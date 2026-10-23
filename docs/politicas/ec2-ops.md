# Operaciones EC2

**Enunciados:** Ejercicios IAM 4 · Ampliación partes 0 y 2

## Escenario

El equipo de soporte necesita encender los servidores por la mañana y apagarlos por la noche. La semana pasada un empleado eliminó por error un servidor web crucial, así que no deben poder terminar instancias

## Requisitos

- Permitir ver (`Describe*`) todos los recursos de EC2
- Permitir arrancar (`StartInstances`) y parar (`StopInstances`) cualquier instancia
- Denegar explícitamente la terminación (`TerminateInstances`)
- Nombre de la política: `daw-ec2-ops-policy`

## Comprobaciones esperadas

| Acción | Resultado esperado |
|---|---|
| `ec2:StartInstances` | Allowed |
| `ec2:StopInstances` | Allowed |
| `ec2:TerminateInstances` | Denied (explicit deny) |

!!! info "En construcción"
    Aquí irán el JSON de la política, el código Terraform y las capturas de la consola y del simulador
