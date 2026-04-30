# 🚀 Guía de Releases (Trunk-Based Development)

## 📋 Contexto

Los releases se generan **automáticamente** desde `main`. No existe rama `develop`. Las features van directamente a `main` vía PR.

Flujo:
```
feature/* → PR → main → release-publish.yml detecta commits → tag v*.*.* → producción
```

> Las ramas `release/vX.X.X` ya no se usan. Los tags se crean directamente sobre `main`.

---

## 🎯 Crear un Release

### Opción A: Automático (por defecto)

No requiere acción manual. Al mergear un PR a `main`, `release-publish.yml` analiza los conventional commits:

| Tipo de commit | Resultado |
|---|---|
| `feat:` | minor (ej: `v1.0.0` → `v1.1.0`) |
| `fix:` / `perf:` | patch (ej: `v1.0.0` → `v1.0.1`) |
| `feat!:` / `BREAKING CHANGE:` | major (ej: `v1.0.0` → `v2.0.0`) |
| `chore:` / `docs:` / `style:` / `refactor:` | sin release |

Simplemente haz `merge` de tu PR a `main`.

---

### Opción B: Manual (fallback)

> ⚠️ Solo usar si el auto-release falló.

```bash
# Asegúrate de estar en main actualizado
git checkout main
git pull origin main

# Crear tag directamente
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# Crear GitHub Release
gh release create v1.2.0 --title "v1.2.0" --generate-notes
```

---

## 🔥 Hotfix

```bash
# Crear hotfix desde main
git checkout main
git pull origin main
git checkout -b hotfix/fix-descripcion

# Implementar el fix
git add .
git commit -m "fix: descripción del fix crítico"
git push origin hotfix/fix-descripcion

# PR a main
gh pr create --base main --title "Hotfix: descripción"
```

Después del merge: `release-publish.yml` detecta el commit `fix:` y genera el tag + release automáticos.

---

## ✅ Checklist Final

- [ ] PR con `feat:` / `fix:` / `perf:` merged a `main`
- [ ] `release-publish.yml` ejecutó correctamente (ver Actions tab)
- [ ] Tag `vX.X.X` creado automáticamente
- [ ] GitHub Release publicado

> **Fallback manual:** si el auto-release falló, verificar que el tag se creó y la release existe.

---

**Maintainer**: @daviilpzDev
