# AWS Academy

La práctica se realiza en un **Learner Lab de AWS Academy** (Vocareum). Es una cuenta real de AWS, pero con permisos IAM recortados por el centro. Antes de diseñar nada se analizó qué operaciones están permitidas, con llamadas reales desde AWS CLI y con el simulador de IAM

!!! warning "Simulación no es despliegue"
    Un resultado `allowed` en el simulador no garantiza que la llamada real funcione. Las conclusiones de esta página se confirman o corrigen al desplegar con Terraform

## Resumen

| Tipo | Cantidad | Cómo se obtuvo |
|---|---|---|
| Acciones permitidas | 7 | Simulación favorable |
| Acciones restringidas | 5 | `implicitDeny` en simulación |
| Acciones bloqueadas | 2 | `explicitDeny` en llamadas reales |

## Operaciones permitidas

| Acción | Para qué sirve |
|---|---|
| `iam:CreatePolicy` | Crear políticas personalizadas |
| `iam:ListPolicies` | Listar políticas |
| `iam:GetPolicy` | Consultar una política propia |
| `iam:GetPolicyVersion` | Leer el JSON de una versión |
| `iam:ListPolicyVersions` | Consultar las versiones |
| `iam:DeletePolicy` | Eliminar políticas |
| `iam:SimulateCustomPolicy` | Simular un JSON sin desplegarlo |

Además, `iam:SimulatePrincipalPolicy` se ha ejecutado con éxito en llamadas reales

## Operaciones restringidas

Estas acciones devuelven `implicitDeny`: ninguna política del laboratorio las autoriza

| Acción | Consecuencia |
|---|---|
| `iam:CreateUser` | No se pueden crear usuarios |
| `iam:CreateGroup` | No se pueden crear grupos |
| `iam:AttachGroupPolicy` | No se pueden asociar políticas a grupos |
| `iam:CreatePolicyVersion` | Una política creada no se puede modificar |
| `iam:TagPolicy` | No se pueden etiquetar políticas |

## Bloqueos explícitos

AWS rechazó estas llamadas reales con `explicitDeny`, causado por la política interna del laboratorio `Pvoclabs2`

| Acción | Recurso |
|---|---|
| `iam:GetRole` | Rol `voclabs` |
| `iam:GetPolicy` | Política `Pvoclabs2` |

Esto demuestra que hay protecciones específicas sobre los recursos internos del laboratorio, pero no que todas las políticas de la cuenta estén protegidas del mismo modo

## Impacto en el proyecto

| Necesidad | Situación | Solución adoptada |
|---|---|---|
| Crear políticas | Permitido | Despliegue real con Terraform |
| Modificar una política | Bloqueado por `CreatePolicyVersion` | Reemplazar la política en lugar de versionarla |
| Etiquetar recursos | Bloqueado por `TagPolicy` | Políticas sin etiquetas |
| Crear usuarios y grupos | Bloqueado | Desplegarlos en LocalStack |
| Asignar políticas para probarlas | Bloqueado | Verificar con el simulador de IAM |

## Pendiente de comprobar

- Ciclo completo `plan → apply → modificar → destroy` con Terraform
- Permisos sobre roles (`CreateRole`, `PassRole`), EC2 y S3
- Restricciones de AWS Organizations (SCP) y límites propios de la sesión

## Otras limitaciones del entorno

- Las **credenciales son temporales** y caducan con la sesión del laboratorio, unas 4 horas
- La clave `.pem` del laboratorio sirve para SSH en EC2, no concede permisos IAM
