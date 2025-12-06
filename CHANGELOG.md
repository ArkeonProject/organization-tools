# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[Unreleased]: https://github.com/ArkeonProject/organization-tools/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ArkeonProject/organization-tools/releases/tag/v1.0.0
