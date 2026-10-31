output "api_endpoint" {
  description = "URL base de la API."
  value       = aws_apigatewayv2_api.http.api_endpoint
}

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_client_id" {
  description = "ID del app client de Cognito."
  value       = aws_cognito_user_pool_client.web.id
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda."
  value       = module.compute.function_name
}
