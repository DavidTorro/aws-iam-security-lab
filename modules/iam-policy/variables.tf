variable "name" {
  description = "Nombre de la política en AWS"
  type        = string

  # Todas las políticas de la práctica usan el prefijo que fija el enunciado
  validation {
    condition     = startswith(var.name, "daw-") && endswith(var.name, "-policy")
    error_message = "El nombre debe empezar por daw- y acabar en -policy, por ejemplo daw-s3-readonly-policy"
  }
}

variable "description" {
  description = "Descripción de la política, visible en la consola de IAM"
  type        = string

  # Límite de IAM para la descripción de una política
  validation {
    condition     = length(var.description) <= 1000
    error_message = "La descripción no puede superar los 1000 caracteres"
  }
}

variable "policy" {
  description = "Documento JSON de la política"
  type        = string

  # Falla en el plan, antes de llamar a AWS, si el JSON está mal escrito
  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "La política debe ser un documento JSON válido"
  }

  # IAM limita una política gestionada a 6144 caracteres sin contar espacios
  # jsonencode devuelve el JSON compacto, sin espacios ni saltos de línea
  # Si el JSON no es válido ya lo avisa la validación anterior, por eso try devuelve true
  validation {
    condition     = try(length(jsonencode(jsondecode(var.policy))) <= 6144, true)
    error_message = "La política supera el límite de 6144 caracteres de IAM"
  }
}
