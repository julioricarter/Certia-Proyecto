variable "name_prefix" {
  description = "Prefijo de nombres para los recursos del módulo."
  type        = string
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch."
  type        = number
  default     = 7
}
