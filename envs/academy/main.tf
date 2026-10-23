# Ejercicios IAM 1 · Ampliación parte 1
module "s3_readonly" {
  source = "../../modules/iam-policy"

  name        = "daw-s3-readonly-policy"
  description = "Lectura de buckets y objetos de S3 sin permiso de subida ni borrado"
  policy      = file("${path.root}/../../policies/s3-readonly.json")
}
