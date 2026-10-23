output "policy_arns" {
  description = "ARN de cada política desplegada, para usarlos en el simulador"
  value = {
    (module.s3_readonly.name) = module.s3_readonly.arn
  }
}
