# Hardening con condiciones

**Enunciado:** Ampliación parte 3

## Escenario

Aplicar el principio de mínimo privilegio no solo según quién hace una acción, sino también dónde y cuándo. Se parte de la política de [Operaciones EC2](ec2-ops.md) y se le añaden condiciones

## Requisitos

- **Restricción geográfica:** solo se pueden operar servidores en `us-east-1`
- **Restricción horaria:** encender y apagar solo está permitido de 08:00 a 18:00 UTC

## Versión o política nueva

El enunciado propone modificar la política o crear una nueva versión. En AWS Academy `iam:CreatePolicyVersion` está denegado, así que la política endurecida se crea como una política independiente

!!! note "Nombre de la política"
    El enunciado menciona `asix-ec2-ops-policy`, mientras que la parte 2 usa el prefijo `daw-`. En este proyecto se mantiene el prefijo `daw-`

## Comprobaciones esperadas

| Acción | Contexto | Resultado esperado |
|---|---|---|
| `ec2:StartInstances` | `us-east-1` | Allowed |
| `ec2:StartInstances` | `eu-west-1` | Denied (condition failed) |

!!! info "En construcción"
    Aquí irán el JSON de la política, el código Terraform y las capturas
