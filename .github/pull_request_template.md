## Qué cambia

<!-- Resumen breve del cambio -->

## Por qué

<!-- Motivo o problema que resuelve. Enlaza el issue si existe: Closes #N -->

## Cómo se ha probado

<!-- Comandos ejecutados y resultado: plan, apply, tests, simulador... -->

## Checklist

- [ ] El título de la PR sigue Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`...)
- [ ] `terraform fmt -recursive` aplicado
- [ ] `terraform validate` sin errores en los entornos afectados
- [ ] Las variables y outputs nuevos tienen `type` y `description`
- [ ] No se suben estados, credenciales ni claves
- [ ] Documentación actualizada si hace falta
