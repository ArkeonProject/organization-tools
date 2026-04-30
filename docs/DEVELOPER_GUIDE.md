# Developer Guide

## Daily Workflow

### 1. Working on a Feature

```bash
# Start from main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/my-awesome-feature

# Make changes
# ... code, code, code ...

# Commit using conventional commits
git add .
git commit -m "feat: add awesome new feature"

# Push and create PR
git push origin feature/my-awesome-feature
gh pr create --base main --title "feat: add awesome new feature"
```

### 2. Creating a Release

**Automatic (default)**:

Releases are generated automatically by `release-publish.yml` on every push to `main`.

| Commit type | Result |
|---|---|
| `feat:` | minor bump (e.g. `v1.0.0` → `v1.1.0`) |
| `fix:` / `perf:` | patch bump (e.g. `v1.0.0` → `v1.0.1`) |
| `feat!:` / `BREAKING CHANGE` | major bump (e.g. `v1.0.0` → `v2.0.0`) |
| `chore:` / `docs:` / `style:` / `refactor:` | no release |

Just merge your PR to `main` — the workflow does the rest.

**Manual fallback** (if auto-release fails):

```bash
# From main
git checkout main
git pull origin main

# Create tag directly
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3

# Create GitHub Release manually
gh release create v1.2.3 --title "v1.2.3" --generate-notes
```

### 3. Creating a Hotfix

**Via GitHub UI**:

1. Go to **Actions** tab
2. Select **Hotfix** workflow
3. Click **Run workflow**
4. Enter hotfix description
5. Click **Run workflow**

This creates a `hotfix/<slug>` branch from `main` (e.g. `hotfix/fix-auth-token`).

**Then**:

```bash
# Checkout the created hotfix branch
git fetch origin
git checkout hotfix/fix-authentication-bug

# Implement the fix using fix: commits
git add .
git commit -m "fix: critical bug in authentication"

# Push
git push origin hotfix/fix-authentication-bug
```

After merge to `main`:
- `release-publish.yml` detects the `fix:` commit and tags a **patch release** automatically (e.g. `v1.2.1`).

## Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style (formatting, missing semicolons, etc.)
- `refactor:` - Code refactoring
- `perf:` - Performance improvement
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes
- `build:` - Build system changes

### Examples

```bash
feat: add user authentication
feat(api): add endpoint for user profile
fix: resolve memory leak in data processing
fix(ui): correct button alignment on mobile
docs: update installation instructions
chore(deps): update dependencies
ci: add workflow for automated testing
```

### Breaking Changes

```bash
feat!: redesign API authentication

BREAKING CHANGE: API now requires OAuth2 instead of API keys
```

## Branch Naming

```
feature/short-description      # New features
bugfix/short-description       # Bug fixes
hotfix/<slug>                  # Emergency fixes (auto-created)
```

> `release/vX.X.X` branches no longer exist — releases are auto-tagged on `main`.

Examples:
```
feature/user-dashboard
feature/add-payment-integration
bugfix/fix-login-redirect
bugfix/resolve-memory-leak
hotfix/fix-auth-token
hotfix/critical-memory-leak
```

## Testing Your Changes

### Before Committing

```bash
# Run linter
pnpm run lint  # or: poetry run ruff check

# Run type checker
pnpm run typecheck  # or: poetry run mypy .

# Run tests
pnpm run test  # or: poetry run pytest

# Run build
pnpm run build  # or: poetry run python -m build
```

### Testing Workflows

1. **Create a test repository**
   ```bash
   gh repo create ArkeonProject/test-workflow --private
   ```

2. **Apply your workflow changes**
   ```bash
   # Copy modified workflow
    cp .github/workflows/ci-node.yml ../test-workflow/.github/workflows/
   ```

3. **Test in the test repo**
   ```bash
   cd ../test-workflow
   git add .
   git commit -m "test: workflow changes"
   git push
   ```

4. **Check Actions tab** in GitHub UI

### Validating Workflows

```bash
# Validate all workflows
./scripts/validate-workflows.sh

# Install validation tools if needed
pip install yamllint
brew install actionlint  # macOS
```

## Resolving Merge Conflicts

### Conflict in Feature Branch

```bash
# Update your feature branch from main
git checkout feature/my-feature
git fetch origin
git rebase origin/main

# Resolve conflicts
# Edit conflicting files
# Look for <<<<<<< HEAD markers
git add .
git rebase --continue

git push origin feature/my-feature --force-with-lease
```

### Conflict in Release Branch

```bash
# Update your release branch from main
git checkout release/v1.2.0
git fetch origin
git merge origin/main

# Resolve conflicts
# ... resolve ...

git add .
git commit -m "chore: resolve conflicts with main"
git push origin release/v1.2.0
```

## Debugging Workflows

### View Workflow Logs

1. Go to **Actions** tab in GitHub
2. Click on the failed workflow run
3. Click on the failed job
4. Expand failed steps to see logs

### Common Issues

**Issue**: `pnpm: command not found`
```yaml
# Solution: Ensure pnpm is installed
- name: Install pnpm
  run: npm install -g pnpm@10 --force
```

**Issue**: `Cache not found`
```yaml
# Solution: Check cache key and paths
- uses: actions/cache@v4
  with:
    path: ~/.pnpm-store
    key: ${{ runner.os }}-pnpm-${{ hashFiles('**/pnpm-lock.yaml') }}
```

**Issue**: Workflow not triggering
```yaml
# Check trigger configuration
on:
  push:
    branches: [main, 'feature/**']  # Trunk-Based Development
  pull_request:
    branches: [main]
```

### Testing Locally with Act

```bash
# Install act
brew install act  # macOS

# Run workflow locally
act -j ci  # Run 'ci' job

# With secrets
act -j ci --secret-file .secrets
```

## Repository Setup

### Setting Up a New Project

```bash
# Using the setup script
./scripts/setup-repo.sh my-new-project node

# With options
./scripts/setup-repo.sh my-new-project python --dry-run
./scripts/setup-repo.sh my-new-project node --interactive
```

### Manual Setup

1. **Create repository**
   ```bash
   gh repo create ArkeonProject/my-project --private
   cd my-project
   ```

2. **Copy templates**
   ```bash
   mkdir -p .github/workflows
   
   # For Node.js
   curl -o .github/workflows/ci.yml \
     https://raw.githubusercontent.com/ArkeonProject/organization-tools/main/.github/workflows/templates/node-ci.template.yml
   ```

3. **Configure secrets** (GitHub UI)
   - Settings → Secrets and variables → Actions
   - Add required secrets

4. **Set up branch protection** (GitHub UI)
   - Settings → Branches → Add rule
   - Configure as per [ARCHITECTURE.md](ARCHITECTURE.md#security)

## Best Practices

### Workflow Development

1. **Start small**: Test with minimal workflow first
2. **Use dry-run**: Test scripts with `--dry-run` flag
3. **Validate early**: Run `validate-workflows.sh` before committing
4. **Test in sandbox**: Use a test repository for validation
5. **Document changes**: Update CHANGELOG.md

### Code Quality

1. **Lint before commit**: Run linters locally
2. **Write tests**: Add tests for new features
3. **Keep PRs focused**: One feature/fix per PR
4. **Review your own PR**: Check the diff before requesting review
5. **Respond to feedback**: Address review comments promptly

### Security

1. **Never commit secrets**: Use GitHub Secrets
2. **Review dependencies**: Check Dependabot PRs
3. **Pin action versions**: Use `@v4` not `@latest`
4. **Minimal permissions**: Request only needed permissions
5. **Validate inputs**: Check user inputs in workflows

## Frequently Asked Questions

**Q: Can I push directly to main?**  
A: No. Always open a PR from `feature/*`, `bugfix/*`, `release/*`, or `hotfix/*`.

**Q: How do I update a workflow for all repos?**  
A: Update it in organization-tools. All repos using it will automatically get the update.

**Q: Can I test workflows locally?**  
A: Yes, use [act](https://github.com/nektos/act) to run workflows locally.

**Q: What if CI fails on my PR?**  
A: Check the logs, fix the issue, commit, and push. CI will re-run automatically.

**Q: How do I rollback a bad release?**  
A: Create a hotfix with the fix or revert commit.

**Q: Can I customize the reusable workflows?**  
A: Yes, use workflow inputs to configure behavior, or copy and modify templates.

## Getting Help

- **Questions**: Open a [Discussion](../../discussions)
- **Bugs**: Open an [Issue](../../issues)
- **Urgent**: Contact @ArkeonProject/devops on Slack

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)

---

**Last Updated**: 2026-04-30  
**Maintainer**: @daviilpzDev

