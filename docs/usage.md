# Developer Quickstart Guide
*Last updated: 2025-08-30*

## Quick Reference Cheat Sheet
```bash
# Setup
./pants --version  # Bootstrap Pants
pre-commit install  # Install git hooks

# Daily Work
./pants fmt ::     # Format code
./pants lint ::    # Lint code
./pants test ::    # Run tests

# Change Detection
./pants --changed-since=origin/main fmt
./pants --changed-since=origin/main lint
./pants --changed-since=origin/main test
```

## Detailed Usage

### Prerequisites

- **Python 3.12+**: Required for Pants and Python development
- **Git**: Version control system
- **Terraform** (optional): For local Terraform development and testing

### Quick Setup

#### Step 1: Clone and Bootstrap

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mono-repo
   ```

2. **Bootstrap Pants**
   ```bash
   ./pants --version
   ```
   This downloads and sets up Pants automatically. No manual installation required!

#### Step 2: Install Pre-commit Hooks (Recommended)

Install pre-commit for automatic quality checks:
```bash
pip install pre-commit
pre-commit install
```

#### Step 3: Verify Your Setup

Run all pre-commit hooks to ensure everything is working:
```bash
pre-commit run --all-files
```

### Daily Development Workflow

#### Python Development

1. **Format your code**
   ```bash
   ./pants fmt ::
   ```

2. **Run linting**
   ```bash
   ./pants lint ::
   ```

3. **Run tests**
   ```bash
   ./pants test ::
   ```

#### Change Detection (PR-like workflow)

For efficient development, use change detection to only run checks on modified files:
```bash
# Format only changed files
./pants --changed-since=origin/main --changed-dependents=transitive fmt

# Lint only changed files
./pants --changed-since=origin/main --changed-dependents=transitive lint

# Test only changed files
./pants --changed-since=origin/main --changed-dependents=transitive test
```

#### Terraform Development

For Terraform modules in `infra-packages/`:

1. **Navigate to a module**
   ```bash
   cd infra-packages/aws/<module-name>
   ```

2. **Initialize and validate**
   ```bash
   terraform init -backend=false
   terraform validate
   ```

3. **Run tests**
   ```bash
   terraform test
   ```

4. **Run all Terraform checks across the repo**
   ```bash
   pre-commit run --all-files --show-diff-on-failure
   ```

### Project Structure

- **`packages/`**: Python libraries packaged via Pants
- **`services/`**: Python service code
- **`infra-packages/`**: Reusable Terraform modules (e.g., AWS infrastructure)
- **`templates/`**: Cookiecutter templates for new projects/modules
- **`3rdparty/python/`**: Locked third-party Python requirements
- **`docs/`**: Developer and usage documentation

### Creating New Components

#### New Python Package
```bash
cookiecutter templates/template-project -o packages
```

#### New Terraform Module
```bash
cookiecutter templates/template-infra -o infra-packages
```

### CI/CD Integration

This project uses GitHub Actions for automated testing:

- **Library Tests**: Runs Pants fmt/lint/test on Python code
- **Terraform Validation**: Validates Terraform modules
- **CI Image**: Reproducible build environment via Docker

### Troubleshooting

#### Common Issues

1. **Pants won't start**
   - Ensure Python 3.12+ is in your PATH
   - Try: `./pants --no-local-cache --version`

2. **Pre-commit hooks fail**
   - Run: `pre-commit run --all-files` to see specific errors
   - Fix issues and commit again

3. **Terraform version conflicts**
   - Pin Terraform version in `pants.toml`:
     ```toml
     [download-terraform]
     version = "1.13.0"
     ```

4. **WSL/Docker networking issues**
   - Configure DNS in WSL or Docker settings
   - Restart your development environment

## Video Tutorials
- [Getting Started with Pants](https://example.com/pants)
- [Terraform in Mono-Repos](https://example.com/tf-mono)

## Common Examples
```bash
# Create new Python package
cookiecutter templates/template-project -o packages

# Create new Terraform module
cookiecutter templates/template-infra -o infra-packages
```

## Getting Help

- **Pants Documentation**: https://www.pantsbuild.org/
- **Terraform Documentation**: https://developer.hashicorp.com/terraform/docs
- **Project Issues**: Check GitHub issues for similar problems
- **Pre-commit Issues**: Run with `--show-diff-on-failure` for detailed output

Your environment is ready when all commands run successfully without errors!
