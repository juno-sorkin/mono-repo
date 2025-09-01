# Infrastructure Template

This is a Cookiecutter template for creating new infrastructure packages in the mono-repo.

## Template Variables

When using this template, you'll be prompted for:
- `infra_name`: Display name of the infrastructure package
- `infra_slug`: Auto-generated slug version of the name (lowercase, underscores)
- `create_backend_config`: Whether to generate Terraform backend config (y/n)
- `create_docs`: Whether to generate documentation (y/n)
- `create_tests`: Whether to generate test files (y/n)

## Usage

Generate a new infrastructure package from this template:
```
cookiecutter templates/template-infra -o infra-packages
```

## Generated Structure

The template will create an infrastructure package with:
- Standard Terraform module structure
- Optional backend configuration (if `create_backend_config=y`)
- Optional documentation (if `create_docs=y`)
- Optional test files (if `create_tests=y`)

## Customization

Edit `cookiecutter.json` to:
- Add/remove variables
- Modify default values
- Add new template options
