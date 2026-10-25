# Tests unitarios de usuarios y grupos
# El provider es un mock: no hace falta LocalStack ni Docker y se pueden ejecutar en el CI
# command = apply con mock no crea nada, pero da valores a los ARN para poder comprobar los adjuntos
# terraform test desde envs/localstack

mock_provider "aws" {
  # El mock genera cadenas aleatorias y el provider exige que policy_arn tenga formato de ARN
  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::000000000000:policy/mock"
    }
  }
}

variables {
  business_day = "2026-10-23"
}

run "identity" {
  command = apply

  # Los tres grupos del enunciado
  assert {
    condition     = toset(keys(aws_iam_group.this)) == toset(["Desarrolladores", "Operaciones", "Auditoria"])
    error_message = "Deberían existir los grupos Desarrolladores, Operaciones y Auditoria"
  }

  # Los seis usuarios del enunciado
  assert {
    condition     = length(aws_iam_user.this) == 6
    error_message = "Deberían existir 6 usuarios y hay ${length(aws_iam_user.this)}"
  }

  # Roberto pertenece a dos grupos y suma sus permisos
  assert {
    condition     = toset(aws_iam_user_group_membership.this["roberto"].groups) == toset(["Desarrolladores", "Auditoria"])
    error_message = "Roberto debería estar en Desarrolladores y Auditoria"
  }

  # Alexis también pertenece a dos grupos
  assert {
    condition     = toset(aws_iam_user_group_membership.this["alexis"].groups) == toset(["Operaciones", "Auditoria"])
    error_message = "Alexis debería estar en Operaciones y Auditoria"
  }

  # Camila existe pero no pertenece a ningún grupo
  assert {
    condition     = contains(keys(aws_iam_user.this), "camila") && !contains(keys(aws_iam_user_group_membership.this), "camila")
    error_message = "Camila debería existir sin pertenecer a ningún grupo"
  }

  # Operaciones solo tiene la política endurecida
  assert {
    condition     = [for a in aws_iam_group_policy_attachment.this : a.policy_arn if a.group == "Operaciones"] == [module.ec2_ops_hardened.arn]
    error_message = "Operaciones debería tener solo daw-ec2-ops-hardened-policy"
  }

  # Auditoria usa la política gestionada de solo lectura de seguridad
  assert {
    condition     = [for a in aws_iam_group_policy_attachment.this : a.policy_arn if a.group == "Auditoria"] == ["arn:aws:iam::aws:policy/SecurityAudit"]
    error_message = "Auditoria debería tener solo SecurityAudit"
  }

  # Ninguna política se adjunta a un usuario: el entorno no declara ese tipo de recurso
  assert {
    condition     = length(aws_iam_group_policy_attachment.this) == 4
    error_message = "Deberían existir 4 adjuntos de políticas a grupos"
  }

  # Política de contraseñas robusta
  assert {
    condition     = aws_iam_account_password_policy.this.minimum_password_length >= 14 && aws_iam_account_password_policy.this.require_symbols
    error_message = "La política de contraseñas debería exigir al menos 14 caracteres y símbolos"
  }
}
