# Políticas de la práctica, las mismas que en academy
module "s3_readonly" {
  source = "../../modules/iam-policy"

  name        = "daw-s3-readonly-policy"
  description = "Lectura de buckets y objetos de S3 sin permiso de subida ni borrado"
  policy      = file("${path.root}/../../policies/s3-readonly.json")
}

module "ec2_ops" {
  source = "../../modules/iam-policy"

  name        = "daw-ec2-ops-policy"
  description = "Ver, arrancar y parar instancias EC2 sin permiso para terminarlas"
  policy      = file("${path.root}/../../policies/ec2-ops.json")
}

module "ec2_region" {
  source = "../../modules/iam-policy"

  name        = "daw-ec2-region-policy"
  description = "Lanzar instancias EC2 solo en la región us-east-1"
  policy      = file("${path.root}/../../policies/ec2-region.json")
}

module "business_hours" {
  source = "../../modules/iam-policy"

  name        = "daw-business-hours-policy"
  description = "Deniega cualquier acción fuera del horario laboral de ${var.opening_time} a ${var.closing_time} UTC del ${var.business_day}"
  policy      = templatefile("${path.root}/../../policies/business-hours.json.tftpl", local.business_window)
}

module "ec2_ops_hardened" {
  source = "../../modules/iam-policy"

  name        = "daw-ec2-ops-hardened-policy"
  description = "Operaciones EC2 limitadas a us-east-1 y al horario laboral de ${var.opening_time} a ${var.closing_time} UTC del ${var.business_day}"
  policy      = templatefile("${path.root}/../../policies/ec2-ops-hardened.json.tftpl", local.business_window)
}

# Grupos
resource "aws_iam_group" "this" {
  for_each = local.group_policies

  name = each.key
}

# Los permisos se asignan a los grupos, nunca a los usuarios
resource "aws_iam_group_policy_attachment" "this" {
  for_each = local.group_policy_attachments

  group      = aws_iam_group.this[each.value.group].name
  policy_arn = each.value.policy_arn
}

# Usuarios
resource "aws_iam_user" "this" {
  for_each = local.user_groups

  name = each.key
}

# Un usuario puede estar en varios grupos: IAM suma los Allow y cualquier Deny explícito gana
# Camila no tiene grupos, así que no se le crea membresía
resource "aws_iam_user_group_membership" "this" {
  for_each = { for user, groups in local.user_groups : user => groups if length(groups) > 0 }

  user   = aws_iam_user.this[each.key].name
  groups = [for group in each.value : aws_iam_group.this[group].name]
}

# Política de contraseñas de la cuenta, una de las buenas prácticas del enunciado
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 14
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
}
