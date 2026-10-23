# S3 de solo lectura

**Enunciados:** Ejercicios IAM 1 · Ampliación parte 1

## Escenario

El departamento de analítica necesita consultar los backups guardados en Amazon S3, pero el equipo de seguridad prohíbe que puedan borrar o modificar los datos existentes

## Requisitos

- Permitir listar todos los buckets (`ListBucket`)
- Permitir descargar y leer objetos (`GetObject`)
- No permitir bajo ningún concepto la subida (`PutObject`) ni el borrado (`DeleteObject`)
- Nombre de la política: `daw-s3-readonly-policy`

## Comprobaciones esperadas

| Acción | Resultado esperado |
|---|---|
| `s3:GetObject` | Allowed |
| `s3:DeleteObject` | Denied |

!!! info "En construcción"
    Aquí irán el JSON de la política, el código Terraform y las capturas de la consola y del simulador
