#!/bin/bash
set -e

ORG="ArkeonProject"
USER="davilpzDev"

echo "Aplicando reglas correctas para main + develop en '$ORG'…"

REPOS=$(gh repo list "$ORG" --limit 200 --json name -q '.[].name')

for repo in $REPOS; do
  echo ""
  echo "========================================================================="
  echo "➡ Procesando repositorio: $repo"
  echo "========================================================================="

  ###############################################
  # 1. CREAR DEVELOP SI NO EXISTE
  ###############################################

  if gh api "/repos/$ORG/$repo/branches/develop" >/dev/null 2>&1; then
    echo "develop existe"
  else
    echo "develop no existe — creándola desde main…"

    sha=$(gh api "/repos/$ORG/$repo/branches/main" -q '.commit.sha')

    gh api -X POST "/repos/$ORG/$repo/git/refs" \
      -f ref="refs/heads/develop" \
      -f sha="$sha"

    echo "✔ develop creada"
  fi

  ###############################################
  # 2. PROTECCIÓN PARA DEVELOP
  #    (allow force pushes = true, pero restricciones
  #     hacen que SOLO tú puedas hacer push)
  ###############################################

  echo "Protegiendo develop…"

  DEVELOP_JSON=$(cat <<EOF
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
  "required_linear_history": false,
  "allow_force_pushes": true,
  "allow_deletions": false
}
EOF
)

  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/develop/protection" \
    -H "Accept: application/vnd.github+json" \
    --input <(echo "$DEVELOP_JSON")

  echo "develop protegido correctamente."
  echo "Force push permitido SOLO porque nadie más puede pushear."


  ###############################################
  # 3. PROTECCIÓN PARA MAIN (Modo producción)
  ###############################################

  echo "Protegiendo main…"

  MAIN_JSON=$(cat <<EOF
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
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "restrictions": {
    "users": ["$USER"],
    "teams": [],
    "apps": []
  }
}
EOF
)

  gh api \
    -X PUT \
    "/repos/$ORG/$repo/branches/main/protection" \
    -H "Accept: application/vnd.github+json" \
    --input <(echo "$MAIN_JSON")

  echo "main protegido correctamente."

done

echo ""
echo "========================================================================="
echo "✅ Configuración aplicada en TODOS los repos."
echo "========================================================================="
echo ""
echo "📌 Configuración aplicada:"
echo "   • Linear history: DESACTIVADO en ambas ramas"
echo "   • Permite merge commits y auto-back-merge automático"
echo "   • develop permite force push pero SOLO tú puedes push"
echo "   • main protegida como entorno productivo"
echo ""
echo "💡 Beneficios:"
echo "   • Historial completo de features preservado"
echo "   • Auto-back-merge funciona correctamente"
echo "   • develop NUNCA quedará behind después de un release"
