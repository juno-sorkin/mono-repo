# Development Environment Setup

This document provides detailed information about setting up and maintaining the development environment for this Terraform shared modules repository.

## Local Development

### Prerequisites

- **Python 3.12+**: Required for running linting tools and tests
- **Conda**: Package and environment management
- **Terraform**: Infrastructure as Code tool
- **Git**: Version control system

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/juno-sorkin/tf-shared-modules.git
   cd tf-shared-modules
   ```

2. **Set up the development environment**
   ```bash
   # Create and activate conda environment
   conda env create -f dev_env.yml
   conda activate self-test
   ```

3. **Install pre-commit hooks**
   ```bash
   pre-commit install
   ```

4. **Verify setup**
   ```bash
   pre-commit run --all-files
   ```

## Development Workflow

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Add new modules in appropriate directories
   - Update documentation
   - Add tests

3. **Run quality checks**
   ```bash
   # Format code
   ruff format .

   # Run linting
   ruff check .

   # Run tests
   pytest
   ```

4. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: your meaningful commit message"
   ```

### Adding New Modules

When adding new Terraform modules:

1. **Choose the appropriate directory**
   - `shared-modules/custom/` for custom-built modules
   - `shared-modules/wrapped/` for modules that wrap community modules

2. **Include required files**
   - `main.tf` - Main Terraform configuration
   - `variables.tf` - Input variable definitions
   - `outputs.tf` - Output definitions
   - `versions.tf` - Provider and Terraform version constraints
   - `README.md` - Module documentation with examples
   - `test.tftests.hcl` - Test configuration

3. **Follow naming conventions**
   - Use lowercase with hyphens: `my-module-name`
   - Use descriptive names that indicate the module's purpose

4. **Add documentation**
   - Include clear description of the module's purpose
   - Provide usage examples
   - Document all inputs and outputs
   - Include any prerequisites or dependencies

## Code Quality

### Linting and Formatting

This project uses Ruff for code quality:

- **Formatting**: Enforces consistent code style
- **Linting**: Catches potential bugs and enforces best practices
- **Import sorting**: Maintains clean import statements

### Testing

- **Python tests**: Located in `tests/` directory
- **Terraform tests**: `.tftests.hcl` files in each module
- **Integration tests**: Validate module combinations

### Pre-commit Hooks

Pre-commit hooks automatically run on each commit:

- **terraform_fmt**: Formats Terraform code
- **terraform_docs**: Generates/updates module documentation
- **ruff**: Linting and formatting for Python code
- **tflint**: Terraform linting

## Contributing

### Pull Request Process

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Run tests and quality checks**
5. **Submit a pull request**

### Code Review Requirements

- All tests must pass
- Code must pass linting checks
- Documentation must be updated
- Changes must be backwards compatible (or clearly marked as breaking)

### Documentation Updates

When making changes:

- Update relevant README files
- Update this development documentation if needed
- Add examples for new features
- Update module documentation using terraform-docs

## Troubleshooting

### Common Issues

1. **Pre-commit hooks failing**
   - Run `pre-commit run --all-files` to see specific errors
   - Fix formatting/linting issues
   - Consider running `ruff format .` and `ruff check . --fix`

2. **Terraform tests failing**
   - Check Terraform syntax
   - Verify provider versions
   - Review test configurations

3. **Conda environment issues**
   - Recreate environment: `conda env remove -n self-test && conda env create -f dev_env.yml`
   - Update dependencies: `conda env update -f dev_env.yml`

### Getting Help

- Check existing issues on GitHub
- Review pull requests for similar changes
- Consult the documentation in the `docs/` directory
- Ask questions in discussions or issues
