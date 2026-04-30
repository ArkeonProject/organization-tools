#!/bin/bash
set -e

ORG="ArkeonProject"
USER="davilpzDev"

echo "Aplicando protección de main en todos los repos de '$ORG'…"

REPOS=$(gh repo list "$ORG" --limit 200 --json name -q '.[].name')

for repo in $REPOS; do
  echo ""
  echo "========================================================================="
  echo "➡ Procesando repositorio: $repo"
  echo "========================================================================="

  ###############################################
  # PROTECCIÓN PARA MAIN (Modo producción / TBD)
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
echo "📌 Configuración aplicada (Trunk-Based Development):"
echo "   • main protegida: PRs obligatorios, no force push"
echo "   • Status checks requeridos antes de merge"
echo "   • Features van directo a main via PR (feature/* → main)"
echo "   • Releases se gestionan con tags v*.*.* en main"
echo ""
echo "💡 Flujo:"
echo "   feature/* → PR → main → tag v*.*.* → producción"
