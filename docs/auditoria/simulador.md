# Auditoría con el simulador

**Enunciado:** Ampliación parte 4

Como las cuentas de alumno no permiten crear usuarios, las políticas se verifican con el **IAM Policy Simulator**, que evalúa una política para una acción y un contexto concretos sin ejecutarla

## Tests de auditoría

| Test | Política | Acción | Contexto | Esperado en el enunciado | Resultado obtenido |
|---|---|---|---|---|---|
| 1 | [S3 de solo lectura](../politicas/s3-readonly.md) | `s3:GetObject` | | Allowed | `allowed` |
| 2 | [S3 de solo lectura](../politicas/s3-readonly.md) | `s3:DeleteObject` | | Denied | `explicitDeny` |
| 3 | [Operaciones EC2](../politicas/ec2-ops.md) | `ec2:TerminateInstances` | | Denied (explicit deny) | `explicitDeny` |
| 4A | [Hardening](../politicas/ec2-ops-hardened.md) | `ec2:StartInstances` | `us-east-1` | Allowed | `allowed` |
| 4B | [Hardening](../politicas/ec2-ops-hardened.md) | `ec2:StartInstances` | `eu-west-1` | Denied (condition failed) | `explicitDeny` |

En el test 4B el enunciado espera una condición no cumplida porque plantea la restricción como un `Allow` con condición. En este proyecto las restricciones son `Deny` explícitos, así que la acción queda igualmente denegada pero por una denegación explícita, que prevalece sobre cualquier otra política

Además de estos cinco tests, cada política tiene comprobaciones extra en su página

## Resultado

```text
$ terraform test
tests/simulation.tftest.hcl... in progress
  run "test_1_s3_get_object_allowed"... pass
  run "test_2_s3_delete_object_denied"... pass
  run "s3_list_allowed"... pass
  run "s3_write_denied"... pass
  run "test_3_ec2_terminate_denied"... pass
  run "ec2_ops_start_stop_describe_allowed"... pass
  run "ec2_region_run_instances_us_east_1_allowed"... pass
  run "ec2_region_run_instances_eu_west_1_denied"... pass
  run "business_hours_inside_window_allowed"... pass
  run "business_hours_before_opening_denied"... pass
  run "business_hours_after_closing_denied"... pass
  run "test_4a_hardened_start_us_east_1_allowed"... pass
  run "test_4b_hardened_start_eu_west_1_denied"... pass
  run "hardened_start_after_closing_denied"... pass
  run "hardened_terminate_denied"... pass
tests/simulation.tftest.hcl... pass

Success! 15 passed, 0 failed.
```

## Cómo se ejecutan

- **Simulador web:** el procedimiento del enunciado, en modo *Personalizado*, con capturas de cada resultado
- **Terraform:** `terraform test` desde `envs/academy`, que repite los tests tras cada cambio

### Tests con Terraform

Terraform no tiene un recurso para `iam:SimulateCustomPolicy`, así que el módulo `policy-simulation` lo llama a través de la AWS CLI con un data source `external`

```hcl
--8<-- "modules/policy-simulation/main.tf"
```

Cada test indica las políticas, las acciones y, si hace falta, el contexto de la petición, y comprueba la decisión del simulador. Por ejemplo, el test 4B

```hcl
--8<-- "envs/academy/tests/simulation.tftest.hcl:267:288"
```

| Decisión | Significado |
|---|---|
| `allowed` | Una sentencia `Allow` concede la acción |
| `explicitDeny` | Una sentencia `Deny` la bloquea, aunque otra política la permita |
| `implicitDeny` | Ninguna sentencia la concede |

!!! note "Credenciales"
    Los tests consultan el simulador real, así que necesitan credenciales de AWS Academy y se ejecutan en local. El CI solo valida su sintaxis

!!! warning "Indicar siempre la región"
    Las condiciones negativas como `StringNotEquals` se cumplen cuando la clave no existe en la petición. Si un test no indicara `aws:RequestedRegion`, el `Deny` por región se aplicaría y la acción saldría denegada. Por eso los tests de las políticas con región la indican siempre

## Capturas del simulador web

### Tests 1 y 2

![Tests 1 y 2: GetObject permitido y DeleteObject denegado](../assets/capturas/s3-readonly-simulador.png)

### Test 3

![Test 3: TerminateInstances denegado](../assets/capturas/ec2-ops-simulador.png)

### Test 4A

El simulador web nuevo no aplica las condiciones globales (`aws:RequestedRegion`, `aws:CurrentTime`), así que el test 4A se verifica con `test_4a_hardened_start_us_east_1_allowed`

### Test 4B

Igual que el 4A, se verifica con `test_4b_hardened_start_eu_west_1_denied`, que devuelve `explicitDeny`
