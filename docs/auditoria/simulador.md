# Auditoría con el simulador

**Enunciado:** Ampliación parte 4

Como las cuentas de alumno no permiten crear usuarios, las políticas se verifican con el **IAM Policy Simulator**, que evalúa una política para una acción y un contexto concretos sin ejecutarla

## Tests de auditoría

| Test | Política | Acción | Contexto | Resultado esperado |
|---|---|---|---|---|
| 1 | S3 de solo lectura | `s3:GetObject` | | Allowed |
| 2 | S3 de solo lectura | `s3:DeleteObject` | | Denied |
| 3 | Operaciones EC2 | `ec2:TerminateInstances` | | Denied (explicit deny) |
| 4A | Hardening | `ec2:StartInstances` | `us-east-1` | Allowed |
| 4B | Hardening | `ec2:StartInstances` | `eu-west-1` | Denied (condition failed) |

## Cómo se ejecutan

- **Simulador web:** el procedimiento del enunciado, en modo *Personalizado*, con capturas de cada resultado
- **Terraform:** `terraform test` desde `envs/academy`, que repite los tests tras cada cambio

### Tests con Terraform

Terraform no tiene un recurso para `iam:SimulateCustomPolicy`, así que el módulo `policy-simulation` lo llama a través de la AWS CLI con un data source `external`

```hcl
--8<-- "modules/policy-simulation/main.tf"
```

Cada test indica la política, las acciones y, si hace falta, el contexto de la petición, y comprueba la decisión del simulador

```hcl
--8<-- "envs/academy/tests/simulation.tftest.hcl:6:24"
```

| Decisión | Significado |
|---|---|
| `allowed` | Una sentencia `Allow` concede la acción |
| `explicitDeny` | Una sentencia `Deny` la bloquea, aunque otra política la permita |
| `implicitDeny` | Ninguna sentencia la concede |

!!! note "Credenciales"
    Los tests consultan el simulador real, así que necesitan credenciales de AWS Academy y se ejecutan en local. El CI solo valida su sintaxis

!!! info "En construcción"
    Aquí irán los resultados de cada test y sus capturas
