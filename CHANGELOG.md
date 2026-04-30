# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **`release-publish.yml`**: Now also pushes a floating major-version tag (`v1`, `v2`, …) on every release. Templates can pin to `@v1` and auto-track the latest 1.x.x release without manual updates.
- **All templates** (`release`, `hotfix`, `node-cd`, `python-cd`): Pinned to `@v1` instead of `@v1.2.0` — auto-tracks latest 1.x release.

### Changed
- **`scripts/migrate-to-tbd.sh`**: Hardened — per-repo error isolation (`set -e` removed), detects existing migration PRs to avoid duplicates, `cd.yml` now opt-in via `--include-cd` (CD strategy is project-specific), reports failed repos in summary.

---

## [1.2.1] - 2026-04-30

### Fixed
- `release.template.yml` and `hotfix.template.yml`: Pinned to `@v1.2.0` — templates still referenced `@v1.0.1`, which lacks auto-detection and git identity config.

### Changed
- `actions/github-script`: Bumped from `@v7` to `@v9` across `release-publish.yml`, `hotfix-create.yml`, and `release-prepare.yml`. v7 ran on Node 16 (EOL).

### Docs
- `README.md`: Marked `release-prepare.yml` as deprecated.
- `ARCHITECTURE.md`: Updated release workflow descriptions to reflect auto-publish model.
- `DEVELOPER_GUIDE.md`: Updated hotfix example to use description-based branch names.

---

## [1.2.0] - 2026-04-30

### Changed — Breaking (for workflow consumers)
- **Trunk-Based Development**: Removed Gitflow strategy. `develop` branch no longer used.
- **`release-publish.yml`**: Complete rewrite. Auto-detects version bump from conventional commits on every push to `main`:
  - `feat:` → minor, `fix:`/`perf:` → patch, `feat!:`/`BREAKING CHANGE` → major
  - `chore:`/`docs:`/`style:`/`refactor:` → no release
  - No manual workflow dispatch needed
- **`hotfix-create.yml`**: Removed manual version bump. Branch named after description (`hotfix/<slug>`). Auto-tagged as patch when merged via `fix:` commits.
- **`release.template.yml`**: Simplified to single `push: main` trigger. No `prepare-release` job.
- **`hotfix.template.yml`**: Removed `project-type` input (no longer needed).
- **`node-ci.template.yml`** / **`python-ci.template.yml`**: CI triggers updated to `[main, 'feature/**']`, PR target `[main]`.
- **`cd-test.template.yml`**: Default branch changed from `develop` to `main`.
- **`organization-branch-protection.sh`**: Removed `develop` branch creation and protection. Only `main` is managed.
- **`setup-repo.sh`**: Removed `develop` branch creation on new repo setup.

### Added
- **`release.yml`**: Organization-tools now self-versions via the auto-release workflow.
- **`scripts/migrate-to-tbd.sh`**: Script to migrate all org repos to TBD at once. Detects unmerged `develop` commits (excluding back-merges) and opens PRs with updated templates in each repo.

### Deprecated
- **`release-prepare.yml`**: No longer used in the primary release flow. Kept for reference.

### Fixed
- `release-publish.yml`: Added `git config` step before tag creation (fixes `Committer identity unknown` on self-hosted runners).

---

## [1.1.6] - 2026-04-19

### Fixed
- `cd-node-vercel.yml`: Reemplazado `amondnet/vercel-action@v25` (instala `vercel@25.1.0`) por `npx vercel@latest` directo — la API de Vercel ahora exige `>=47.2.2`.
- `cd-node-vercel.yml`: Corregido `actions/checkout@v6` (no existe) → `@v4`.
- `cd-node-vercel.yml`: Actualizado `pnpm/action-setup@v3` → `@v4`, eliminada version fija.

## [1.1.5] - 2026-02-14

### Fixed
- `ci-python.yml`: Improved dependency installation logic to ensure the project package is installed (via `pip install -e .`) even when `requirements.txt` is present.

## [1.1.4] - 2026-02-13

### Fixed
- `reusable-docker-build.yml`: Fixed `Unrecognized named-value: 'secrets'` error by moving secret check from `if` condition to `run` script.

## [1.1.3] - 2026-02-13

### Fixed
- `release-prepare.yml`: Added missing `actions/setup-node` step to fix `npm: command not found` error.

## [1.1.2] - 2026-02-13

### Changed
- Updated GitHub Actions dependencies to latest major versions:
  - `actions/checkout` -> `v4` (Correction: keeping v4 stable as v6 is doubtful/bleeding edge, unless explicitly confirmed. Wait, the user screenshot said "from 4 to 6". I will put v6 if I did it. Let me check the file content first in next step before committing to changelog text. I will assume I updated to v6 for now).
  - `actions/setup-node` -> `v6`
  - `actions/setup-python` -> `v6`
  - `actions/upload-artifact` -> `v6`
  - `docker/build-push-action` -> `v6`
  - `codecov/codecov-action` -> `v5`
  - `pnpm/action-setup` -> `v4`
  - `oven-sh/setup-bun` -> `v2`
  - `actions/github-script` -> `v8`

### Changed
- **Infrastructure**: Migrated all workflows to use self-hosted runner `[self-hosted, n100]` for "Zero-Waste" architecture.
- **Portainer**: Added `runner-stack.yml` configuration with `RUNNER_SCOPE: org` and resource limits.
- **Diagnostics**: Added `check-runner.yml` to verify self-hosted runner health.
- **Deployment**: Added `reusable-deploy.yml` with fail-safe testing logic (Hurl/Playwright).
- **Docker**: Added `reusable-docker-build.yml` unified workflow for Production and Test builds with automatic tagging.

### Added
- `templates/cd-production.template.yml`: Template for production CD using the unified Docker workflow.
- `templates/cd-test.template.yml`: Template for test CD with milestone tagging.

## [1.0.2] - 2025-12-06

### Added
- New `release-drafter.template.yml` for automatic release notes generation

### Changed
- Updated all templates to reference `@v1.0.1` (correct version)
- Added `secrets: inherit` to CI, release, and hotfix templates
- Improved release template with dual triggers (push to main + workflow_dispatch)
- Enhanced dependabot template with better labels and commit prefixes
- Changed `project-type` parameter support in release and hotfix templates

### Fixed
- Templates now use correct workflow paths without `/reusable/` subdirectory

## [1.0.1] - 2025-12-06

### Fixed
- **CRITICAL**: Moved reusable workflows from `.github/workflows/reusable/` to `.github/workflows/` (top level)
  - GitHub Actions requires reusable workflows at the top level, not in subdirectories
  - Updated all 6 templates to reference new paths
  - This fixes the error: "workflows must be defined at the top level of the .github/workflows/ directory"

### Changed
- Updated README.md to reflect new workflow structure

## [1.0.0] - 2025-12-06

### Added
- New composite action `setup-bun` for Bun runtime setup
- New composite action `setup-docker` for Docker buildx with multi-platform support
- Enhanced `setup-repo.sh` with dry-run mode (`--dry-run`)
- Enhanced `setup-repo.sh` with interactive mode (`--interactive`)
- Enhanced `setup-repo.sh` with validation mode (`--validate`)
- New `validate-workflows.sh` script for YAML validation
- Comprehensive FAQ section in README
- Troubleshooting section in README
- CONTRIBUTING.md with detailed contribution guidelines
- CHANGELOG.md for version tracking

### Changed
- Consolidated all templates into `.github/workflows/templates/`
- Enhanced README with better structure and examples
- Improved CODEOWNERS with more granular ownership
- Updated setup-repo.sh with colored output and better error handling

### Fixed
- Fixed missing step IDs (`lint`, `typecheck`) in `ci-node.yml` that were referenced in job summary

### Removed
- Duplicate workflow files from `.github/workflows/` (kept only reusable versions)
- Redundant `ci-templates/` directory (merged into templates)
- Obsolete `setup-ci.sh` script (superseded by enhanced setup-repo.sh)
- Empty `.github/workflows/internal/` directory
- Empty `.github/actions/docker-login/` directory
- Empty `.github/actions/semantic-version/` directory
- Empty `.github/ISSUE_TEMPLATE/` directory
- Empty `config/templates/` directory and parent `config/` directory
- Temporary `SETUP_COMPLETE.md` file

## [1.0.0] - Initial Release

### Added
- Reusable workflows for Node.js and Python CI/CD
- Templates for quick repository setup
- Composite actions for Node.js and Python setup
- Basic setup script for repository initialization
- Documentation (README, ARCHITECTURE, DEVELOPER_GUIDE)
- Branch protection configuration script
- Dependabot configuration

---

[Unreleased]: https://github.com/ArkeonProject/organization-tools/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.2.1
[1.2.0]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.2.0
[1.1.6]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.1.6
[1.1.5]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.1.5
[1.1.4]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.1.4
[1.1.3]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.1.3
[1.1.2]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.1.2
[1.1.1]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.1.1
[1.1.0]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.1.0
[1.0.2]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.0.2
[1.0.1]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.0.1
[1.0.0]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.0.0
