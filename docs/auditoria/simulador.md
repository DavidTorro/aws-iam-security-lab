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

- **Simulador web:** el procedimiento del enunciado, con capturas de cada resultado
- **AWS CLI:** `aws iam simulate-custom-policy`, que permite automatizar los tests y repetirlos tras cada cambio

!!! info "En construcción"
    Aquí irán los resultados de cada test y sus capturas
