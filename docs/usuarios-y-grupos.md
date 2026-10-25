# Usuarios y grupos

## Enunciado

Crear grupos y usuarios en IAM, asignar permisos a los grupos y añadir los usuarios a ellos siguiendo las buenas prácticas de seguridad

## Diseño

El enunciado propone tres grupos y seis usuarios. Un usuario puede pertenecer a varios grupos o a ninguno

| Usuario | Desarrolladores | Operaciones | Auditoría |
|---|:---:|:---:|:---:|
| Alicia | ✓ | | |
| Roberto | ✓ | | ✓ |
| Sandra | ✓ | | |
| Marta | | ✓ | |
| Alexis | | ✓ | ✓ |
| Camila | | | |

Los permisos se asignan **siempre a los grupos y nunca a los usuarios**, tal y como recomienda el enunciado: con muchos usuarios es la única forma de mantener el control

## ¿Qué pasa si un usuario está en varios grupos?

El enunciado plantea esta duda. IAM no elige un grupo "ganador": evalúa **todas las políticas a la vez** con estas reglas

1. Por defecto todo está denegado (*implicit deny*)
2. Un `Allow` de cualquier política concede el permiso: los permisos de los grupos se suman
3. Un `Deny` explícito en cualquier política gana siempre, aunque otra lo permita

Roberto, por ejemplo, tendrá la suma de los permisos de Desarrolladores y Auditoría, salvo lo que alguna de las dos deniegue de forma explícita

## Buenas prácticas aplicadas

- Mínimo privilegio: solo los permisos necesarios
- Permisos en grupos, no en usuarios
- Política de contraseñas de la cuenta
- MFA para todos los usuarios
- No usar la cuenta root en el día a día

## Implementación

AWS Academy deniega `CreateUser` y `CreateGroup`, así que los usuarios y grupos se despliegan en **LocalStack**, un emulador de AWS que corre en local con Docker. El entorno `envs/localstack` crea también las cinco políticas de la práctica para poder adjuntarlas

### Permisos de cada grupo

| Grupo | Políticas | Motivo |
|---|---|---|
| Desarrolladores | `daw-s3-readonly-policy`, `daw-ec2-region-policy` | Consultar datos en S3 y lanzar instancias solo en `us-east-1` |
| Operaciones | `daw-ec2-ops-hardened-policy` | Arrancar y parar servidores en `us-east-1` y en horario laboral, sin poder terminarlos |
| Auditoria | `SecurityAudit` (gestionada de AWS) | Revisar la configuración de seguridad sin leer el contenido de los datos |

### Grupos y usuarios

La relación entre usuarios y grupos se define como datos, en un mapa, y Terraform crea los recursos a partir de él

```hcl
--8<-- "envs/localstack/locals.tf:8:24"
```

```hcl
--8<-- "envs/localstack/main.tf:42:71"
```

### Política de contraseñas

```hcl
--8<-- "envs/localstack/main.tf:73:83"
```

### Despliegue

```bash
cd envs/localstack
docker compose up -d
terraform init
terraform apply
```

El apply crea 29 recursos: 5 políticas, 3 grupos, 4 adjuntos de políticas, 6 usuarios, 5 membresías, la política de contraseñas y las 5 huellas de las políticas

Para comprobar los grupos de Roberto

```bash
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test aws --endpoint-url http://localhost:4566 \
  iam list-groups-for-user --user-name roberto --query 'Groups[].GroupName' --output text
```

```text
Auditoria	Desarrolladores
```

!!! note "MFA"
    El MFA se activa con un dispositivo físico o una app en cada usuario, así que no se automatiza con Terraform
