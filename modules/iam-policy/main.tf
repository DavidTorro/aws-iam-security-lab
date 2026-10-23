# Huella del contenido de la política
# Se normaliza el JSON para que cambiar espacios o saltos de línea no cuente como cambio
resource "terraform_data" "policy_revision" {
  input = sha256(jsonencode(jsondecode(var.policy)))
}

# Crear la política IAM
resource "aws_iam_policy" "this" {
  name        = var.name
  description = var.description
  policy      = var.policy

  # Sin tags: iam:TagPolicy está denegado en AWS Academy

  lifecycle {
    # Modificar una política existente necesita iam:CreatePolicyVersion, que está denegado
    # Cuando cambia el JSON, Terraform destruye la política y la vuelve a crear
    replace_triggered_by = [terraform_data.policy_revision]
  }
}
