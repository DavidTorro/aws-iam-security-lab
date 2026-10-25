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
envs/localstack/            despliegue completo en LocalStack (pendiente)
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

!!! info "En construcción"
    Esta sección se completará a medida que se implementen los módulos y entornos
