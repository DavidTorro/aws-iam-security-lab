# Ejercicios IAM 1 · Ampliación parte 1
module "s3_readonly" {
  source = "../../modules/iam-policy"

  name        = "daw-s3-readonly-policy"
  description = "Lectura de buckets y objetos de S3 sin permiso de subida ni borrado"
  policy      = file("${path.root}/../../policies/s3-readonly.json")
}

# Ejercicios IAM 4 · Ampliación partes 0 y 2
module "ec2_ops" {
  source = "../../modules/iam-policy"

  name        = "daw-ec2-ops-policy"
  description = "Ver, arrancar y parar instancias EC2 sin permiso para terminarlas"
  policy      = file("${path.root}/../../policies/ec2-ops.json")
}

# Ejercicios IAM 2
module "ec2_region" {
  source = "../../modules/iam-policy"

  name        = "daw-ec2-region-policy"
  description = "Lanzar instancias EC2 solo en la región us-east-1"
  policy      = file("${path.root}/../../policies/ec2-region.json")
}

# Ejercicios IAM 3
module "business_hours" {
  source = "../../modules/iam-policy"

  name        = "daw-business-hours-policy"
  description = "Deniega cualquier acción fuera del horario laboral de ${var.opening_time} a ${var.closing_time} UTC del ${var.business_day}"
  policy      = templatefile("${path.root}/../../policies/business-hours.json.tftpl", local.business_window)
}

# Ampliación parte 3
module "ec2_ops_hardened" {
  source = "../../modules/iam-policy"

  name        = "daw-ec2-ops-hardened-policy"
  description = "Operaciones EC2 limitadas a us-east-1 y al horario laboral de ${var.opening_time} a ${var.closing_time} UTC del ${var.business_day}"
  policy      = templatefile("${path.root}/../../policies/ec2-ops-hardened.json.tftpl", local.business_window)
}
