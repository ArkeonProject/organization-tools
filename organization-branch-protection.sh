#!/bin/bash
set -e

ORG="ArkeonProject"
USER="davilpzDev"

echo " Aplicando reglas correctas para main + develop en '$ORG'…"

REPOS=$(gh repo list "$ORG" --limit 200 --json name -q '.[].name')

for repo in $REPOS; do
  echo ""
  echo "========================================================================="
  echo " Procesando repositorio: $repo"
  echo "========================================================================="

  ###############################################
  # 1. Crear develop si no existe
  ###############################################
  if gh api "/repos/$ORG/$repo/branches/develop" >/dev/null 2>&1; then
    echo "develop existe"
  else
    echo "develop no existe — creándola desde main…"

    sha=$(gh api "/repos/$ORG/$repo/branches/main" -q '.commit.sha')

    gh api -X POST "/repos/$ORG/$repo/git/refs" \
      -f ref="refs/heads/develop" \
      -f sha="$sha"

    echo "develop creada"
  fi

  ###############################################
  # 2. Protección DEVELOP (sin checks, con force push)
  ###############################################
  echo "Protegiendo develop…"

  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/develop/protection" \
    -H "Accept: application/vnd.github+json" \
    -f "$(cat <<EOF
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0
  },
  "restrictions": {
    "users": ["$USER"],
    "teams": [],
    "apps": []
  },
  "required_linear_history": true,
  "allow_force_pushes": true,
  "allow_deletions": false
}
EOF
)"

  echo "✔ develop protegido correctamente."


  ###############################################
  # 3. Protección MAIN (full producción, sin force push)
  ###############################################
  echo "Protegiendo main…"

  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/main/protection" \
    -H "Accept: application/vnd.github+json" \
    -f "$(cat <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": []
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0
  },
  "required_conversation_resolution": true,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "restrictions": {
    "users": ["$USER"],
    "teams": [],
    "apps": []
  }
}
EOF
)"

  echo "main protegido correctamente."

done

echo ""
echo "Configuración de protección aplicada a TODOS los repos."
echo "develop ya NO quedará behind nunca más"
echo "main protegida como entorno productivo"
