# Salida de ARN (Amazon Resource Name) de la política IAM creada
output "arn" {
  description = "ARN de la política, necesario para adjuntarla o simularla"
  value       = aws_iam_policy.this.arn
}

# Salida del nombre de la política IAM creada
output "name" {
  description = "Nombre de la política en AWS"
  value       = aws_iam_policy.this.name
}
