# Valores posibles: allowed, explicitDeny o implicitDeny
output "decisions" {
  description = "Decisión del simulador para cada acción"
  value       = data.external.simulation.result
}
