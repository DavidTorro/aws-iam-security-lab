# Varias políticas se evalúan juntas, como un usuario que las tuviera todas adjuntas
variable "policies" {
  description = "Documentos JSON de las políticas que se simulan"
  type        = list(string)

  validation {
    condition     = length(var.policies) > 0 && alltrue([for policy in var.policies : can(jsondecode(policy))])
    error_message = "Hay que indicar al menos una política y todas deben ser documentos JSON válidos"
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
