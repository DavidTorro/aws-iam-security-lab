# Decisiones

Registro de las decisiones técnicas del proyecto y su motivo

## Terraform en lugar de solo AWS CLI

Las restricciones de AWS Academy afectan igual a las dos herramientas, pero Terraform aporta código versionado, planes de cambios revisables y un despliegue reproducible

## Dos entornos: AWS Academy y LocalStack

AWS Academy permite crear políticas pero no usuarios ni grupos. Las políticas se despliegan en AWS real y la parte de usuarios y grupos se despliega en LocalStack, reutilizando el mismo código

## Reemplazar en lugar de versionar

`iam:CreatePolicyVersion` está denegado, así que una política no se puede modificar en sitio. Cuando cambia su JSON, Terraform la elimina y la crea de nuevo

## Políticas sin etiquetas

`iam:TagPolicy` está denegado. Las políticas no llevan `tags` y el provider no usa `default_tags`

## Deny explícito para las restricciones

Las restricciones de región, horario y terminación se escriben como `Deny` con condición en lugar de `Allow` con condición. Un `Deny` explícito prevalece sobre cualquier `Allow` de otra política, así que la restricción se mantiene aunque el usuario reciba permisos por otra vía

## Prefijo `daw-`

Los nombres de las políticas usan el prefijo `daw-` que fija el enunciado. La mención a `asix-ec2-ops-policy` en la ampliación se considera una errata

## Documentación como código

La memoria se escribe en Markdown dentro del repositorio, se publica con MkDocs en GitHub Pages y se exporta a PDF con `mkdocs-to-pdf`. Los JSON de las políticas se incrustan desde `policies/`, de modo que la documentación muestra siempre el código real
