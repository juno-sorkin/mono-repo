# Development Environment Setup Guide
*Last updated: 2025-08-30*

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Development Workflow](#development-workflow)
4. [Adding Components](#adding-components)
5. [Quality Assurance](#quality-assurance)
6. [Troubleshooting](#troubleshooting)

## Prerequisites
- **Python 3.12+** (as configured in pants.toml)
- **Git** (version control)
- **Optional Tools**:
  - Terraform (for infrastructure development)
  - tflint (Terraform linting)
  - terraform-docs (documentation generation)

## Environment Setup
```bash
git clone <repository-url>
cd mono-repo
./pants --version  # Bootstraps Pants
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

## Development Workflow
### Standard Process
1. Create feature branch
2. Make changes
3. Run quality checks:
```bash
./pants fmt ::
./pants lint ::
./pants test ::
```
4. Commit changes

### Change Detection (PR-like)
```bash
./pants --changed-since=origin/main --changed-dependents=transitive fmt
./pants --changed-since=origin/main --changed-dependents=transitive lint
./pants --changed-since=origin/main --changed-dependents=transitive test
```

## Adding Components
### Adding New Python Packages

When adding new Python packages:

1. **Create package structure in `packages/`**
   ```
   packages/your_package/
   ├── BUILD
   ├── pyproject.toml
   ├── src/your_package/
   │   ├── __init__.py
   │   └── module.py
   └── tests/
       └── test_module.py
   ```

2. **Configure BUILD file**
   ```python
   python_sources(
       name="src",
       dependencies=["//:requirements#your-dependencies"],
   )

   python_tests(
       name="tests",
       dependencies=[":src"],
   )
   ```

3. **Update pyproject.toml**
   - Add package metadata
   - Specify dependencies
   - Configure build settings

### Adding New Terraform Modules

When adding new Terraform modules in `infra-packages/`:

1. **Follow the standard structure**
   ```
   infra-packages/aws/your_module/
   ├── BUILD
   ├── main.tf
   ├── variables.tf
   ├── outputs.tf
   ├── versions.tf
   ├── README.md
   └── test.tftest.hcl
   ```

2. **Include required files**
   - `main.tf` - Main Terraform configuration
   - `variables.tf` - Input variable definitions
   - `outputs.tf` - Output definitions
   - `versions.tf` - Provider and Terraform version constraints
   - `README.md` - Module documentation with examples
   - `test.tftest.hcl` - Test configuration

3. **Configure BUILD file for Pants**
   ```python
   terraform_module(
       name="module",
       sources=["**/*.tf", "**/*.tftest.hcl"],
   )
   ```

## Quality Assurance

### Pants Quality Gates

This project uses Pants for comprehensive code quality:

- **Formatting**: Enforces consistent code style across Python and other languages
- **Linting**: Catches potential bugs and enforces best practices
- **Testing**: Runs unit and integration tests
- **Dependency management**: Handles Python and Terraform dependencies

### Pre-commit Hooks

Pre-commit hooks automatically run on each commit:

- **Pants fmt/lint/test**: Code quality checks
- **terraform_fmt**: Formats Terraform code
- **terraform_docs**: Generates/updates module documentation
- **tflint**: Terraform linting
- **terraform validate**: Validates Terraform syntax

## Troubleshooting

### Common Issues

1. **Pants bootstrap failing**
   - Ensure Python 3.12+ is installed and in PATH
   - Try `./pants --no-local-cache --version` to bypass cache issues

2. **Terraform tests failing**
   - Check Terraform syntax with `terraform validate`
   - Verify provider versions in `versions.tf`
   - Review test configurations in `.tftest.hcl` files

3. **Pre-commit hooks failing**
   - Run `pre-commit run --all-files` to see specific errors
   - Fix formatting/linting issues with `./pants fmt ::` and `./pants lint ::`
   - Consider running `terraform fmt` on Terraform files

4. **Dependency issues**
   - Check `3rdparty/python/` for locked requirements
   - Update dependencies using Pants dependency management

### Getting Help

- Check existing issues on GitHub
- Review pull requests for similar changes
- Consult the documentation in the `docs/` directory
- Ask questions in discussions or issues
- Check Pants documentation: https://www.pantsbuild.org/
- Check Terraform documentation: https://developer.hashicorp.com/terraform/docs
