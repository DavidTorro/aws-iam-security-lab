<div align="center">

![Banner](./assets/banner.svg)
<br>
  <img src="https://img.shields.io/badge/-Terraform-7b42bc?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/-AWS%20IAM-dd344c?style=for-the-badge" alt="AWS IAM">
  <img src="https://img.shields.io/badge/-Amazon%20S3-569a31?style=for-the-badge" alt="Amazon S3">
  <img src="https://img.shields.io/badge/-Amazon%20EC2-ff9900?style=for-the-badge" alt="Amazon EC2">
  <img src="https://img.shields.io/badge/-LocalStack-1d2a6b?style=for-the-badge" alt="LocalStack">
  <br>
  <a href="https://github.com/DavidTorro">
    <img src="https://img.shields.io/badge/author-David%20Torr%C3%B3-181717?style=for-the-badge&logo=github&logoColor=white" alt="Author: David Torró">
  </a>
</div>

# AWS IAM Security Lab
Práctica de seguridad en AWS IAM resuelta como infraestructura como código con Terraform

## Objetivo

- Políticas IAM de mínimo privilegio para S3 y EC2
- Restricciones con condiciones: región (`us-east-1`) y horario laboral (08:00–18:00 UTC)
- Usuarios y grupos gestionados como código
- Verificación automatizada con el simulador de políticas de IAM
