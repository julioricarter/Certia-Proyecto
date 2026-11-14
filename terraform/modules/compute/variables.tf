variable "name_prefix" {
  description = "Prefijo de nombres para los recursos del módulo."
  type        = string
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch."
  type        = number
  default     = 7
}

variable "cloudwatch_kms_key_arn" {
  type        = string
  description = "ARN de la llave KMS para cifrar los logs de CloudWatch"
  default     = null # O puedes dejarlo sin default si es obligatorio
}