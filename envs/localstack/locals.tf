locals {
  # Ventana horaria en el formato ISO 8601 que espera aws:CurrentTime
  business_window = {
    window_start = "${var.business_day}T${var.opening_time}:00Z"
    window_end   = "${var.business_day}T${var.closing_time}:00Z"
  }

  # Políticas de cada grupo: las propias de la práctica y una gestionada de AWS para Auditoria
  group_policies = {
    Desarrolladores = [module.s3_readonly.arn, module.ec2_region.arn]
    Operaciones     = [module.ec2_ops_hardened.arn]
    Auditoria       = ["arn:aws:iam::aws:policy/SecurityAudit"]
  }

  # Grupos de cada usuario, según la tabla del enunciado
  # Camila no está en ningún grupo: existe pero no tiene permisos
  user_groups = {
    alicia  = ["Desarrolladores"]
    roberto = ["Desarrolladores", "Auditoria"]
    sandra  = ["Desarrolladores"]
    marta   = ["Operaciones"]
    alexis  = ["Operaciones", "Auditoria"]
    camila  = []
  }

  # aws_iam_group_policy_attachment adjunta una sola política, así que se aplana el mapa en pares grupo-política
  # La clave usa el índice y no el ARN porque los ARN de las políticas propias no se conocen hasta el apply
  group_policy_attachments = merge([
    for group, arns in local.group_policies : {
      for index, arn in arns : "${group}-${index}" => { group = group, policy_arn = arn }
    }
  ]...)
}
