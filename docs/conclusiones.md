# Conclusiones

## Resultado

La práctica cubre los tres enunciados y todos los requisitos se comprueban de forma automática

| Requisito | Dónde se cumple | Cómo se comprueba |
|---|---|---|
| Usuarios, grupos y permisos por grupo | LocalStack | Tests unitarios y AWS CLI contra LocalStack |
| S3 de solo lectura | AWS Academy | Tests 1 y 2 del simulador |
| EC2 sin terminación | AWS Academy | Test 3 del simulador |
| EC2 solo en `us-east-1` | AWS Academy | Simulador con `aws:RequestedRegion` |
| Acceso por horario | AWS Academy | Simulador con `aws:CurrentTime` |
| Hardening con región y horario | AWS Academy | Tests 4A y 4B del simulador |

## Lo aprendido sobre IAM

- **Todo empieza denegado.** Un permiso solo existe si alguna política lo concede de forma explícita
- **Un `Deny` explícito gana siempre.** Por eso las restricciones de región, horario y terminación se escriben como `Deny`: siguen funcionando aunque el usuario reciba permisos por otro grupo
- **Los permisos de varios grupos se suman.** Roberto y Alexis tienen la unión de los permisos de sus dos grupos, salvo lo que se deniegue de forma explícita
- **Las condiciones negativas se cumplen si falta la clave.** Un `StringNotEquals` sobre `aws:RequestedRegion` deniega también cuando la petición no indica región, algo que hay que tener en cuenta al probar
- **IAM no tiene horarios recurrentes.** `aws:CurrentTime` compara fechas completas, así que "de 8 a 18 todos los días" no se puede expresar en una sola política

## Limitaciones encontradas

- **AWS Academy** no permite crear usuarios, grupos ni versiones de políticas. Se resolvió con dos entornos y reemplazando las políticas en lugar de versionarlas
- **El simulador web nuevo** no aplica las condiciones globales en el modo de políticas personalizadas. Los casos con región y horario se verifican con el simulador desde Terraform, que sí las aplica
- **LocalStack Community** crea los recursos IAM pero no evalúa los permisos, así que no sirve para probar si una acción se permite o se deniega

## Valoración

Resolver la práctica con Terraform en lugar de con la consola ha llevado más trabajo al principio, pero ha dado ventajas claras

- Cada cambio se revisa con `terraform plan` antes de aplicarlo
- Todo el entorno se crea y se destruye con un comando
- Los tests detectan errores en las políticas antes de desplegarlas
- La documentación muestra siempre el código real, porque lo incrusta desde el repositorio

El mismo código sirve para AWS Academy y para LocalStack, y se podría desplegar en una cuenta de AWS real sin cambios en las políticas
