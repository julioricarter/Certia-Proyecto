locals {
  name_prefix = "lab09-${var.project_name}-${var.environment}"
}

# ---------------------------------------------------------------------------
# Cognito: User Pool con los 3 grupos del diagrama (Hogar, Técnico, Administrador)
# ---------------------------------------------------------------------------
resource "aws_cognito_user_pool" "main" {
  name                     = "${local.name_prefix}-users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "web" {
  name            = "${local.name_prefix}-web"
  user_pool_id    = aws_cognito_user_pool.main.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}

resource "aws_cognito_user_group" "groups" {
  for_each     = toset(var.user_groups)
  name         = each.value
  user_pool_id = aws_cognito_user_pool.main.id
}

# ---------------------------------------------------------------------------
# Cómputo: Lambda (módulo compute)
# ---------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  name_prefix        = local.name_prefix
  log_retention_days = var.log_retention_days
}

# ---------------------------------------------------------------------------
# API Gateway (HTTP API) protegido con el JWT de Cognito
# ---------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.http.id
  name             = "cognito-jwt"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.web.id]
    issuer   = "https://${aws_cognito_user_pool.main.endpoint}"
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.compute.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "tecnicos" {
  api_id             = aws_apigatewayv2_api.http.id
  route_key          = "GET /tecnicos"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowInvokeFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.compute.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
