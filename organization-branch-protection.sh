#!/bin/bash
set -e

###############################################
#  ArkeonProject — Unified Branch Protection
#  Applies PRO rules for `main` and DEV rules
#  for `develop` across all repositories.
###############################################

ORG="ArkeonProject"
USER="davilpzDev"

echo "🚀 Aplicando reglas de protección para main + develop en todos los repositorios de '$ORG'…"

###############################################
#  LISTA DE REPOS
###############################################
REPOS=$(gh repo list "$ORG" --limit 200 --json name -q '.[].name')

for repo in $REPOS; do
  echo ""
  echo "========================================================================="
  echo "➡ Procesando repositorio: $repo"
  echo "========================================================================="

  ###############################################
  # 1️⃣ Asegurar que develop existe
  ###############################################
  if gh api "/repos/$ORG/$repo/branches/develop" >/dev/null 2>&1; then
    echo "✔ develop ya existe"
  else
    echo "⚠ develop no existe — Creándola desde main…"
    gh api \
      -X POST \
      "/repos/$ORG/$repo/git/refs" \
      -H "Accept: application/vnd.github+json" \
      -f ref="refs/heads/develop" \
      -f sha=$(gh api "/repos/$ORG/$repo/branches/main" -q '.commit.sha')
    echo "✔ develop creada"
  fi

  ###############################################
  # 2️⃣ PROTECCIÓN PARA DEVELOP
  ###############################################
  echo "🔧 Aplicando protección para DEVELOP en $repo…"

  # Protección base
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/develop/protection" \
    -H "Accept: application/vnd.github+json" \
    -F required_pull_request_reviews="" \
    -F enforce_admins=false \
    -F required_linear_history=true \
    -F allow_force_pushes=true \
    -F allow_deletions=false \
    >/dev/null

  # PR rules
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/develop/protection/required_pull_request_reviews" \
    -H "Accept: application/vnd.github+json" \
    -F dismiss_stale_reviews=false \
    -F require_code_owner_reviews=false \
    -F required_approving_review_count=0 \
    >/dev/null

  # DELETE status checks (clave para no quedar behind)
  gh api -X DELETE \
    "/repos/$ORG/$repo/branches/develop/protection/required_status_checks" \
    -H "Accept: application/vnd.github+json" \
    >/dev/null || true

  # Restricciones de push
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/develop/protection/restrictions" \
    -H "Accept: application/vnd.github+json" \
    -F users[]="$USER" \
    >/dev/null

  # Allow force push solo tú
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/develop/protection/allow_force_pushes" \
    -H "Accept: application/vnd.github+json" \
    -F users[]="$USER" \
    >/dev/null

  echo "✔ DEVELOP protegido correctamente."


  ###############################################
  # 3️⃣ PROTECCIÓN PARA MAIN
  ###############################################
  echo "🔒 Aplicando protección para MAIN en $repo…"

  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/main/protection" \
    -H "Accept: application/vnd.github+json" \
    -F required_pull_request_reviews="" \
    -F required_status_checks.strict=true \
    -F required_status_checks.contexts[]="" \
    -F enforce_admins=true \
    -F required_linear_history=true \
    -F allow_force_pushes=false \
    -F allow_deletions=false \
    >/dev/null

  # PR rules
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/main/protection/required_pull_request_reviews" \
    -H "Accept: application/vnd.github+json" \
    -F dismiss_stale_reviews=false \
    -F require_code_owner_reviews=false \
    -F required_approving_review_count=0

  # Conversación obligatoria
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/main/protection/required_conversation_resolution" \
    -H "Accept: application/vnd.github+json" \
    -F enabled=true

  # Requerir deployments
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/main/protection/required_deployments" \
    -H "Accept: application/vnd.github+json" \
    -F required_deployment_environments[]="Preview"

  # Push restringido
  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/main/protection/restrictions" \
    -H "Accept: application/vnd.github+json" \
    -F users[]="$USER"

  echo "✔ MAIN protegido correctamente."
done

echo ""
echo "🎉 FIN DEL PROCESO"
echo "✔ Todas las protecciones aplicadas"
echo "✔ develop nunca volverá a quedar behind"
echo "✔ main está configurada como producción real"
echo ""
