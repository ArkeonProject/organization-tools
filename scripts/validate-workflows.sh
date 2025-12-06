#!/bin/bash
# scripts/validate-workflows.sh
# Validate all GitHub Actions workflow files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

print_info "Validating workflows in: $REPO_ROOT"

# Check for required tools
check_tools() {
  local missing_tools=()
  
  if ! command -v yamllint &> /dev/null; then
    missing_tools+=("yamllint (install: pip install yamllint)")
  fi
  
  if ! command -v actionlint &> /dev/null; then
    print_warning "actionlint not found (optional but recommended)"
    print_info "Install: brew install actionlint (macOS) or see https://github.com/rhysd/actionlint"
  fi
  
  if [ ${#missing_tools[@]} -gt 0 ]; then
    print_error "Missing required tools:"
    for tool in "${missing_tools[@]}"; do
      echo "  - $tool"
    done
    return 1
  fi
  
  return 0
}

# Validate YAML syntax
validate_yaml_syntax() {
  local file="$1"
  local filename=$(basename "$file")
  
  if yamllint -d "{extends: default, rules: {line-length: {max: 120}, document-start: disable}}" "$file" &> /dev/null; then
    print_success "YAML syntax valid: $filename"
    return 0
  else
    print_error "YAML syntax error: $filename"
    yamllint -d "{extends: default, rules: {line-length: {max: 120}, document-start: disable}}" "$file"
    return 1
  fi
}

# Validate with actionlint
validate_with_actionlint() {
  local file="$1"
  local filename=$(basename "$file")
  
  if ! command -v actionlint &> /dev/null; then
    return 0
  fi
  
  if actionlint "$file" &> /dev/null; then
    print_success "Action lint passed: $filename"
    return 0
  else
    print_error "Action lint failed: $filename"
    actionlint "$file"
    return 1
  fi
}

# Check for common issues
check_common_issues() {
  local file="$1"
  local filename=$(basename "$file")
  local issues=()
  
  # Check for hardcoded secrets
  if grep -q "ghp_\|gho_\|github_pat_" "$file" 2>/dev/null; then
    issues+=("Possible hardcoded GitHub token detected")
  fi
  
  # Check for missing workflow_call trigger in reusable workflows
  if [[ "$file" == *"/reusable/"* ]]; then
    if ! grep -q "workflow_call:" "$file"; then
      issues+=("Reusable workflow missing 'workflow_call' trigger")
    fi
  fi
  
  # Check for deprecated actions
  if grep -q "actions/checkout@v[12]" "$file"; then
    issues+=("Using deprecated checkout action version (use @v4)")
  fi
  
  if grep -q "actions/setup-node@v[123]" "$file"; then
    issues+=("Using deprecated setup-node action version (use @v4)")
  fi
  
  if [ ${#issues[@]} -gt 0 ]; then
    print_warning "Potential issues in $filename:"
    for issue in "${issues[@]}"; do
      echo "  - $issue"
    done
    return 1
  fi
  
  return 0
}

# Main validation
main() {
  if ! check_tools; then
    exit 1
  fi
  
  local total_files=0
  local passed_files=0
  local failed_files=0
  
  print_info "Scanning for workflow files..."
  
  # Find all workflow YAML files
  while IFS= read -r -d '' file; do
    ((total_files++))
    
    echo ""
    print_info "Validating: $(basename "$file")"
    
    local file_passed=true
    
    # Run validations
    if ! validate_yaml_syntax "$file"; then
      file_passed=false
    fi
    
    if ! validate_with_actionlint "$file"; then
      file_passed=false
    fi
    
    check_common_issues "$file" || true  # Don't fail on warnings
    
    if [ "$file_passed" = true ]; then
      ((passed_files++))
    else
      ((failed_files++))
    fi
    
  done < <(find "$REPO_ROOT/.github/workflows" -name "*.yml" -o -name "*.yaml" -print0 2>/dev/null)
  
  # Also check composite actions
  while IFS= read -r -d '' file; do
    ((total_files++))
    
    echo ""
    print_info "Validating: $(basename "$(dirname "$file")")/$(basename "$file")"
    
    local file_passed=true
    
    if ! validate_yaml_syntax "$file"; then
      file_passed=false
    fi
    
    if [ "$file_passed" = true ]; then
      ((passed_files++))
    else
      ((failed_files++))
    fi
    
  done < <(find "$REPO_ROOT/.github/actions" -name "action.yml" -o -name "action.yaml" -print0 2>/dev/null)
  
  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_info "Validation Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Total files:  $total_files"
  echo "Passed:       $passed_files"
  echo "Failed:       $failed_files"
  echo ""
  
  if [ $failed_files -eq 0 ]; then
    print_success "All workflow files are valid!"
    exit 0
  else
    print_error "Some workflow files have errors"
    exit 1
  fi
}

main "$@"
