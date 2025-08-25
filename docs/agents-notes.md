# @agents-notes




## Quick Start Versioning Guide
This project standardizes its development and CI environments by pinning all essential tools to specific versions. This ensures that every developer and every CI run operates with the exact same dependencies, eliminating "it works on my machine" issues.

**Key Insight:** A critical finding during our CI setup was that `terraform-docs` is not included in the default GitHub Actions runner image. Unlike `tflint`, it must be explicitly installed. We use the `tfutils/setup-terraform-docs` action to handle this in a clean and maintainable way.

### Pinned Versions
| Tool | Version | Configuration File |
| :--- | :--- | :--- |
| Python | `3.12` | `.github/workflows/test-library.yml` |
| Terraform | `1.13.0` | `.github/workflows/validate-modules.yml` |
| pre-commit | `4.3.0` | `.github/workflows/validate-modules.yml` |
| terraform-docs | `v0.20.0` | `.github/workflows/validate-modules.yml` |
| `pre-commit/pre-commit-hooks` | `v6.0.0` | `.pre-commit-config.yaml` |
| `astral-sh/ruff-pre-commit` | `v0.12.10` | `.pre-commit-config.yaml` |
| `antonbabenko/pre-commit-terraform` | `v1.100.0` | `.pre-commit-config.yaml` |

To align your local development environment (using Homebrew) with these versions, see the CLI commands in the "Local Environment Setup" section of this document.

## CI/CD and Development Strategy

This repository's quality is maintained by a complementary two-part system: **local generation** via pre-commit hooks and **remote enforcement** via GitHub Actions.

1.  **Local Generation (via Pre-Commit Hooks):** Developers are expected to use the `pre-commit` framework to automatically format code, generate documentation, and run lint checks. The hooks are configured in `.pre-commit-config.yaml` and run automatically on every `git commit` after a one-time setup (`pre-commit install`). This ensures that code is already clean and compliant *before* it is ever pushed to the remote repository.

2.  **Remote Enforcement (via GitHub Actions):** The CI workflows in `.github/workflows/` serve as the ultimate quality gate. They run on every pull request and perform the same checks as the pre-commit hooks (formatting, linting, validation). Their purpose is to **verify** that the submitted code adheres to all standards, failing the build if any issues are found. They will never change code automatically.

This strategy provides instant, automated feedback to developers locally, while the CI/CD pipeline guarantees that no non-compliant code is ever merged.

---

## Detailed Workflow Information

### Python Code Quality (`test-library.yml`)

A GitHub Actions workflow has been set up at `.github/workflows/test-library.yml` to automate code quality checks. This workflow is triggered on every **pull request** targeting the `master` branch.

**The workflow now operates in "Enforcement Mode."** Instead of auto-formatting the code, it will fail the build if the code does not adhere to the project's formatting and linting standards. This is a more robust CI practice that ensures all code is clean *before* being committed, and it resolves the need for developers to constantly `git pull` changes made by a bot. Developers are expected to run `ruff format .` and `ruff check . --fix` locally before pushing their changes.

A `pyproject.toml` file in the root of the project consolidates all linting and formatting rules for `ruff`.
It is configured to enforce a superset of Black's code style, ensuring high-quality, readable code.

The workflow uses a Mamba environment defined in `dev_env.yml`. To ensure that the commands can be found, the job's default shell is set to `bash -l {0}` to properly activate the Conda environment for all steps.

### Ruff Configuration (`pyproject.toml`)

The `pyproject.toml` file contains the following key configurations for `ruff`:

-   **`target-version = "py312"`**: Ensures that `ruff` applies rules compatible with Python 3.12.
-   **`line-length = 88`**: Matches the Black code style.
-   **`select`**: Enables a curated set of rules:
    -   `E`/`W`: Standard pycodestyle errors and warnings.
    -   `F`: Pyflakes for detecting common errors.
    -   `I`: Isort for consistent import ordering.
    -   `C`: Flake8-comprehensions for more Pythonic comprehensions.
    -   `B`: Flake8-bugbear to find likely bugs and design problems.

This setup provides a robust foundation for maintaining code quality. For a full list of rules, refer to the [Ruff documentation](https://docs.astral.sh/ruff/rules/).

### Workflow Steps:

1.  **Checkout Code:** The workflow begins by checking out the repository's code.
2.  **Install Dependencies:** It installs the necessary Python packages using `mamba` from the `dev_env.yml` file. This provides a significant speed improvement over the standard `conda` installer. This file defines all the required packages for the project, including:
    *   `pytest`: For running automated tests.
    *   `pytest-cov`: For measuring test coverage.
    *   `ruff`: For formatting and linting.
3.  **Check Formatting with Ruff:** It runs `ruff format --check .` to ensure the code is formatted correctly. If it's not, this step will fail.
4.  **Lint with Ruff:** It runs `ruff check .` to check for a wide range of potential issues, from style violations to logical errors, based on the rules in `pyproject.toml`.
5.  **Run Pytest with Coverage:** It executes the test suite using `pytest --cov=src --cov-report=xml`. This runs all tests and generates a code coverage report in XML format.

This automated workflow ensures that all code merged into the `master` branch is properly formatted, free of common errors, and well-tested, which is crucial for maintaining a high-quality codebase.

---

### Terraform Module Validation (`validate-modules.yml`)

This workflow ensures the quality and correctness of all Terraform modules. It runs on any pull request that modifies files within the `modules/` directory and follows a "fail-fast," two-stage validation process using dependent jobs.

1.  **Job 1: `lint-and-validate`**: This job serves as a fast, global quality gate. It runs `pre-commit` across all tracked files (excluding the root `README.md`) to execute all file-based checks (like `terraform_fmt`, `tflint`, etc.). If any linting, formatting, or documentation issue is found, this job fails, and the workflow stops immediately, providing quick feedback without wasting time on slower tests.

2.  **Job 2: `test-modules`**: This job only runs if the `lint-and-validate` job succeeds. It uses a **matrix strategy** to run `terraform test` on each module in parallel. This executes the more comprehensive business logic and validation rules defined in the `.tftests.hcl` files, providing a deeper level of quality assurance.

This two-job structure provides the best of both worlds: rapid feedback for common, repository-wide errors and thorough, parallelized validation for complex module logic.

Note: `.terraform-docs.yml` now has `recursive.enabled: false` so docs are only injected for modules invoked by pre-commit (scoped to `packages/` and `shared-modules/`). This prevents CI from touching the root `README.md`.

CI safeguard: We also set `SKIP=terraform_docs` in the `validate-modules.yml` pre-commit step to hard-disable docs generation in CI while we investigate root README changes. Other terraform hooks (fmt/validate/tflint) still run.

---

### Local Pre-Commit Setup

To streamline local development and ensure all quality checks pass before you even push your code, this repository is configured with `pre-commit`. This tool will automatically run all the necessary formatting, validation, and documentation generation on every `git commit`.

**One-Time Setup:**

Before you commit for the first time, you must install the git hooks:

1.  Make sure your Conda environment (`self-test`) is active.
2.  Run the following command from the root of the repository:
    ```bash
    pre-commit install
    ```

**How it Works:**

Once installed, `pre-commit` will run automatically every time you run `git commit`. It will execute the checks defined in `.pre-commit-config.yaml` (including `terraform_docs`, `tflint`, etc.).

-   If a hook makes a change (like reformatting a file or updating a `README.md`), it will abort the commit. You can then review the changes and run `git add .` and `git commit` again.
-   If all hooks pass, your commit will proceed as normal.

This setup ensures that every commit is already clean and compliant, saving you from having to fix CI/CD failures.

---

### Combining Manual and Auto-Generated READMEs

The `terraform_docs` hook automatically generates documentation for Terraform modules. While this is great for keeping the API reference (inputs, outputs, etc.) up to date, you will often need to add manual content, such as a description or a specific example for how to use the module in this mono-repo.

The tool **will overwrite** the entire README unless you use special markers. To combine your manual content with the auto-generated tables, structure your module's `README.md` file like this:

```markdown
# My Terraform Module

This is my custom description of what this module does and how to use it.

## Example Usage

```hcl
module "my_module" {
  source = "github.com/juno-sorkin/tf-shared-modules//modules/my_module?ref=0.1.0"

  # ... other variables
}
```

<!-- BEGIN_TF_DOCS -->
(This section will be overwritten by terraform-docs)
<!-- END_TF_DOCS -->
```

**Workflow:**
1.  Add your manual content (description, usage example, etc.) to the README.
2.  Add the `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` markers where you want the auto-generated documentation to appear.
3.  When you commit a change to a `.tf` file, the `terraform_docs` hook will run and **only replace the content between these markers**. All of your custom content outside this block will be preserved.

This is the standard and recommended way to maintain high-quality, comprehensive documentation.

---

### TODO: Populate Test Suite

The `tests` directory currently contains only a dummy test (`tests/test_dummy.py`). This should be expanded with a comprehensive suite of tests that cover all the functionality of the Python code in this repository.


### TODO: configure cookiecutter

currently the src and cookiecutter setup is blank, it will have to be populated and properly configured

---

### Pre-Commit Installation

The `pre-commit` package is a required dependency for this project's development workflow. If it is not already installed, it can be installed via pip:

```bash
pip install pre-commit
```

---

### Module: `vpc_metaflow` Design Note

We initially explored refactoring the `vpc_metaflow` module to more cleanly handle disabling the NAT Gateway and enabling VPC endpoints through a simplified interface. However, we decided to temporarily forgo this abstraction and revert to a simpler configuration to avoid introducing complexity that was not immediately required. The current implementation remains focused on its core purpose without the added conditional logic.

*   **`iam_metaflow`**: This module provides the necessary IAM roles and policies for Metaflow to interact with AWS services, including AWS Batch, S3, and CloudWatch Logs.
*   **`vpc_metaflow`**: This module provisions a foundational VPC tailored for Metaflow on AWS Batch. It is a thin wrapper around `terraform-aws-modules/vpc/aws` (v6.0.1) that creates a single-AZ network with public and private subnets but intentionally disables the NAT Gateway to minimize costs.
*   **`ecr_unop`**: A module for managing an Elastic Container Registry (ECR) repository, intended for internal use and not yet fully integrated into the primary workflow.

*   **`s3_metaflow`**: A module for provisioning an S3 bucket with the appropriate policies for Metaflow artifact storage.

*   **`batch_metaflow`**: This module configures the AWS Batch compute environment, job queue, and job definition required for executing Metaflow workflows.


### `vpc_metaflow` README Update

*   **Standardized Module Naming**: Updated the `README.md` to refer to the module as `vpc_metaflow` instead of `metaflow-network` to align with the directory structure and improve consistency across the project. This change clarifies the module's identity and scope.

### `vpc_metaflow` Refactor

*   **Flexible Gateway Endpoints**: Refactored the `vpc_metaflow` module to use a variable (`gateway_endpoints`) for defining VPC gateway endpoints. This change replaces the previously hardcoded S3 and DynamoDB endpoints, allowing for greater flexibility and reusability.

---

### Wrapped Modules Overview

The modules within `shared-modules/wrapped/` are designed as specialized wrappers around public Terraform modules. They serve to encapsulate complexity, enforce opinionated configurations, and provide a simplified, purpose-built interface for creating core infrastructure components for the Metaflow environment.

*   **`vpc_metaflow`**: This module provisions a foundational VPC tailored for Metaflow on AWS Batch. It is a thin wrapper around `terraform-aws-modules/vpc/aws` (v6.0.1) that creates a single-AZ network with public and private subnets but intentionally disables the NAT Gateway to minimize costs.

*   **`s3_metaflow`**: This module creates a secure S3 bucket to act as Metaflow's datastore. It wraps `terraform-aws-modules/s3-bucket/aws` (v5.4.0) and hardcodes critical settings like object versioning, server-side encryption, and public access blocks. It also features a dynamic IAM policy that can restrict access to a specific VPC endpoint when operating in a private network.

*   **`security_groups_unop`**: This is a flexible wrapper around `terraform-aws-modules/security-group/aws` (v5.3.0). Its primary purpose is to standardize the creation of security groups by enforcing a consistent naming convention (`<project_prefix>-<context_name>-sg`) and merging common tags. It passes through all rule-making capabilities, allowing consuming modules to define granular ingress and egress rules as needed.

*   **`ecr_unop`**: This module provides a standardized interface for creating private ECR repositories for custom container images, serving as an optional extension to the core architecture which primarily relies on public registries. It wraps the `terraform-aws-modules/ecr/aws` module (v3.0.1) to enforce defaults such as immutable tags, automatic lifecycle policies, and optional IAM role-based access control.

*   **`iam_metaflow`**: This module provides a comprehensive IAM foundation for Metaflow on AWS Batch deployments. It creates all necessary IAM roles using the `terraform-aws-modules/iam/aws//modules/iam-role` submodule (v6.1.0), including: a Batch job role (with S3 and CloudWatch access, plus optional, extensible policy support for services like ECR), a Batch service role, an EC2 instance role with instance profile, and an optional Spot Fleet role. The module is designed for seamless integration with other wrapper modules through its `batch_job_role_arn` output.

## ECR Module Rewrite (Latest)

**Date**: Current session
**Issue**: The ECR module had been experiencing validation errors due to incorrect argument names and inconsistent documentation.

**Resolution**: Successfully rewrote the `ecr_unop` module using the comprehensive module documentation from `docs/module-targets.md`. The rewrite included:

1. **Corrected argument names**: Used the proper `repository_*` prefixed arguments as specified in the v3.0.1 documentation:
   - `repository_name`
   - `repository_type`
   - `repository_image_tag_mutability`
   - `repository_force_delete`
   - `create_lifecycle_policy`
   - `repository_lifecycle_policy`
   - `attach_repository_policy`
   - `repository_read_write_access_arns`

2. **Enhanced functionality**:
   - Added `job_role_arn` variable for optional IAM role access
   - Added `force_delete` variable for repository deletion control
   - Improved lifecycle policy handling with default JSON policy
   - Added `repository_registry_id` output

3. **Updated documentation**: Regenerated README.md with terraform-docs and enhanced the overview with feature descriptions.

**Key Insight**: The `docs/module-targets.md` file contains authoritative, comprehensive documentation for all Terraform AWS modules, making it the definitive source for argument names, types, and behavior. This resolved the previous confusion between Terraform Registry documentation and actual module implementation.

## IAM Metaflow Module Creation (Latest)

**Date**: Current session
**Purpose**: Create a comprehensive IAM wrapper module that integrates seamlessly with the Metaflow AWS Batch system and existing wrapper modules.

**Implementation**: Successfully created the `iam_metaflow` module using the IAM module specifications from `docs/module-targets.md`. The module includes:

1. **Architecture Design**:
   - **Batch Job Role**: Grants Metaflow tasks access to S3 and CloudWatch, with optional, extensible policy support for services like ECR.
   - **Batch Service Role**: Allows AWS Batch service to manage compute environments
   - **EC2 Instance Role & Profile**: Enables EC2 instances to join Batch compute environments

2. **Integration Features**:
   - `batch_job_role_arn` output designed for use with `s3_metaflow` and `ecr_unop` modules
   - Role ARNs for AWS Batch compute environment configuration
   - Support for additional managed policies and custom inline policies
   - Consistent tagging and naming conventions

3. **Module Structure**: Used the `terraform-aws-modules/iam/aws//modules/iam-role` submodule (v6.1.0) for all role creation, following the pattern established by other wrapper modules.

**Key Design Decision**: The module creates separate roles for different functions rather than a single multi-purpose role, following AWS security best practices and enabling fine-grained access control for different components of the Metaflow system.

## Batch Metaflow Module Testing Implementation (Latest)

**Date**: Current session
**Purpose**: Implement comprehensive Terraform tests for the `batch_metaflow` module following the official Terraform testing playbook.

**Implementation**: Successfully created comprehensive tests in `shared-modules/wrapped/batch_metaflow/tests/test.tftest.hcl` following current best practices:

1. **Testing Strategy**:
   - **Plan-only tests** (`command = plan`) for fast validation without real infrastructure deployment
   - **Comprehensive scenario coverage** including all feature combinations (spot enabled/disabled, GPU enabled/disabled)
   - **Output validation** with assertions on all module outputs including proper ARN formatting
   - **Edge case testing** covering boundary values, single/multiple resources, and empty configurations

2. **Test Scenarios Implemented**:
   - **Basic setup**: Required variables only with default spot enabled
   - **Feature combinations**: All permutations of spot and GPU compute environments
   - **Custom configurations**: Non-default values for vCPUs, instance types, container images
   - **Boundary testing**: Minimum and maximum values for numeric parameters
   - **Edge cases**: Empty tags, single subnet, multiple security groups
   - **Comprehensive scenario**: All features enabled with extensive configuration

3. **Key Testing Insights**:
   - The module's conditional logic for spot and GPU environments requires careful testing of null outputs when features are disabled
   - Metaflow-specific outputs (`metaflow_batch_job_queue`, `metaflow_batch_job_definition`) must be consistent with their corresponding default outputs
   - ARN format validation using regex assertions ensures proper resource creation
   - Testing both minimal and comprehensive configurations validates the module's flexibility

4. **Testing Best Practices Applied**:
   - Clear, descriptive test names that indicate the scenario being tested
   - Deterministic test inputs using fixed AWS resource IDs (subnet IDs, security group IDs, IAM ARNs)
   - Assertions focused on stable attributes rather than provider-generated values
   - One scenario per `run` block for clarity and maintainability
   - Provider configuration at file level to ensure consistent testing environment

**Key Finding**: The testing approach validates the module's core design principle of cost optimization (zero minimum vCPUs) and conditional resource creation without requiring actual AWS infrastructure deployment, making the tests fast and reliable for CI/CD pipelines.

## GitHub Actions: Branch Fetch and Outputs Fix (Latest)

**Date**: Current session

**Issue**:
1) PR validation failed with `fatal: ambiguous argument 'origin/master'` because the workflow computed diffs against a branch that wasn't fetched in the CI clone.
2) Matrix output used pretty JSON, which can cause invalid `$GITHUB_OUTPUT` formatting if multiline.

**Changes**:
- In `.github/workflows/validate-modules.yml`, added a step to `git fetch origin ${{ github.event.pull_request.base.ref }}` before computing diffs.
- Switched `jq` to compact mode (`-c`) when building the matrix JSON so `echo "matrix=$JSON_MATRIX" >> $GITHUB_OUTPUT` writes a single line.
- Updated workflow paths and diff logic to use `shared-modules/**` and construct module roots as `shared-modules/<group>/<module>`.

**Impact**:
- Removes ambiguous ref errors on PRs from forks or shallow clones.
- Ensures matrix output adheres to `name=value` requirements for GitHub Actions outputs.

### CI Cache Reliability for Terraform Validation (Latest)

**Date**: Current Session
**Issue**: The `lint-and-validate` job was intermittently failing on the `terraform_docs` hook with an error indicating `terraform-docs` was not installed, despite being managed by `pre-commit`.
**Analysis**: CI logs showed `pre-commit` initializing but not installing the environment for the `antonbabenko/pre-commit-terraform` hook, pointing to a corrupted cache on the GitHub Actions runner.
**Resolution**: The `validate-modules.yml` workflow was updated to use `actions/cache@v4`. This caches the `~/.cache/pre-commit` directory, using a hash of `.pre-commit-config.yaml` as the cache key. This ensures fast, reliable builds by restoring a clean cache on most runs and automatically rebuilding it only when hook configurations change.

## ECR Module Rewrite (Latest)

**Date**: Current session
**Issue**: The ECR module had been experiencing validation errors due to incorrect argument names and inconsistent documentation.

**Resolution**: Successfully rewrote the `ecr_unop` module using the comprehensive module documentation from `docs/module-targets.md`. The rewrite included:

1. **Corrected argument names**: Used the proper `repository_*` prefixed arguments as specified in the v3.0.1 documentation:
   - `repository_name`
   - `repository_type`
   - `repository_image_tag_mutability`
   - `repository_force_delete`
   - `create_lifecycle_policy`
   - `repository_lifecycle_policy`
   - `attach_repository_policy`
   - `repository_read_write_access_arns`

2. **Enhanced functionality**:
   - Added `job_role_arn` variable for optional IAM role access
   - Added `force_delete` variable for repository deletion control
   - Improved lifecycle policy handling with default JSON policy
   - Added `repository_registry_id` output

3. **Updated documentation**: Regenerated README.md with terraform-docs and enhanced the overview with feature descriptions.

**Key Insight**: The `docs/module-targets.md` file contains authoritative, comprehensive documentation for all Terraform AWS modules, making it the definitive source for argument names, types, and behavior. This resolved the previous confusion between Terraform Registry documentation and actual module implementation.

## IAM Metaflow Module Creation (Latest)

**Date**: Current session
**Purpose**: Create a comprehensive IAM wrapper module that integrates seamlessly with the Metaflow AWS Batch system and existing wrapper modules.

**Implementation**: Successfully created the `iam_metaflow` module using the IAM module specifications from `docs/module-targets.md`. The module includes:

1. **Architecture Design**:
   - **Batch Job Role**: Grants Metaflow tasks access to S3 and CloudWatch, with optional, extensible policy support for services like ECR.
   - **Batch Service Role**: Allows AWS Batch service to manage compute environments
   - **EC2 Instance Role & Profile**: Enables EC2 instances to join Batch compute environments

2. **Integration Features**:
   - `batch_job_role_arn` output designed for use with `s3_metaflow` and `ecr_unop` modules
   - Role ARNs for AWS Batch compute environment configuration
   - Support for additional managed policies and custom inline policies
   - Consistent tagging and naming conventions

3. **Module Structure**: Used the `terraform-aws-modules/iam/aws//modules/iam-role` submodule (v6.1.0) for all role creation, following the pattern established by other wrapper modules.

**Key Design Decision**: The module creates separate roles for different functions rather than a single multi-purpose role, following AWS security best practices and enabling fine-grained access control for different components of the Metaflow system.

## Batch Metaflow Module Testing Implementation (Latest)

**Date**: Current session
**Purpose**: Implement comprehensive Terraform tests for the `batch_metaflow` module following the official Terraform testing playbook.

**Implementation**: Successfully created comprehensive tests in `shared-modules/wrapped/batch_metaflow/tests/test.tftest.hcl` following current best practices:

1. **Testing Strategy**:
   - **Plan-only tests** (`command = plan`) for fast validation without real infrastructure deployment
   - **Comprehensive scenario coverage** including all feature combinations (spot enabled/disabled, GPU enabled/disabled)
   - **Output validation** with assertions on all module outputs including proper ARN formatting
   - **Edge case testing** covering boundary values, single/multiple resources, and empty configurations

2. **Test Scenarios Implemented**:
   - **Basic setup**: Required variables only with default spot enabled
   - **Feature combinations**: All permutations of spot and GPU compute environments
   - **Custom configurations**: Non-default values for vCPUs, instance types, container images
   - **Boundary testing**: Minimum and maximum values for numeric parameters
   - **Edge cases**: Empty tags, single subnet, multiple security groups
   - **Comprehensive scenario**: All features enabled with extensive configuration

3. **Key Testing Insights**:
   - The module's conditional logic for spot and GPU environments requires careful testing of null outputs when features are disabled
   - Metaflow-specific outputs (`metaflow_batch_job_queue`, `metaflow_batch_job_definition`) must be consistent with their corresponding default outputs
   - ARN format validation using regex assertions ensures proper resource creation
   - Testing both minimal and comprehensive configurations validates the module's flexibility

4. **Testing Best Practices Applied**:
   - Clear, descriptive test names that indicate the scenario being tested
   - Deterministic test inputs using fixed AWS resource IDs (subnet IDs, security group IDs, IAM ARNs)
   - Assertions focused on stable attributes rather than provider-generated values
   - One scenario per `run` block for clarity and maintainability
   - Provider configuration at file level to ensure consistent testing environment

**Key Finding**: The testing approach validates the module's core design principle of cost optimization (zero minimum vCPUs) and conditional resource creation without requiring actual AWS infrastructure deployment, making the tests fast and reliable for CI/CD pipelines.

### Batch Metaflow: Compatibility fix with upstream Batch module (Latest)

- Changed `compute_resources.spot_fleet_role` to `compute_resources.spot_iam_fleet_role` to match upstream `terraform-aws-modules/batch/aws` input schema. Without this, the SPOT CE role ARN may be ignored or cause validation errors.
- Removed `container_properties.vcpus` and `container_properties.memory` when `resourceRequirements` are provided in the job definition. Current AWS Batch API expects `resourceRequirements` instead of the legacy fields to avoid conflicts.
- Minimal edits; no behavior change intended beyond schema compliance. Tests reference remain plan-only and should pass unchanged.
