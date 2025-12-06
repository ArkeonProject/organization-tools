# 🚀 Guía: Crear Release v1.0.0 de organization-tools

## 📋 Contexto

Estás en `develop` con todos los cambios de limpieza y optimización listos. Ahora vamos a crear el primer release oficial para integrar estos cambios en `main`.

## 🎯 Pasos para Crear el Release

### 1. Verificar Estado Actual

```bash
# Asegúrate de estar en develop
git checkout develop
git pull origin develop

# Verifica que todo esté limpio
git status
```

✅ **Estado actual**: Estás en develop, todo limpio

---

### 2. Crear Branch de Release

```bash
# Crear branch release/v1.0.0 desde develop
git checkout -b release/v1.0.0

# Verificar que estás en la rama correcta
git branch --show-current
# Debe mostrar: release/v1.0.0
```

---

### 3. Actualizar Versión en CHANGELOG (Ya está hecho)

Tu `CHANGELOG.md` ya tiene la sección `[Unreleased]`. Vamos a convertirla en `[1.0.0]`:

```bash
# Editar CHANGELOG.md
# Cambiar:
## [Unreleased]

# Por:
## [1.0.0] - 2025-12-06
```

**Nota**: Voy a hacer este cambio por ti ahora.

---

### 4. Commit de Preparación del Release

```bash
git add CHANGELOG.md
git commit -m "chore(release): prepare v1.0.0"
```

---

### 5. Push del Branch de Release

```bash
git push origin release/v1.0.0
```

---

### 6. Crear Pull Request a Main

```bash
# Opción A: Con GitHub CLI (recomendado)
gh pr create \
  --base main \
  --head release/v1.0.0 \
  --title "Release v1.0.0" \
  --body "## 🚀 Release v1.0.0

### Cambios Principales

- ✅ Limpieza completa de archivos duplicados y directorios vacíos
- ✅ Nuevas composite actions: setup-bun, setup-docker
- ✅ Script setup-repo.sh mejorado con dry-run e interactivo
- ✅ Script de validación de workflows
- ✅ Documentación completa actualizada
- ✅ Bug fix en ci-node.yml

### Archivos Eliminados
- 12 archivos redundantes/duplicados
- 7 directorios vacíos

### Archivos Creados
- 2 composite actions nuevas
- 1 script de validación
- 2 archivos de documentación (CONTRIBUTING.md, CHANGELOG.md)

### Archivos Mejorados
- README.md, ARCHITECTURE.md, DEVELOPER_GUIDE.md
- setup-repo.sh (96 → 312 líneas)

Ver [CHANGELOG.md](./CHANGELOG.md) para detalles completos."

# Opción B: Manualmente en GitHub UI
# Ve a: https://github.com/ArkeonProject/organization-tools/compare/main...release/v1.0.0
```

---

### 7. Revisar y Aprobar el PR

Como este es el repositorio de organización y tú eres el maintainer:

1. **Revisa el PR** en GitHub
2. **Verifica los cambios** (diff)
3. **Aprueba el PR** (si tienes otro maintainer, pídele que revise)
4. **Merge el PR** a main

---

### 8. Crear Tag y GitHub Release (Después del Merge)

Una vez que el PR esté merged a `main`:

```bash
# Cambiar a main y actualizar
git checkout main
git pull origin main

# Crear tag anotado
git tag -a v1.0.0 -m "Release v1.0.0

## Highlights
- Complete CI/CD infrastructure cleanup and optimization
- New composite actions for Bun and Docker
- Enhanced setup script with dry-run mode
- Comprehensive documentation updates

See CHANGELOG.md for full details."

# Push del tag
git push origin v1.0.0
```

---

### 9. Crear GitHub Release

```bash
# Opción A: Con GitHub CLI
gh release create v1.0.0 \
  --title "v1.0.0 - CI/CD Infrastructure Overhaul" \
  --notes "## 🚀 First Official Release

### ✨ Highlights

- **Cleaned up infrastructure**: Removed 12 duplicate files and 7 empty directories
- **New composite actions**: setup-bun and setup-docker for modern workflows
- **Enhanced tooling**: Improved setup script with dry-run, interactive, and validation modes
- **Comprehensive docs**: Updated README, ARCHITECTURE, DEVELOPER_GUIDE + new CONTRIBUTING.md

### 📦 What's Included

#### New Components
- \`setup-bun\` composite action for Bun runtime
- \`setup-docker\` composite action for multi-platform Docker builds
- \`validate-workflows.sh\` script for YAML validation
- CONTRIBUTING.md with detailed guidelines
- CHANGELOG.md for version tracking

#### Improvements
- Enhanced \`setup-repo.sh\` (96 → 312 lines) with:
  - \`--dry-run\` mode for safe testing
  - \`--interactive\` mode for guided setup
  - \`--validate\` mode for prerequisite checking
- Updated documentation with diagrams and examples
- Fixed missing step IDs in ci-node.yml

#### Removed
- Duplicate workflow files
- Redundant \`ci-templates/\` directory
- Empty directories (docker-login, semantic-version, etc.)
- Obsolete \`setup-ci.sh\` script

### 📚 Documentation

- [README.md](./README.md) - Quick start and usage
- [ARCHITECTURE.md](./docs/ARCHITECTURE.md) - System design
- [DEVELOPER_GUIDE.md](./docs/DEVELOPER_GUIDE.md) - Development workflows
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Contribution guidelines
- [CHANGELOG.md](./CHANGELOG.md) - Version history

### 🚀 Getting Started

\`\`\`bash
# Setup a new Node.js project
./scripts/setup-repo.sh my-project node

# Setup a new Python project
./scripts/setup-repo.sh my-api python

# Validate workflows
./scripts/validate-workflows.sh
\`\`\`

---

**Full Changelog**: https://github.com/ArkeonProject/organization-tools/blob/main/CHANGELOG.md"

# Opción B: Manualmente en GitHub UI
# Ve a: https://github.com/ArkeonProject/organization-tools/releases/new
# Tag: v1.0.0
# Title: v1.0.0 - CI/CD Infrastructure Overhaul
# Description: (copia el texto de arriba)
```

---

### 10. Back-merge a Develop

Después de crear el release, sincroniza develop con main:

```bash
git checkout develop
git pull origin develop
git merge main
git push origin develop
```

---

## ✅ Checklist Final

- [ ] Branch `release/v1.0.0` creado desde develop
- [ ] CHANGELOG.md actualizado con fecha
- [ ] Commit de preparación realizado
- [ ] PR creado: release/v1.0.0 → main
- [ ] PR revisado y aprobado
- [ ] PR merged a main
- [ ] Tag v1.0.0 creado en main
- [ ] GitHub Release publicado
- [ ] Develop sincronizado con main

---

## 🎉 ¡Listo!

Después de estos pasos tendrás:

1. ✅ Release v1.0.0 en main
2. ✅ Tag v1.0.0 creado
3. ✅ GitHub Release publicado
4. ✅ Develop sincronizado

Ahora todos los proyectos pueden usar:
```yaml
uses: ArkeonProject/organization-tools/.github/workflows/reusable/ci-node.yml@v1.0.0
# o
uses: ArkeonProject/organization-tools/.github/workflows/reusable/ci-node.yml@main
```

---

## 📝 Notas Importantes

- **@v1.0.0**: Versión estable, no cambia
- **@main**: Siempre la última versión, puede cambiar
- **Recomendación**: Usa `@main` en desarrollo, `@v1.0.0` en producción

---

**¿Listo para empezar?** Ejecuta el paso 2 para crear el branch de release.
