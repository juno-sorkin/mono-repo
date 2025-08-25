# Shared Terraform Modules

This repository is a monorepo for managing shared Terraform modules and related Python tooling. It is designed to enforce high standards of code quality and maintainability through a robust system of local development tools and remote CI/CD validation.

[See internal developer documentation](docs/)

## Features

-   **Centralized Modules:** A single source for reusable Terraform infrastructure modules.
-   **Automated Quality Checks:** Code formatting, linting, and validation are enforced automatically on every commit and pull request.
-   **Automated Documentation:** Terraform module documentation (inputs, outputs, etc.) is generated and updated automatically.
-   **Consistent Tooling:** A standardized development environment using `conda` and `pre-commit` ensures that all contributors adhere to the same quality standards.
-   **CI/CD Pipeline:** GitHub Actions workflows validate all changes, ensuring the integrity of the `master` branch.

## Using the Modules

To use a module from this repository in your own Terraform configuration, reference it directly from GitHub. You should pin your module source to a specific Git tag or commit hash for stability.

### Example

```hcl
module "my_module" {
  source = "github.com/juno-sorkin/tf-shared-modules//modules/<module_name>?ref=<tag_or_commit>"

  # ... module variables
}
```

Detailed documentation for each module, including its inputs, outputs, and an example usage, can be found in the `README.md` file within each module's directory (e.g., `modules/<module_name>/README.md`).

## Contributing

Contributions to this repository are welcome. To ensure a smooth development process, please adhere to the following workflow.

### One-Time Setup

Before making your first commit, you must install the `pre-commit` hooks to enable automated local quality checks.

1.  Activate your Conda environment (`self_test`).
2.  Run the following command from the root of the repository:
    ```bash
    pre-commit install
    ```

### Development Workflow

1.  **Make changes:** Implement your new feature or bug fix in the relevant module or Python code.
2.  **Commit changes:** When you run `git commit`, the pre-commit hooks will automatically run. They will format your code, lint for issues, and generate documentation.
    -   If a hook makes a change (e.g., reformatting a file), it may abort the commit. Simply `git add` the modified files and run `git commit` again.
    -   If all hooks pass, your commit will be created.
3.  **Push and open a Pull Request:** Once your changes are committed, push your branch and open a pull request against the `master` branch.
4.  **CI/CD Validation:** A suite of GitHub Actions will run on your pull request to validate formatting, linting, and run tests. All checks must pass before the pull request can be merged.

This process ensures that all code is clean, consistent, and validated *before* it is merged, maintaining the high quality of the repository.

## Repository Structure

```
.
├── .github/        # GitHub Actions CI/CD workflows
├── docs/           # Internal developer documentation
├── func_from_ir/   # (TBD) Python source code
├── modules/        # Shared Terraform modules
├── project_template/ # Cookiecutter template for new projects
├── tests/          # Python tests
├── .pre-commit-config.yaml # Configuration for pre-commit hooks
├── dev_env.yml     # Conda environment for development
└── pyproject.toml  # Configuration for Python tooling (ruff, pytest)
```

## Future Work

-   **Populate Test Suite:** The Python test suite in the `tests/` directory needs to be expanded to provide comprehensive coverage.
-   **Configure Cookiecutter:** The `project_template` directory needs to be fully configured to provide a robust template for new projects.
