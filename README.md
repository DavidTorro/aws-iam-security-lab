<div align="center">

![Banner](./assets/banner.svg)
<br>
  <img src="https://img.shields.io/badge/-Terraform-7b42bc?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/-AWS%20IAM-dd344c?style=for-the-badge" alt="AWS IAM">
  <img src="https://img.shields.io/badge/-Amazon%20S3-569a31?style=for-the-badge" alt="Amazon S3">
  <img src="https://img.shields.io/badge/-Amazon%20EC2-ff9900?style=for-the-badge" alt="Amazon EC2">
  <img src="https://img.shields.io/badge/-LocalStack-1d2a6b?style=for-the-badge" alt="LocalStack">
  <br>
  <a href="https://github.com/DavidTorro/aws-iam-security-lab/actions/workflows/ci.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/DavidTorro/aws-iam-security-lab/ci.yml?branch=main&style=for-the-badge&label=CI" alt="CI">
  </a>
  <a href="https://davidtorro.github.io/aws-iam-security-lab/">
    <img src="https://img.shields.io/badge/docs-MkDocs-526cfe?style=for-the-badge&logo=materialformkdocs&logoColor=white" alt="Documentación">
  </a>
  <a href="https://davidtorro.github.io/aws-iam-security-lab/pdf/aws-iam-security-lab.pdf">
    <img src="https://img.shields.io/badge/memoria-PDF-b30b00?style=for-the-badge&logo=adobeacrobatreader&logoColor=white" alt="Memoria en PDF">
  </a>
  <a href="https://github.com/DavidTorro">
    <img src="https://img.shields.io/badge/author-David%20Torr%C3%B3-181717?style=for-the-badge&logo=github&logoColor=white" alt="Author: David Torró">
  </a>
</div>

# AWS IAM Security Lab

Práctica de seguridad en AWS IAM resuelta como infraestructura como código con Terraform

📖 **[Documentación](https://davidtorro.github.io/aws-iam-security-lab/)** · 📄 **[Memoria en PDF](https://davidtorro.github.io/aws-iam-security-lab/pdf/aws-iam-security-lab.pdf)**

## Qué incluye

| Política | Qué permite | Restricciones |
| --- | --- | --- |
| `daw-s3-readonly-policy` | Listar buckets y leer objetos | Sin subida ni borrado |
| `daw-ec2-ops-policy` | Ver, arrancar y parar instancias | Deny explícito a terminar |
| `daw-ec2-region-policy` | Lanzar instancias | Solo en `us-east-1` |
| `daw-business-hours-policy` | — (solo deniega) | Fuera de 08:00–18:00 UTC |
| `daw-ec2-ops-hardened-policy` | Ver, arrancar y parar instancias | `us-east-1`, horario laboral y sin terminar |

Además, **6 usuarios y 3 grupos** (Desarrolladores, Operaciones, Auditoria) con los permisos asignados siempre a los grupos y una política de contraseñas de la cuenta

## Dos entornos

AWS Academy permite crear políticas pero no usuarios ni grupos, así que el proyecto se despliega en dos sitios con el mismo código

| Entorno | Qué despliega | Cómo se verifica |
| --- | --- | --- |
| [`envs/academy`](envs/academy) | Las 5 políticas en AWS real | Tests contra el simulador de IAM |
| [`envs/localstack`](envs/localstack) | Políticas, usuarios, grupos y contraseñas | Tests unitarios con mock y AWS CLI |

## Estructura

```text
policies/                   JSON y plantillas (.tftpl) de las políticas
modules/iam-policy/         crea una política y la reemplaza al cambiar su JSON
modules/policy-simulation/  consulta el simulador de IAM desde Terraform
envs/academy/               despliegue en AWS Academy y tests de simulación
envs/localstack/            despliegue completo en LocalStack y tests unitarios
docs/                       documentación (MkDocs) y capturas
```

## Uso rápido

**Requisitos:** Terraform ≥ 1.9, Docker y, para Academy, credenciales en `~/.aws/credentials`

### AWS Academy

```bash
cd envs/academy
terraform init
terraform apply
terraform test   # 15 tests contra el simulador de IAM
```

### LocalStack

```bash
cd envs/localstack
docker compose up -d
terraform init
terraform apply
terraform test   # tests unitarios, no necesitan LocalStack
```

### Documentación en local

```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/mkdocs serve
```

## Decisiones destacadas

- **Reemplazar en lugar de versionar:** Academy deniega `iam:CreatePolicyVersion`, así que el módulo destruye y recrea la política cuando cambia su JSON
- **Deny explícito para las restricciones:** región, horario y terminación se mantienen aunque el usuario reciba permisos por otro grupo
- **Horario para un día concreto:** IAM no tiene condiciones recurrentes y la ventana se genera desde la variable `business_day`
- **Verificación con Terraform:** el simulador web ignora las condiciones globales o aplica las SCP de Academy, así que los casos con región y horario se comprueban con `terraform test`

Todas las decisiones y su motivo están en [Decisiones](https://davidtorro.github.io/aws-iam-security-lab/decisiones/)

## Licencia

Código bajo licencia [MIT](LICENSE)
