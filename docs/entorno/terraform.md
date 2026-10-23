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

## Estructura prevista

```text
policies/        documentos JSON de las políticas
modules/         módulos reutilizables de Terraform
envs/academy/    despliegue real en AWS Academy
envs/localstack/ despliegue completo en LocalStack
tests/           tests unitarios y de simulación
docs/            esta documentación
```

!!! info "En construcción"
    Esta sección se completará a medida que se implementen los módulos y entornos
