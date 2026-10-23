terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    # Ejecuta simulate.sh y recoge su salida como datos de Terraform
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}
