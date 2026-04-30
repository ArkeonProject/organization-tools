# 🚀 Guía de Releases (Trunk-Based Development)

## 📋 Contexto

Los releases se crean desde `main`. No existe rama `develop`. Las features van directamente a `main` via PR.

Flujo:
```
feature/* → PR → main → release/vX.X.X → PR → main → tag v*.*.* → producción
```

---

## 🎯 Crear un Release

### Opción A: Via GitHub Actions (recomendado)

1. Ve a **Actions** → **Release** → **Run workflow**
2. Elige el tipo de bump:
   - `patch` — fixes (1.0.0 → 1.0.1)
   - `minor` — nuevas features (1.0.0 → 1.1.0)
   - `major` — breaking changes (1.0.0 → 2.0.0)
3. Click **Run workflow**

El workflow automáticamente:
- ✅ Crea `release/vX.X.X` desde `main`
- ✅ Actualiza versión en `package.json` / `pyproject.toml`
- ✅ Crea PR a `main` con checklist
- ✅ Al mergear: crea tag `vX.X.X` + GitHub Release

---

### Opción B: Manual

```bash
# Asegúrate de estar en main actualizado
git checkout main
git pull origin main

# Crear branch de release
git checkout -b release/v1.2.0

# Bump versión
npm version minor --no-git-tag-version
# o: poetry version minor

# Commit
git add .
git commit -m "chore(release): prepare v1.2.0"
git push origin release/v1.2.0

# Crear PR a main
gh pr create --base main --title "Release v1.2.0"
```

Después del merge:

```bash
git checkout main
git pull origin main

# Crear tag
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
git checkout -b hotfix/v1.1.1

# Implementar el fix
git add .
git commit -m "fix: descripción del fix crítico"
git push origin hotfix/v1.1.1

# PR a main
gh pr create --base main --title "Hotfix v1.1.1: descripción"
```

Después del merge: tag + release automáticos via workflow.

---

## ✅ Checklist Final

- [ ] `release/vX.X.X` creado desde `main`
- [ ] Versión actualizada en archivos del proyecto
- [ ] PR revisado y CI pasando
- [ ] PR merged a `main`
- [ ] Tag `vX.X.X` creado
- [ ] GitHub Release publicado

---

**Maintainer**: @daviilpzDev
