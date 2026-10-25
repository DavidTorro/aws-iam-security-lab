# Terraform

Toda la práctica se gestiona como **infraestructura como código**. En lugar de crear las políticas a mano en la consola, se describen en archivos versionados y Terraform se encarga de desplegarlas, compararlas y eliminarlas

## Por qué Terraform y no solo AWS CLI

| | AWS CLI | Terraform |
|---|---|---|
| Crear recursos | Un comando por recurso | Se declara el estado deseado |
| Repetir el despliegue | Volver a lanzar los comandos | `terraform apply` |
| Ver qué va a cambiar | No | `terraform plan` |
| Eliminar todo | Recurso a recurso | `terraform destroy` |
| Versionado y revisión | Scripts sueltos | Código revisado en pull requests |

Las restricciones de AWS Academy son iguales para las dos herramientas: lo que la CLI no puede hacer, Terraform tampoco

## Entornos

| Entorno | Qué despliega | Motivo |
|---|---|---|
| `envs/academy` | Solo políticas IAM | AWS Academy deniega crear usuarios, grupos y versiones de políticas |
| `envs/localstack` | Políticas, usuarios y grupos | Emulador local que permite el ciclo completo |

!!! note "LocalStack"
    La edición gratuita de LocalStack permite crear recursos IAM pero no evalúa los permisos. La comprobación de permisos se hace siempre con el simulador de IAM

## Estructura

```text
policies/                   documentos JSON y plantillas (.tftpl) de las políticas
modules/iam-policy/         crea una política IAM y la reemplaza al cambiar
modules/policy-simulation/  consulta el simulador de IAM
envs/academy/               despliegue real en AWS Academy
envs/academy/tests/         tests contra el simulador
envs/localstack/            despliegue completo en LocalStack
envs/localstack/tests/      tests unitarios de usuarios y grupos
modules/iam-policy/tests/   tests unitarios del módulo
docs/                       esta documentación
```

Las políticas con horario son plantillas: Terraform las rellena con `templatefile` y la ventana del día indicado en `terraform.tfvars`

## Módulo `iam-policy`

Todas las políticas se crean con el mismo módulo, que recibe el nombre, la descripción y el JSON

```hcl
--8<-- "modules/iam-policy/main.tf"
```

### Reemplazar en lugar de modificar

Cuando cambia el JSON de una política, AWS no la edita: crea una **versión nueva** con `iam:CreatePolicyVersion`. En AWS Academy esa acción está denegada, así que un `terraform apply` normal fallaría al modificar una política

El módulo guarda una huella (`sha256`) del JSON en un recurso `terraform_data`. Si el JSON cambia, la huella cambia y `replace_triggered_by` obliga a Terraform a **destruir la política y crearla de nuevo**, usando solo `DeletePolicy` y `CreatePolicy`, que sí están permitidos

Resultado real en AWS Academy al añadir una acción al JSON de la política de S3

```text
module.s3_readonly.aws_iam_policy.this: Destroying...
module.s3_readonly.aws_iam_policy.this: Destruction complete after 0s
module.s3_readonly.terraform_data.policy_revision: Modifying...
module.s3_readonly.terraform_data.policy_revision: Modifications complete after 0s
module.s3_readonly.aws_iam_policy.this: Creating...
module.s3_readonly.aws_iam_policy.this: Creation complete after 1s

Apply complete! Resources: 1 added, 1 changed, 1 destroyed.
```

La huella (`terraform_data`) se actualiza en el sitio y su cambio es lo que dispara el reemplazo de la política

### Validaciones

Antes de llamar a AWS, el módulo comprueba que

- El nombre sigue el formato `daw-<nombre>-policy`
- El documento es un JSON válido

- La política no supera los 6144 caracteres de IAM

## Tests unitarios

Además de los tests contra el simulador, el proyecto tiene tests unitarios que usan un **mock** del provider de AWS. No llaman a AWS ni a LocalStack, así que se ejecutan en el CI en cada pull request

| Tests | Qué comprueban |
|---|---|
| `modules/iam-policy/tests` | Las validaciones de nombre, JSON y tamaño, y que la huella ignore los espacios del JSON |
| `envs/localstack/tests` | Los grupos, los usuarios, las membresías, los permisos de cada grupo y la política de contraseñas |

```hcl
--8<-- "modules/iam-policy/tests/validation.tftest.hcl:44:53"
```

```text
$ terraform test
tests/validation.tftest.hcl... pass
  run "valid_policy"... pass
  run "revision_ignores_whitespace"... pass
  run "name_without_prefix"... pass
  run "name_without_suffix"... pass
  run "invalid_json"... pass
  run "policy_too_long"... pass

Success! 6 passed, 0 failed.
```

## Integración continua

Cada pull request ejecuta en GitHub Actions

| Job | Qué hace |
|---|---|
| Terraform fmt | Comprueba el formato de todo el código |
| Terraform validate | Valida la sintaxis y los tipos de los dos entornos |
| Terraform test | Ejecuta los tests unitarios con mock |
| MkDocs build | Genera la web y el PDF en modo estricto |
