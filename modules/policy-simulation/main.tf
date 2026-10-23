# Terraform no tiene un recurso para iam:SimulateCustomPolicy, así que se llama a la CLI
# Usa las mismas credenciales que el resto del proyecto (~/.aws/credentials)
data "external" "simulation" {
  program = ["bash", "${path.module}/simulate.sh"]

  query = {
    policy    = var.policy
    actions   = jsonencode(var.actions)
    resources = jsonencode(var.resource_arns)
    context = jsonencode([
      for entry in var.context : {
        ContextKeyName   = entry.key
        ContextKeyType   = entry.type
        ContextKeyValues = entry.values
      }
    ])
  }
}
