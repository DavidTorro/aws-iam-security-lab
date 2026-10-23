variable "policy" {
  description = "Documento JSON de la política que se simula"
  type        = string

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "La política debe ser un documento JSON válido"
  }
}

variable "actions" {
  description = "Acciones que se evalúan, por ejemplo s3:GetObject"
  type        = list(string)

  validation {
    condition     = length(var.actions) > 0
    error_message = "Hay que indicar al menos una acción"
  }
}

variable "resource_arns" {
  description = "Recursos sobre los que se evalúan las acciones"
  type        = list(string)
  default     = ["*"]
}

# Equivale a las condiciones de solicitud del simulador web, como la región o la fecha
variable "context" {
  description = "Claves de contexto de la petición simulada"
  type = list(object({
    key    = string
    type   = string
    values = list(string)
  }))
  default = []
}
