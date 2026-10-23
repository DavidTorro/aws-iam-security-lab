# Flujo de trabajo

El repositorio sigue **GitHub Flow**: `main` siempre está estable y todo cambio entra mediante una pull request desde una rama propia

## Ramas

```text
main (protegida)
 ├── docs/mkdocs-setup  →  PR  →  main
 ├── feat/...           →  PR  →  main
 └── ...
```

| Prefijo | Uso |
|---|---|
| `feat/` | Nueva funcionalidad: políticas, módulos, entornos |
| `fix/` | Corrección de un error |
| `docs/` | Documentación |
| `ci/` | Workflows de GitHub Actions |
| `chore/` | Configuración y mantenimiento |

## Commits

Los mensajes siguen **Conventional Commits**: `tipo(ámbito): descripción`

```text
feat(policies): add s3 readonly policy
docs: add academy restrictions analysis
ci: add mkdocs build job
```

Las pull requests se integran con **squash merge**, de modo que cada PR queda en `main` como un único commit con el título de la PR

## Protección de `main`

`main` está protegida con un ruleset de GitHub

| Regla | Efecto |
|---|---|
| Pull request obligatoria | No se puede hacer push directo |
| Solo squash merge | Historial lineal, un commit por PR |
| Checks de CI obligatorios | No se integra nada con el CI en rojo |
| Conversaciones resueltas | Los comentarios de revisión deben cerrarse |
| Sin force push ni borrado | El historial de `main` no se reescribe |
| Sin excepciones | La regla se aplica también al propietario |

## Integración continua

| Workflow | Cuándo | Qué hace |
|---|---|---|
| CI | Cada PR y push a `main` | Comprueba el formato de Terraform y construye la documentación |
| Documentación | Push a `main` | Publica esta web y el PDF en GitHub Pages |
| Dependabot | Semanal | Propone actualizar el provider de AWS, las actions y MkDocs |

## Seguimiento

Cada fase de la práctica tiene un issue en GitHub. La pull request que la completa lo cierra con `Closes #N`
