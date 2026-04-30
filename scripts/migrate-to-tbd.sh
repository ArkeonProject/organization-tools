#!/bin/bash
# scripts/migrate-to-tbd.sh
# Migra todos los repos de ArkeonProject a Trunk-Based Development.
#
# Para cada repo:
#   1. Detecta commits en develop que NO están en main (excluye back-merges)
#   2. Actualiza ci.yml, release.yml y hotfix.yml via PR
#
# Uso:
#   ./scripts/migrate-to-tbd.sh              # aplica en todos los repos
#   ./scripts/migrate-to-tbd.sh --dry-run    # solo muestra qué haría
#   ./scripts/migrate-to-tbd.sh --org MiOrg  # otra organización
#   ./scripts/migrate-to-tbd.sh --include-cd # también actualiza cd.yml (revisar manualmente)

ORG="${ORG:-ArkeonProject}"
ORG_TOOLS="organization-tools"
MIGRATION_BRANCH="chore/migrate-to-tbd"
DRY_RUN=false
INCLUDE_CD=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info()    { echo -e "  ${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "  ${GREEN}✓${NC} $1"; }
print_warning() { echo -e "  ${YELLOW}⚠${NC} $1"; }
print_error()   { echo -e "  ${RED}✗${NC} $1"; }
print_header()  { echo -e "\n${CYAN}▸ $1${NC}"; }

# ─── Args ────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)   DRY_RUN=true; shift ;;
    --include-cd) INCLUDE_CD=true; shift ;;
    --org)       ORG="$2"; shift 2 ;;
    -h|--help)
      echo "Uso: $0 [--dry-run] [--include-cd] [--org <nombre>]"
      echo ""
      echo "  --dry-run     Muestra qué haría sin aplicar cambios"
      echo "  --include-cd  También actualiza cd.yml (revisar manualmente antes de mergear)"
      echo "  --org         Organización GitHub (default: ArkeonProject)"
      exit 0
      ;;
    *) shift ;;
  esac
done

BASE_URL="https://raw.githubusercontent.com/$ORG/$ORG_TOOLS/main/.github/workflows/templates"

# ─── Prerequisites ───────────────────────────────────────────────────────────

for tool in gh jq curl; do
  if ! command -v "$tool" &>/dev/null; then
    echo -e "${RED}✗ Falta: $tool${NC}"
    exit 1
  fi
done

if ! gh auth status &>/dev/null; then
  echo -e "${RED}✗ gh no autenticado — ejecuta: gh auth login${NC}"
  exit 1
fi

# ─── Helpers ─────────────────────────────────────────────────────────────────

# Devuelve "node", "python" o "node" (default) según los archivos del repo
detect_project_type() {
  local repo=$1
  if gh api "/repos/$ORG/$repo/contents/package.json" >/dev/null 2>&1; then
    echo "node"
  elif gh api "/repos/$ORG/$repo/contents/pyproject.toml" >/dev/null 2>&1; then
    echo "python"
  else
    echo "node"
  fi
}

# Devuelve número de commits en develop no presentes en main,
# excluyendo back-merges y bumps de versión.
# Devuelve "no_develop" si la rama no existe.
count_unmerged_develop() {
  local repo=$1

  if ! gh api "/repos/$ORG/$repo/branches/develop" >/dev/null 2>&1; then
    echo "no_develop"
    return
  fi

  gh api "/repos/$ORG/$repo/compare/main...develop" \
    --jq '[
      .commits[]
      | select(
          .commit.message | test(
            "back-merge|back merge|chore\\(release\\)|Merge branch|Merge pull request";
            "i"
          ) | not
        )
    ] | length' 2>/dev/null || echo "0"
}

# Lista los commits unmerged con su SHA corto y mensaje
list_unmerged_develop() {
  local repo=$1

  gh api "/repos/$ORG/$repo/compare/main...develop" \
    --jq '.commits[]
      | select(
          .commit.message | test(
            "back-merge|back merge|chore\\(release\\)|Merge branch|Merge pull request";
            "i"
          ) | not
        )
      | "    " + .sha[0:7] + " " + (.commit.message | split("\n")[0])' \
    2>/dev/null || true
}

# Sube o actualiza un archivo en el repo vía GitHub Contents API
# Retorna 0 en éxito, 1 en fallo (no aborta el script)
update_workflow_file() {
  local repo=$1
  local filename=$2
  local template_url=$3
  local branch=$4

  # Descarga el template
  local content
  content=$(curl -sf "$template_url") || {
    print_warning "No se pudo descargar: $template_url"
    return 1
  }
  local content_b64
  content_b64=$(echo "$content" | base64 | tr -d '\n')

  # Busca el SHA del archivo en la rama de migración primero, luego en main
  local file_sha
  file_sha=$(
    gh api "/repos/$ORG/$repo/contents/.github/workflows/$filename?ref=$branch" \
      --jq '.sha' 2>/dev/null ||
    gh api "/repos/$ORG/$repo/contents/.github/workflows/$filename" \
      --jq '.sha' 2>/dev/null ||
    echo ""
  )

  local payload
  if [ -n "$file_sha" ]; then
    payload=$(jq -n \
      --arg msg "ci: update $filename for trunk-based development" \
      --arg content "$content_b64" \
      --arg sha "$file_sha" \
      --arg branch "$branch" \
      '{message: $msg, content: $content, sha: $sha, branch: $branch}')
  else
    payload=$(jq -n \
      --arg msg "ci: add $filename for trunk-based development" \
      --arg content "$content_b64" \
      --arg branch "$branch" \
      '{message: $msg, content: $content, branch: $branch}')
  fi

  gh api -X PUT "/repos/$ORG/$repo/contents/.github/workflows/$filename" \
    --input <(echo "$payload") >/dev/null || {
      print_error "Falló al actualizar $filename"
      return 1
    }

  print_success "$filename"
}

# Crea la rama de migración desde main (ignora si ya existe)
create_migration_branch() {
  local repo=$1
  local main_sha
  main_sha=$(gh api "/repos/$ORG/$repo/branches/main" --jq '.commit.sha' 2>/dev/null) || {
    print_error "No se pudo obtener SHA de main"
    return 1
  }

  gh api -X POST "/repos/$ORG/$repo/git/refs" \
    -f ref="refs/heads/$MIGRATION_BRANCH" \
    -f sha="$main_sha" >/dev/null 2>&1 || true
}

# Devuelve URL del PR de migración si ya existe, o vacío
find_existing_pr() {
  local repo=$1
  gh api "/repos/$ORG/$repo/pulls?head=$ORG:$MIGRATION_BRANCH&state=open" \
    --jq '.[0].html_url // ""' 2>/dev/null || echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  🚀 Migración a Trunk-Based Development — $ORG"
echo "═══════════════════════════════════════════════════════════════════"
[ "$DRY_RUN"    = true ] && echo "  ⚠️  DRY RUN — no se aplicarán cambios"
[ "$INCLUDE_CD" = true ] && echo "  📦  Modo --include-cd activo — cd.yml también se actualizará"
echo ""

REPOS=$(gh repo list "$ORG" --limit 200 --json name -q '.[].name' | grep -v "^${ORG_TOOLS}$")

declare -a WARN_REPOS=()
declare -a MIGRATED_REPOS=()
declare -a SKIPPED_REPOS=()
declare -a FAILED_REPOS=()

for repo in $REPOS; do
  echo "───────────────────────────────────────────────────────────────────"
  echo "  📦 $ORG/$repo"

  # ── 1. Detectar divergencia en develop ──────────────────────────────
  UNMERGED=$(count_unmerged_develop "$repo")

  if [ "$UNMERGED" = "no_develop" ]; then
    print_info "Sin rama develop"
  elif [ "$UNMERGED" -eq 0 ]; then
    print_success "develop sin cambios únicos respecto a main"
  else
    print_warning "$UNMERGED commit(s) en develop NO mergeados a main:"
    list_unmerged_develop "$repo"
    WARN_REPOS+=("$repo ($UNMERGED commits)")
  fi

  # ── 2. Detectar PR existente ─────────────────────────────────────────
  EXISTING_PR=$(find_existing_pr "$repo")
  if [ -n "$EXISTING_PR" ]; then
    print_info "PR ya existe: $EXISTING_PR"
    SKIPPED_REPOS+=("$repo (PR ya existe)")
    continue
  fi

  # ── 3. Detectar tipo de proyecto ────────────────────────────────────
  PROJECT_TYPE=$(detect_project_type "$repo")
  print_info "Tipo detectado: $PROJECT_TYPE"

  if [ "$DRY_RUN" = true ]; then
    if [ "$INCLUDE_CD" = true ]; then
      print_info "[DRY RUN] Aplicaría: ci.yml, release.yml, hotfix.yml, cd.yml"
    else
      print_info "[DRY RUN] Aplicaría: ci.yml, release.yml, hotfix.yml"
    fi
    MIGRATED_REPOS+=("$repo")
    continue
  fi

  # ── 4. Crear rama de migración ──────────────────────────────────────
  if ! create_migration_branch "$repo"; then
    FAILED_REPOS+=("$repo (no se pudo crear rama)")
    continue
  fi

  # ── 5. Aplicar templates ─────────────────────────────────────────────
  print_info "Actualizando workflows..."
  REPO_FAILED=false

  if [ "$PROJECT_TYPE" = "node" ]; then
    update_workflow_file "$repo" "ci.yml" "$BASE_URL/node-ci.template.yml" "$MIGRATION_BRANCH" || REPO_FAILED=true
    if [ "$INCLUDE_CD" = true ]; then
      update_workflow_file "$repo" "cd.yml" "$BASE_URL/node-cd.template.yml" "$MIGRATION_BRANCH" || REPO_FAILED=true
    fi
  else
    update_workflow_file "$repo" "ci.yml" "$BASE_URL/python-ci.template.yml" "$MIGRATION_BRANCH" || REPO_FAILED=true
    if [ "$INCLUDE_CD" = true ]; then
      update_workflow_file "$repo" "cd.yml" "$BASE_URL/python-cd.template.yml" "$MIGRATION_BRANCH" || REPO_FAILED=true
    fi
  fi

  update_workflow_file "$repo" "release.yml" "$BASE_URL/release.template.yml" "$MIGRATION_BRANCH" || REPO_FAILED=true
  update_workflow_file "$repo" "hotfix.yml"  "$BASE_URL/hotfix.template.yml"  "$MIGRATION_BRANCH" || REPO_FAILED=true

  if [ "$REPO_FAILED" = true ]; then
    FAILED_REPOS+=("$repo (error al actualizar workflows)")
    continue
  fi

  # ── 6. Crear PR ─────────────────────────────────────────────────────
  CD_LINE=""
  [ "$INCLUDE_CD" = true ] && CD_LINE="\n- \`cd.yml\` — triggers actualizados a TBD"

  PR_BODY="## Migración a Trunk-Based Development

### Cambios aplicados
- \`ci.yml\` — CI corre en \`main\` y \`feature/**\`
- \`release.yml\` — auto-release desde conventional commits al mergear a main
- \`hotfix.yml\` — branch creada sin bump manual; el release es automático${CD_LINE}

### Nuevo flujo de release automático
\`\`\`
feat:  → merge a main → minor  (ej: v1.1.0)
fix:   → merge a main → patch  (ej: v1.0.1)
feat!: → merge a main → major  (ej: v2.0.0)
chore/docs → merge a main → sin release
\`\`\`

### ⚠️ Antes de mergear este PR
- Verifica que no hay commits pendientes en \`develop\` que necesites migrar
- Una vez mergeado, el próximo PR con \`feat:\` o \`fix:\` generará el primer release automático"

  PR_URL=$(
    gh pr create \
      --repo "$ORG/$repo" \
      --head "$MIGRATION_BRANCH" \
      --base main \
      --title "ci: migrate workflows to trunk-based development" \
      --body "$PR_BODY" \
      2>/dev/null
  ) || { PR_URL="(error al crear PR)"; FAILED_REPOS+=("$repo (PR no creado)"); }

  print_success "PR: $PR_URL"
  MIGRATED_REPOS+=("$repo → $PR_URL")
done

# ─── Resumen ─────────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  📊 RESUMEN"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

echo "  ✅ PRs creados (${#MIGRATED_REPOS[@]}):"
for r in "${MIGRATED_REPOS[@]}"; do echo "     - $r"; done

if [ ${#SKIPPED_REPOS[@]} -gt 0 ]; then
  echo ""
  echo "  ⏭️  Omitidos — PR ya existía (${#SKIPPED_REPOS[@]}):"
  for r in "${SKIPPED_REPOS[@]}"; do echo "     - $r"; done
fi

if [ ${#WARN_REPOS[@]} -gt 0 ]; then
  echo ""
  echo "  ⚠️  Repos con commits en develop sin mergear (${#WARN_REPOS[@]}):"
  for r in "${WARN_REPOS[@]}"; do echo "     - $r"; done
  echo ""
  echo "  → Revisa esos commits ANTES de mergear los PRs y eliminar develop"
fi

if [ ${#FAILED_REPOS[@]} -gt 0 ]; then
  echo ""
  echo "  ❌ Fallidos (${#FAILED_REPOS[@]}):"
  for r in "${FAILED_REPOS[@]}"; do echo "     - $r"; done
fi

echo ""
[ "$DRY_RUN" = true ] && echo "  ⚠️  Esto fue un DRY RUN — ejecuta sin --dry-run para aplicar"
