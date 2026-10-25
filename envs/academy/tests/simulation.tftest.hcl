# Tests de las políticas contra el simulador de IAM
# Incluyen los tests de auditoría de la Ampliación parte 4
# Necesitan credenciales de AWS Academy: terraform test desde envs/academy
# Usan command = plan porque el simulador se consulta al leer el data source, sin crear nada
# Las políticas con horario usan una ventana fija para que el resultado no dependa de terraform.tfvars

# ---------------------------------------------------------------------------
# S3 de solo lectura · Ejercicios IAM 1 · Ampliación parte 1
# ---------------------------------------------------------------------------

# Test 1: el analista puede leer los backups
run "test_1_s3_get_object_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [file("../../policies/s3-readonly.json")]
    actions  = ["s3:GetObject"]
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
    policies = [file("../../policies/s3-readonly.json")]
    actions  = ["s3:DeleteObject"]
  }

  assert {
    condition     = output.decisions["s3:DeleteObject"] == "explicitDeny"
    error_message = "s3:DeleteObject debería tener una denegación explícita y da ${output.decisions["s3:DeleteObject"]}"
  }
}

run "s3_list_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [file("../../policies/s3-readonly.json")]
    actions  = ["s3:ListAllMyBuckets", "s3:ListBucket"]
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
    policies = [file("../../policies/s3-readonly.json")]
    actions  = ["s3:PutObject", "s3:DeleteObjectVersion"]
  }

  assert {
    condition     = alltrue([for decision in values(output.decisions) : decision == "explicitDeny"])
    error_message = "Subir objetos y borrar versiones debería estar denegado: ${jsonencode(output.decisions)}"
  }
}

# ---------------------------------------------------------------------------
# Operaciones EC2 · Ejercicios IAM 4 · Ampliación partes 0 y 2
# ---------------------------------------------------------------------------

# Test 3: el equipo de soporte no puede terminar instancias
run "test_3_ec2_terminate_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [file("../../policies/ec2-ops.json")]
    actions  = ["ec2:TerminateInstances"]
  }

  assert {
    condition     = output.decisions["ec2:TerminateInstances"] == "explicitDeny"
    error_message = "ec2:TerminateInstances debería tener una denegación explícita y da ${output.decisions["ec2:TerminateInstances"]}"
  }
}

run "ec2_ops_start_stop_describe_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [file("../../policies/ec2-ops.json")]
    actions  = ["ec2:StartInstances", "ec2:StopInstances", "ec2:DescribeInstances"]
  }

  assert {
    condition     = alltrue([for decision in values(output.decisions) : decision == "allowed"])
    error_message = "Ver, arrancar y parar instancias debería estar permitido: ${jsonencode(output.decisions)}"
  }
}

# ---------------------------------------------------------------------------
# EC2 restringido a región · Ejercicios IAM 2
# ---------------------------------------------------------------------------

run "ec2_region_run_instances_us_east_1_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [file("../../policies/ec2-region.json")]
    actions  = ["ec2:RunInstances"]
    context  = [{ key = "aws:RequestedRegion", type = "string", values = ["us-east-1"] }]
  }

  assert {
    condition     = output.decisions["ec2:RunInstances"] == "allowed"
    error_message = "Lanzar instancias en us-east-1 debería estar permitido y da ${output.decisions["ec2:RunInstances"]}"
  }
}

run "ec2_region_run_instances_eu_west_1_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [file("../../policies/ec2-region.json")]
    actions  = ["ec2:RunInstances"]
    context  = [{ key = "aws:RequestedRegion", type = "string", values = ["eu-west-1"] }]
  }

  assert {
    condition     = output.decisions["ec2:RunInstances"] == "explicitDeny"
    error_message = "Lanzar instancias en eu-west-1 debería tener una denegación explícita y da ${output.decisions["ec2:RunInstances"]}"
  }
}

# ---------------------------------------------------------------------------
# Acceso por horario · Ejercicios IAM 3
# La política solo deniega, así que se simula junto a otra que conceda permisos
# ---------------------------------------------------------------------------

run "business_hours_inside_window_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [
      file("../../policies/s3-readonly.json"),
      templatefile("../../policies/business-hours.json.tftpl", { window_start = "2026-10-23T08:00:00Z", window_end = "2026-10-23T18:00:00Z" }),
    ]
    actions = ["s3:GetObject"]
    context = [{ key = "aws:CurrentTime", type = "date", values = ["2026-10-23T10:00:00Z"] }]
  }

  assert {
    condition     = output.decisions["s3:GetObject"] == "allowed"
    error_message = "A las 10:00 el acceso debería estar permitido y da ${output.decisions["s3:GetObject"]}"
  }
}

run "business_hours_before_opening_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [
      file("../../policies/s3-readonly.json"),
      templatefile("../../policies/business-hours.json.tftpl", { window_start = "2026-10-23T08:00:00Z", window_end = "2026-10-23T18:00:00Z" }),
    ]
    actions = ["s3:GetObject"]
    context = [{ key = "aws:CurrentTime", type = "date", values = ["2026-10-23T07:00:00Z"] }]
  }

  assert {
    condition     = output.decisions["s3:GetObject"] == "explicitDeny"
    error_message = "A las 07:00 el acceso debería estar denegado y da ${output.decisions["s3:GetObject"]}"
  }
}

run "business_hours_after_closing_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [
      file("../../policies/s3-readonly.json"),
      templatefile("../../policies/business-hours.json.tftpl", { window_start = "2026-10-23T08:00:00Z", window_end = "2026-10-23T18:00:00Z" }),
    ]
    actions = ["s3:GetObject"]
    context = [{ key = "aws:CurrentTime", type = "date", values = ["2026-10-23T20:00:00Z"] }]
  }

  assert {
    condition     = output.decisions["s3:GetObject"] == "explicitDeny"
    error_message = "A las 20:00 el acceso debería estar denegado y da ${output.decisions["s3:GetObject"]}"
  }
}

# ---------------------------------------------------------------------------
# Hardening con condiciones · Ampliación parte 3
# ---------------------------------------------------------------------------

# Test 4A: arrancar en us-east-1 dentro del horario
run "test_4a_hardened_start_us_east_1_allowed" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [templatefile("../../policies/ec2-ops-hardened.json.tftpl", { window_start = "2026-10-23T08:00:00Z", window_end = "2026-10-23T18:00:00Z" })]
    actions  = ["ec2:StartInstances"]
    context = [
      { key = "aws:RequestedRegion", type = "string", values = ["us-east-1"] },
      { key = "aws:CurrentTime", type = "date", values = ["2026-10-23T10:00:00Z"] },
    ]
  }

  assert {
    condition     = output.decisions["ec2:StartInstances"] == "allowed"
    error_message = "Arrancar en us-east-1 a las 10:00 debería estar permitido y da ${output.decisions["ec2:StartInstances"]}"
  }
}

# Test 4B: arrancar en eu-west-1 dentro del horario
run "test_4b_hardened_start_eu_west_1_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [templatefile("../../policies/ec2-ops-hardened.json.tftpl", { window_start = "2026-10-23T08:00:00Z", window_end = "2026-10-23T18:00:00Z" })]
    actions  = ["ec2:StartInstances"]
    context = [
      { key = "aws:RequestedRegion", type = "string", values = ["eu-west-1"] },
      { key = "aws:CurrentTime", type = "date", values = ["2026-10-23T10:00:00Z"] },
    ]
  }

  assert {
    condition     = output.decisions["ec2:StartInstances"] == "explicitDeny"
    error_message = "Arrancar en eu-west-1 debería estar denegado y da ${output.decisions["ec2:StartInstances"]}"
  }
}

run "hardened_start_after_closing_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [templatefile("../../policies/ec2-ops-hardened.json.tftpl", { window_start = "2026-10-23T08:00:00Z", window_end = "2026-10-23T18:00:00Z" })]
    actions  = ["ec2:StartInstances", "ec2:StopInstances"]
    context = [
      { key = "aws:RequestedRegion", type = "string", values = ["us-east-1"] },
      { key = "aws:CurrentTime", type = "date", values = ["2026-10-23T20:00:00Z"] },
    ]
  }

  assert {
    condition     = alltrue([for decision in values(output.decisions) : decision == "explicitDeny"])
    error_message = "Arrancar y parar a las 20:00 debería estar denegado: ${jsonencode(output.decisions)}"
  }
}

run "hardened_terminate_denied" {
  command = plan

  module {
    source = "../../modules/policy-simulation"
  }

  variables {
    policies = [templatefile("../../policies/ec2-ops-hardened.json.tftpl", { window_start = "2026-10-23T08:00:00Z", window_end = "2026-10-23T18:00:00Z" })]
    actions  = ["ec2:TerminateInstances"]
    context = [
      { key = "aws:RequestedRegion", type = "string", values = ["us-east-1"] },
      { key = "aws:CurrentTime", type = "date", values = ["2026-10-23T10:00:00Z"] },
    ]
  }

  assert {
    condition     = output.decisions["ec2:TerminateInstances"] == "explicitDeny"
    error_message = "Terminar instancias debería seguir denegado y da ${output.decisions["ec2:TerminateInstances"]}"
  }
}
