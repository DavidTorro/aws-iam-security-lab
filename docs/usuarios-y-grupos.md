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

!!! info "En construcción"
    AWS Academy deniega `CreateUser` y `CreateGroup`, por lo que este apartado se implementa como un módulo de Terraform y se despliega en LocalStack
