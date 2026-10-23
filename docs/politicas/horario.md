# Acceso por horario

**Enunciado:** Ejercicios IAM 3

## Objetivo

Permitir que un usuario acceda a AWS solo en horario laboral, de 08:00 a 18:00 UTC

## Limitación de IAM

IAM no tiene una condición de horario que se repita cada día. La clave de condición `aws:CurrentTime` solo admite comparaciones con fechas completas (`DateGreaterThan`, `DateLessThan`), por ejemplo `2026-10-23T08:00:00Z`

Por eso una política estática solo puede limitar el acceso a una ventana concreta, no a "todos los días de 8 a 18". Es una limitación del propio IAM, no de AWS Academy

Además, IAM no impide iniciar sesión en la consola: lo que hace la política es denegar todas las acciones fuera del horario, de modo que la consola queda inutilizable

## Comprobaciones esperadas

| Momento | Resultado esperado |
|---|---|
| Dentro de la ventana | Allowed |
| Fuera de la ventana | Denied |

!!! info "En construcción"
    Aquí irán la solución adoptada para la ventana horaria, el JSON, el código Terraform y las capturas
