# Organization CI/CD Tools

> Centralized reusable workflows for the entire ArkeonProject organization

## 🎯 Purpose

This repository contains all the workflows, templates, composite actions, and scripts necessary to implement consistent CI/CD across the organization.

## 🏗️ Infrastructure ("Zero-Waste" Architecture)

This organization uses a **Self-Hosted Runner** optimized for Intel N100 hardware to minimize resource usage ("Zero-Waste").

- **Runner Tag**: `[self-hosted, n100]`
- **Docker Strategy**: Docker-out-of-Docker (DooD) via `/var/run/docker.sock`
- **Resource Limits**: 3GB RAM Soft Limit (enforced via Portainer Stack)
- **Documentation**: See [contracts/infrastructure/portainer/runner-stack.yml](docs/infrastructure/portainer/runner-stack.yml) for setup.

## 📦 Contents

### Reusable Workflows (`.github/workflows/`)
- `reusable-deploy.yml` - **[NEW]** Universal deploy with fail-safe testing (Hurl/Playwright)
- `reusable-docker-build.yml` - **[NEW]** Unified Docker build & push (Production/Milestone modes)
- `check-runner.yml` - **[NEW]** Diagnostic tool for self-hosted runner health
- `ci-node.yml` - CI for Node.js projects (supports pnpm, npm, yarn, bun)
- `ci-python.yml` - CI for Python projects
- `cd-node-vercel.yml` - Deploy Node.js to Vercel
- `cd-python-docker.yml` - (Legacy) Build and push Docker images for Python
- `release-prepare.yml` - Prepare releases
- `release-publish.yml` - Publish releases
- `hotfix-create.yml` - Create hotfixes

### Templates (`.github/workflows/templates/`)
Ready-to-copy templates for new repositories:
- `cd-production.template.yml` - **[NEW]** Production CD using Docker
- `cd-test.template.yml` - **[NEW]** Test CD with automatic milestone tagging
- `node-ci.template.yml` - Node.js CI template
- `node-cd.template.yml` - Node.js CD template
- `python-ci.template.yml` - Python CI template
- `python-cd.template.yml` - Python CD template
- `release.template.yml` - Release workflow template
- `hotfix.template.yml` - Hotfix workflow template
- `dependabot.template.yml` - Dependabot configuration

### Composite Actions (`.github/actions/`)
- `setup-node-pnpm/` - Setup Node.js with pnpm
- `setup-python/` - Setup Python with pip/poetry
- `setup-bun/` - Setup Bun runtime
- `setup-docker/` - Setup Docker buildx with multi-platform support

### Scripts (`scripts/`)
- `setup-repo.sh` - Automated repository setup
- `validate-workflows.sh` - Validate workflow YAML files

## 🚀 Quick Start

### New Node.js Repository

```bash
./scripts/setup-repo.sh my-frontend-app node
```

### New Python Repository

```bash
./scripts/setup-repo.sh my-backend-api python
```

### Dry Run (Preview Changes)

```bash
./scripts/setup-repo.sh my-app node --dry-run
```

### Interactive Mode

```bash
./scripts/setup-repo.sh my-app node --interactive
```

### Validate Prerequisites

```bash
./scripts/setup-repo.sh --validate
```

## 🔧 Required Secrets

### For Node.js + Vercel Projects:
- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

### For Python + Docker Projects:
- `GITHUB_TOKEN` (automatic for GHCR)
- `DOCKERHUB_USERNAME` (optional)
- `DOCKERHUB_TOKEN` (optional)

## 🌿 Branching Model (Trunk-Based Development)

```
main (production + integration)
  ├── feature/* → PR → main
  ├── bugfix/*  → PR → main
  ├── release/vX.X.X → PR → main (auto-created by workflow)
  └── hotfix/vX.X.X  → PR → main (auto-created by workflow)
```

**Golden Rule:** Features merge directly to `main` via PRs. Releases use tags (`v*.*.*`) on main. Never push directly to `main`.

## 📖 Usage

### Creating a Release

Via GitHub UI:
1. Go to Actions → Release → Run workflow
2. Select version bump (patch/minor/major)
3. Workflow creates release/* branch automatically
4. Merge PR to main
5. Automatically published

### Creating a Hotfix

Via GitHub UI:
1. Go to Actions → Hotfix → Run workflow
2. Describe the hotfix
3. Workflow creates hotfix/* branch automatically
4. Implement the fix
5. Merge PR to main
6. Automatically tagged and released

## 🔄 Updates

Workflows are updated centrally in this repository. All repos using them receive updates automatically.

## 🛠️ Development

### Validate Workflows

```bash
./scripts/validate-workflows.sh
```

### Test Setup Script

```bash
./scripts/setup-repo.sh test-repo node --dry-run
```

## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md) - System architecture and design
- [Developer Guide](docs/DEVELOPER_GUIDE.md) - Development workflows
- [Release Guide](docs/RELEASE_GUIDE.md) - How to create releases
- [Contributing](CONTRIBUTING.md) - Contribution guidelines

## ❓ FAQ

**Q: Can I push directly to main?**  
A: No. Always open a PR from `feature/*`, `bugfix/*`, `release/*`, or `hotfix/*`.

**Q: How do I rollback a release?**  
A: Create a hotfix with the necessary corrections.

**Q: Do workflows update automatically?**  
A: Yes, since they're centralized in organization-tools.

**Q: What if the setup script fails?**  
A: Run `./scripts/setup-repo.sh --validate` to check prerequisites.

**Q: Can I customize the workflows?**  
A: Yes, copy templates and modify them, or use workflow inputs to configure reusable workflows.

## 🐛 Troubleshooting

### GitHub CLI Not Authenticated
```bash
gh auth login
```

### Workflow Validation Errors
```bash
# Install required tools
pip install yamllint
brew install actionlint  # macOS

# Run validation
./scripts/validate-workflows.sh
```

### Setup Script Fails
```bash
# Check prerequisites
./scripts/setup-repo.sh --validate

# Preview what would happen
./scripts/setup-repo.sh my-app node --dry-run
```

## 📞 Support

- Issues: [GitHub Issues](../../issues)
- Team: @ArkeonProject/devops

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

---

**Maintainer:** @daviilpzDev  
**Organization:** ArkeonProject

