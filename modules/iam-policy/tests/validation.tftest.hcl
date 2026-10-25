# Tests unitarios del módulo iam-policy
# El provider es un mock: no hace falta AWS ni credenciales y se pueden ejecutar en el CI
# terraform test desde modules/iam-policy

mock_provider "aws" {}

variables {
  name        = "daw-test-policy"
  description = "Política de prueba"
  policy      = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"*\"}]}"
}

# Con datos válidos el plan pasa y la política recibe el nombre indicado
run "valid_policy" {
  command = plan

  assert {
    condition     = aws_iam_policy.this.name == "daw-test-policy"
    error_message = "La política debería llamarse daw-test-policy"
  }
}

# La huella no cambia si solo cambian los espacios del JSON
run "revision_ignores_whitespace" {
  command = plan

  variables {
    policy = <<-EOT
      {
        "Version": "2012-10-17",
        "Statement": [
          { "Effect": "Allow", "Action": "s3:GetObject", "Resource": "*" }
        ]
      }
    EOT
  }

  assert {
    condition     = terraform_data.policy_revision.input == sha256(jsonencode(jsondecode("{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"*\"}]}")))
    error_message = "La huella debería ser la misma que con el JSON compacto"
  }
}

# Un nombre sin el prefijo daw- se rechaza en el plan
run "name_without_prefix" {
  command = plan

  variables {
    name = "s3-readonly-policy"
  }

  expect_failures = [var.name]
}

# Un nombre sin el sufijo -policy también se rechaza
run "name_without_suffix" {
  command = plan

  variables {
    name = "daw-s3-readonly"
  }

  expect_failures = [var.name]
}

# Un JSON mal escrito se rechaza antes de llamar a AWS
run "invalid_json" {
  command = plan

  variables {
    policy = "{\"Version\": \"2012-10-17\","
  }

  expect_failures = [var.policy]
}

# Una política que supera el límite de 6144 caracteres de IAM se rechaza
run "policy_too_long" {
  command = plan

  variables {
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [{ Effect = "Allow", Action = [for i in range(500) : "s3:Action${i}"], Resource = "*" }]
    })
  }

  expect_failures = [var.policy]
}
