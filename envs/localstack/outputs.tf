output "user_groups" {
  description = "Grupos a los que pertenece cada usuario"
  value       = { for user, groups in local.user_groups : aws_iam_user.this[user].name => groups }
}

output "group_policies" {
  description = "Políticas adjuntas a cada grupo"
  value       = local.group_policies
}
