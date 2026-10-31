variable "aws_region" {
  description = "Región AWS donde se despliega el laboratorio (misma del bucket de estado)."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Nombre del proyecto."
  type        = string
  default     = "certia"
}

variable "environment" {
  description = "Entorno de despliegue."
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch."
  type        = number
  default     = 7
}

variable "user_groups" {
  description = "Grupos del User Pool de Cognito (roles de la plataforma)."
  type        = list(string)
  default     = ["hogar", "tecnico", "administrador"]
}
