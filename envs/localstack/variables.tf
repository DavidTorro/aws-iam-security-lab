# IAM no tiene una condición de horario que se repita cada día: aws:CurrentTime solo compara fechas completas
# Por eso las políticas con horario se generan para un día concreto
variable "business_day" {
  description = "Día laborable al que se aplica la ventana horaria, en formato AAAA-MM-DD"
  type        = string

  validation {
    condition     = can(formatdate("YYYY-MM-DD", "${var.business_day}T00:00:00Z"))
    error_message = "El día debe tener el formato AAAA-MM-DD, por ejemplo 2026-10-23"
  }
}

variable "opening_time" {
  description = "Hora de inicio del horario laboral en UTC, en formato HH:MM"
  type        = string
  default     = "08:00"

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.opening_time))
    error_message = "La hora debe tener el formato HH:MM, por ejemplo 08:00"
  }
}

variable "closing_time" {
  description = "Hora de fin del horario laboral en UTC, en formato HH:MM"
  type        = string
  default     = "18:00"

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.closing_time))
    error_message = "La hora debe tener el formato HH:MM, por ejemplo 18:00"
  }
}

variable "localstack_endpoint" {
  description = "URL de LocalStack a la que se envían las llamadas de IAM y STS"
  type        = string
  default     = "http://localhost:4566"
}
