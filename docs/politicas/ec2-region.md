# EC2 restringido a región

**Enunciado:** Ejercicios IAM 2

## Objetivo

Permitir que un usuario solo cree instancias EC2 en la región `us-east-1` (Norte de Virginia)

## Requisitos

- Lanzar instancias (`RunInstances`) solo en `us-east-1`
- Cualquier intento en otra región debe ser denegado

## Comprobaciones esperadas

| Acción | Región | Resultado esperado |
|---|---|---|
| `ec2:RunInstances` | `us-east-1` | Allowed |
| `ec2:RunInstances` | `eu-west-1` | Denied |

!!! note "Verificación"
    El enunciado propone adjuntar la política a un usuario de prueba y lanzar una instancia en otra región. Como AWS Academy no permite crear usuarios, la restricción se verifica con el simulador indicando la región en el contexto

!!! info "En construcción"
    Aquí irán el JSON de la política, el código Terraform y las capturas
