# Project Template

This is a Cookiecutter template for creating new projects in the mono-repo.

## Template Variables

When using this template, you'll be prompted for:
- `project_name`: Display name of the project
- `project_slug`: Auto-generated slug version of the name (lowercase, underscores)
- `package_name`: Python package name (defaults to project_slug)
- `project_description`: Short description of the project
- `date`: Start date in mm/dd format
- `project_version`: Initial version (default: v0.1.0)
- `create_docs`: Whether to generate documentation (y/n)
- `create_readme`: Whether to generate a README (y/n)
- `create_flows`: Whether to generate metaflow orchastration files (y/n)

## Usage

Generate a new project from this template:
```
cookiecutter templates/template-project -o services
```

## Generated Structure

The template will create a project with:
- Basic Python package structure
- Optional documentation (if `create_docs=y`)
- Optional README (if `create_readme=y`)
- Optional workflow files (if `create_flows=y`)

## Customization

Edit `cookiecutter.json` to:
- Add/remove variables
- Modify default values
- Add new template options
