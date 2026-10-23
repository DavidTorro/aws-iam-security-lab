# Tests de auditoría de la Ampliación parte 4, ejecutados contra el simulador de IAM
# Necesitan credenciales de AWS Academy: terraform test desde envs/academy
# Usan command = plan porque el simulador se consulta al leer el data source, sin crear nada

# Test 1: el analista puede leer los backups
run "test_1_s3_get_object_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policy  = file("../../policies/s3-readonly.json")
    actions = ["s3:GetObject"]
  }

  assert {
    condition     = output.decisions["s3:GetObject"] == "allowed"
    error_message = "s3:GetObject debería estar permitido y da ${output.decisions["s3:GetObject"]}"
  }
}

# Test 2: el analista no puede borrar los backups
# explicitDeny confirma que lo bloquea la sentencia Deny y no la falta de un Allow
run "test_2_s3_delete_object_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policy  = file("../../policies/s3-readonly.json")
    actions = ["s3:DeleteObject"]
  }

  assert {
    condition     = output.decisions["s3:DeleteObject"] == "explicitDeny"
    error_message = "s3:DeleteObject debería tener una denegación explícita y da ${output.decisions["s3:DeleteObject"]}"
  }
}

# Comprobaciones extra del resto de requisitos del enunciado de S3
run "s3_list_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policy  = file("../../policies/s3-readonly.json")
    actions = ["s3:ListAllMyBuckets", "s3:ListBucket"]
  }

  assert {
    condition     = alltrue([for decision in values(output.decisions) : decision == "allowed"])
    error_message = "Listar buckets y objetos debería estar permitido: ${jsonencode(output.decisions)}"
  }
}

run "s3_write_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policy  = file("../../policies/s3-readonly.json")
    actions = ["s3:PutObject", "s3:DeleteObjectVersion"]
  }

  assert {
    condition     = alltrue([for decision in values(output.decisions) : decision == "explicitDeny"])
    error_message = "Subir objetos y borrar versiones debería estar denegado: ${jsonencode(output.decisions)}"
  }
}
