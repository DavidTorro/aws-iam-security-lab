output "policy_arns" {
  description = "ARN de cada política desplegada, para usarlos en el simulador"
  value = {
    (module.s3_readonly.name)      = module.s3_readonly.arn
    (module.ec2_ops.name)          = module.ec2_ops.arn
    (module.ec2_region.name)       = module.ec2_region.arn
    (module.business_hours.name)   = module.business_hours.arn
    (module.ec2_ops_hardened.name) = module.ec2_ops_hardened.arn
  }
}

output "business_window" {
  description = "Ventana horaria aplicada en las políticas con horario"
  value       = "${local.business_window.window_start} - ${local.business_window.window_end}"
}
