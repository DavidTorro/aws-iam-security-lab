# AWS IAM Security Lab

Práctica de seguridad en **AWS Identity and Access Management (IAM)** resuelta como infraestructura como código con **Terraform**

El objetivo es diseñar, desplegar y verificar políticas de mínimo privilegio para Amazon S3 y Amazon EC2, aplicar restricciones por región y horario, y modelar usuarios y grupos como código

## Enunciados cubiertos

La práctica reúne tres enunciados que se solapan entre sí. Cada sección de esta documentación agrupa los apartados que tratan el mismo concepto

| Sección | Enunciados |
|---|---|
| [Usuarios y grupos](usuarios-y-grupos.md) | Creación de usuarios y grupos en IAM |
| [S3 de solo lectura](politicas/s3-readonly.md) | Ejercicios IAM 1 · Ampliación parte 1 |
| [Operaciones EC2](politicas/ec2-ops.md) | Ejercicios IAM 4 · Ampliación partes 0 y 2 |
| [EC2 restringido a región](politicas/ec2-region.md) | Ejercicios IAM 2 |
| [Acceso por horario](politicas/horario.md) | Ejercicios IAM 3 |
| [Hardening con condiciones](politicas/ec2-ops-hardened.md) | Ampliación parte 3 |
| [Auditoría con el simulador](auditoria/simulador.md) | Ampliación parte 4 |

## Cómo está organizado el proyecto

- **Políticas** escritas como documentos JSON y desplegadas con Terraform
- **Dos entornos**: AWS Academy para las políticas reales y LocalStack para el ciclo completo con usuarios y grupos
- **Verificación** con el simulador de políticas de IAM
- **Documentación** generada con MkDocs, publicada en GitHub Pages y exportada a PDF

Los detalles están en [AWS Academy](entorno/aws-academy.md), [Terraform](entorno/terraform.md) y [Flujo de trabajo](entorno/flujo-de-trabajo.md)

<div class="web-only" markdown>

!!! tip "Versión en PDF"
    <a href="https://davidtorro.github.io/aws-iam-security-lab/pdf/aws-iam-security-lab.pdf">Descargar la memoria en PDF</a>

</div>
