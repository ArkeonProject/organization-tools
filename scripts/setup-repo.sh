#!/bin/bash
# scripts/setup-repo.sh
# Enhanced setup CI/CD for a new repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ORG_NAME="${ORG_NAME:-ArkeonProject}"
DRY_RUN=false
INTERACTIVE=false
VALIDATE_ONLY=false

# Functions
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }

show_usage() {
  cat << EOF
Usage: $0 <repo-name> <project-type> [options]

Arguments:
  repo-name       Name of the repository
  project-type    Type of project (node|python)

Options:
  --dry-run       Preview changes without applying them
  --interactive   Interactive mode for configuration
  --validate      Only validate prerequisites
  --org <name>    Organization name (default: ArkeonProject)
  -h, --help      Show this help message

Examples:
  $0 my-app node
  $0 my-api python --dry-run
  $0 my-app node --interactive
EOF
}

validate_prerequisites() {
  print_info "Validating prerequisites..."
  
  local missing_tools=()
  
  if ! command -v gh &> /dev/null; then
    missing_tools+=("gh (GitHub CLI)")
  fi
  
  if ! command -v git &> /dev/null; then
    missing_tools+=("git")
  fi
  
  if ! command -v curl &> /dev/null; then
    missing_tools+=("curl")
  fi
  
  if [ ${#missing_tools[@]} -gt 0 ]; then
    print_error "Missing required tools:"
    for tool in "${missing_tools[@]}"; do
      echo "  - $tool"
    done
    return 1
  fi
  
  # Check GitHub CLI authentication
  if ! gh auth status &> /dev/null; then
    print_error "GitHub CLI not authenticated. Run: gh auth login"
    return 1
  fi
  
  print_success "All prerequisites satisfied"
  return 0
}

execute_or_preview() {
  local cmd="$1"
  local description="$2"
  
  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] $description"
    echo "  Command: $cmd"
  else
    print_info "$description"
    eval "$cmd"
  fi
}

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --interactive)
      INTERACTIVE=true
      shift
      ;;
    --validate)
      VALIDATE_ONLY=true
      shift
      ;;
    --org)
      ORG_NAME="$2"
      shift 2
      ;;
    -h|--help)
      show_usage
      exit 0
      ;;
    -*|--*)
      print_error "Unknown option $1"
      show_usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

# Validate prerequisites first
if ! validate_prerequisites; then
  exit 1
fi

if [ "$VALIDATE_ONLY" = true ]; then
  print_success "Validation complete"
  exit 0
fi

# Get arguments
REPO_NAME=$1
PROJECT_TYPE=$2

if [ -z "$REPO_NAME" ] || [ -z "$PROJECT_TYPE" ]; then
  print_error "Missing required arguments"
  show_usage
  exit 1
fi

if [ "$PROJECT_TYPE" != "node" ] && [ "$PROJECT_TYPE" != "python" ]; then
  print_error "Invalid project type. Use 'node' or 'python'"
  exit 1
fi

# Interactive mode
if [ "$INTERACTIVE" = true ]; then
  print_info "Interactive configuration mode"
  
  read -p "Organization name [$ORG_NAME]: " input_org
  ORG_NAME="${input_org:-$ORG_NAME}"
  
  read -p "Repository name [$REPO_NAME]: " input_repo
  REPO_NAME="${input_repo:-$REPO_NAME}"
  
  read -p "Project type [$PROJECT_TYPE]: " input_type
  PROJECT_TYPE="${input_type:-$PROJECT_TYPE}"
  
  read -p "Enable Dependabot? [Y/n]: " enable_dependabot
  enable_dependabot="${enable_dependabot:-Y}"
fi

print_info "Setting up repository: $REPO_NAME ($PROJECT_TYPE)"
print_info "Organization: $ORG_NAME"

if [ "$DRY_RUN" = true ]; then
  print_warning "DRY RUN MODE - No changes will be made"
fi

# Clone or create repo
if [ ! -d "$REPO_NAME" ]; then
  execute_or_preview \
    "gh repo clone \"$ORG_NAME/$REPO_NAME\" || gh repo create \"$ORG_NAME/$REPO_NAME\" --private --clone" \
    "Cloning or creating repository"
  
  if [ "$DRY_RUN" = false ]; then
    cd "$REPO_NAME"
  fi
else
  if [ "$DRY_RUN" = false ]; then
    cd "$REPO_NAME"
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
  fi
fi

# Create branch structure
execute_or_preview \
  "git checkout -b develop 2>/dev/null || git checkout develop" \
  "Creating/switching to develop branch"

execute_or_preview \
  "git push origin develop 2>/dev/null || true" \
  "Pushing develop branch"

# Create workflows directory
execute_or_preview \
  "mkdir -p .github/workflows" \
  "Creating .github/workflows directory"

# Copy templates based on project type
print_info "Copying workflow templates..."

BASE_URL="https://raw.githubusercontent.com/$ORG_NAME/organization-tools/main/.github/workflows/templates"

if [ "$PROJECT_TYPE" == "node" ]; then
  execute_or_preview \
    "curl -s -o .github/workflows/ci.yml \"$BASE_URL/node-ci.template.yml\"" \
    "Copying Node.js CI template"
  
  execute_or_preview \
    "curl -s -o .github/workflows/cd.yml \"$BASE_URL/node-cd.template.yml\"" \
    "Copying Node.js CD template"
  
elif [ "$PROJECT_TYPE" == "python" ]; then
  execute_or_preview \
    "curl -s -o .github/workflows/ci.yml \"$BASE_URL/python-ci.template.yml\"" \
    "Copying Python CI template"
  
  execute_or_preview \
    "curl -s -o .github/workflows/cd.yml \"$BASE_URL/python-cd.template.yml\"" \
    "Copying Python CD template"
fi

# Common workflows
execute_or_preview \
  "curl -s -o .github/workflows/release.yml \"$BASE_URL/release.template.yml\"" \
  "Copying release workflow"

execute_or_preview \
  "curl -s -o .github/workflows/hotfix.yml \"$BASE_URL/hotfix.template.yml\"" \
  "Copying hotfix workflow"

if [ "$INTERACTIVE" = false ] || [ "$enable_dependabot" = "Y" ] || [ "$enable_dependabot" = "y" ]; then
  execute_or_preview \
    "curl -s -o .github/dependabot.yml \"$BASE_URL/dependabot.template.yml\"" \
    "Copying Dependabot configuration"
fi

# CODEOWNERS
if [ "$DRY_RUN" = false ]; then
  cat > .github/CODEOWNERS <<EOF
# Default owners for everything
* @$ORG_NAME/maintainers

# CI/CD and GitHub workflows
/.github/ @$ORG_NAME/devops

# Documentation
/docs/ @$ORG_NAME/maintainers
*.md @$ORG_NAME/maintainers
EOF
  print_success "Created CODEOWNERS file"
else
  print_info "[DRY RUN] Would create CODEOWNERS file"
fi

# Commit and push
execute_or_preview \
  "git add .github/" \
  "Staging .github directory"

execute_or_preview \
  "git commit -m \"chore(ci): setup CI/CD workflows\" || true" \
  "Committing changes"

execute_or_preview \
  "git push origin develop" \
  "Pushing to develop branch"

# Summary
echo ""
print_success "Repository setup complete!"
echo ""
print_info "📋 Next steps:"

if [ "$PROJECT_TYPE" == "node" ]; then
  echo "  1. Add GitHub secrets:"
  echo "     - VERCEL_TOKEN"
  echo "     - VERCEL_ORG_ID"
  echo "     - VERCEL_PROJECT_ID"
elif [ "$PROJECT_TYPE" == "python" ]; then
  echo "  1. Update image-name in .github/workflows/cd.yml"
  echo "  2. Add GitHub secrets (optional):"
  echo "     - DOCKERHUB_USERNAME"
  echo "     - DOCKERHUB_TOKEN"
fi

echo "  2. Setup branch protection:"
echo "     - main: 2 approvals required"
echo "     - develop: 1 approval required"
echo "  3. Test CI with a PR to develop"
echo ""

if [ "$DRY_RUN" = true ]; then
  print_warning "This was a DRY RUN - no changes were made"
  print_info "Run without --dry-run to apply changes"
fi

