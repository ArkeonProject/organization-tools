# Contributing to Organization CI/CD Tools

Thank you for your interest in contributing! This document provides guidelines for contributing to the organization-tools repository.

## 🎯 Contribution Workflow

### 1. Fork and Clone

```bash
gh repo fork ArkeonProject/organization-tools --clone
cd organization-tools
```

### 2. Create a Feature Branch

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### 3. Make Your Changes

Follow the guidelines below for different types of contributions.

### 4. Test Your Changes

```bash
# Validate workflow syntax
./scripts/validate-workflows.sh

# Test setup script
./scripts/setup-repo.sh test-repo node --dry-run
```

### 5. Commit Your Changes

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git add .
git commit -m "feat: add new composite action for X"
```

Commit types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Test additions or changes
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes

### 6. Push and Create PR

```bash
git push origin feature/your-feature-name
gh pr create --base develop --title "feat: your feature description"
```

## 📝 Guidelines

### Workflow Files

- Use descriptive names with emojis for steps
- Include comprehensive inputs with descriptions
- Provide sensible defaults
- Add outputs when useful
- Include job summaries for better visibility
- Test with multiple scenarios

Example:
```yaml
- name: 📦 Install dependencies
  run: pnpm install --frozen-lockfile
```

### Composite Actions

- Keep actions focused and reusable
- Document all inputs and outputs
- Use semantic versioning for breaking changes
- Include usage examples in README

### Scripts

- Use bash for portability
- Include help text (`--help`)
- Validate prerequisites
- Provide dry-run mode when applicable
- Use colored output for better UX
- Handle errors gracefully

### Documentation

- Keep it concise and scannable
- Use examples liberally
- Update all affected docs
- Include troubleshooting tips
- Add FAQ entries for common questions

## 🧪 Testing Requirements

### Before Submitting

1. **Validate YAML syntax**
   ```bash
   ./scripts/validate-workflows.sh
   ```

2. **Test in a real repository**
   - Create a test repository
   - Apply your changes
   - Verify workflows run successfully

3. **Check for breaking changes**
   - Document any breaking changes
   - Update CHANGELOG.md
   - Consider backward compatibility

### Workflow Testing

For workflow changes:
1. Test with different inputs
2. Verify error handling
3. Check job summaries
4. Test on both `ubuntu-latest` and other runners if applicable

### Script Testing

For script changes:
1. Test with valid inputs
2. Test with invalid inputs
3. Test dry-run mode
4. Test validation mode
5. Verify error messages are clear

## 📋 Code Review Process

### Review Criteria

- [ ] Code follows existing patterns
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Commit messages follow conventions
- [ ] PR description is clear

### Approval Requirements

- **develop branch**: 1 approval from maintainers
- **main branch**: 2 approvals from maintainers

## 🏷️ Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## 🐛 Reporting Issues

### Bug Reports

Include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, versions)
- Relevant logs or screenshots

### Feature Requests

Include:
- Use case description
- Proposed solution
- Alternative solutions considered
- Impact on existing functionality

## 💡 Best Practices

### Workflow Design

1. **Reusability**: Design for multiple use cases
2. **Configurability**: Use inputs for flexibility
3. **Performance**: Minimize job duration
4. **Security**: Never hardcode secrets
5. **Maintainability**: Keep workflows simple and documented

### Composite Actions

1. **Single Responsibility**: One action, one purpose
2. **Idempotency**: Safe to run multiple times
3. **Error Handling**: Fail fast with clear messages
4. **Documentation**: Inline comments for complex logic

### Scripts

1. **Validation**: Check prerequisites early
2. **Feedback**: Provide clear progress indicators
3. **Safety**: Use dry-run for destructive operations
4. **Portability**: Avoid platform-specific commands

## 📞 Getting Help

- **Questions**: Open a [Discussion](../../discussions)
- **Bugs**: Open an [Issue](../../issues)
- **Chat**: Reach out to @ArkeonProject/devops

## 🙏 Thank You

Your contributions make this project better for everyone in the organization!

---

**Maintainer**: @daviilpzDev  
**Team**: @ArkeonProject/devops
