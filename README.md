## Monorepo: Python + Terraform, built with Pants

### Overview
- **Build system**: Pants 2.27.0 for Python code and Terraform workflows
- **Languages/Stacks**: Python 3.12, Terraform modules under `infra-packages/**`
- **Quality gates**: pre-commit (Terraform hooks), Pants fmt/lint/test
- **CI**: GitHub Actions; reproducible runner via `.github/ci.Dockerfile`

### Repository layout
- **`packages/`**: Python libraries (packaged via Pants)
- **`services/`**: Service code (Python)
- **`infra-packages/`**: Reusable Terraform modules (e.g., `aws/*`)
- **`templates/`**: Cookiecutter templates (`template-project`, `template-infra`) — ignored by Pants
- **`3rdparty/python/`**: Locked third-party requirements for Pants resolves
- **`docs/`**: Developer and usage docs
- **`BUILD` / `pants.toml`**: Pants configuration

### Prerequisites
- Python 3.12
- Git
- Optional locally: Terraform, tflint, terraform-docs (needed only if you run Terraform pre-commit hooks locally; CI provides them)

### Quickstart
1) Bootstrap Pants
```
pants --version
```

2) Install pre-commit hooks (recommended locally)
```
pip install pre-commit && pre-commit install
```

3) Python formatting, linting, tests
```
pants fmt --check ::
pants lint ::
pants test ::
```

4) Change detection (PR-like runs)
```
pants --changed-since=origin/main --changed-dependents=transitive fmt --check
pants --changed-since=origin/main --changed-dependents=transitive lint
pants --changed-since=origin/main --changed-dependents=transitive test
```

5) Terraform (module-level)
- Validate/test a module manually:
```
cd infra-packages/aws/<module>
terraform init -backend=false
terraform validate
terraform test        # runs terraform.tftest.hcl
```
- Run pre-commit Terraform hooks across the repo:
```
pre-commit run --all-files --show-diff-on-failure
```

### Installing Pants
You can download and run an installer script that will install the Pants binary with this command:

```
curl --proto '=https' --tlsv1.2 -fsSL https://static.pantsbuild.org/setup/get-pants.sh | bash
```

This script will install pants into ~/.local/bin, which must be on your PATH. The installer script will warn you if it is not.

For security reasons, we don't recommend frequently curling this script directly to bash, e.g., on every CI run. Instead, for regular use, we recommend checking this script into the root of your repo and pointing users and CI machines to that checked-in version.

Alternatively, on macOS you can also use homebrew to install pants:

```
brew install pantsbuild/tap/pants
```

You can also use the bin tool to install pants:

```
bin i github.com/pantsbuild/scie-pants ~/.local/bin/pants
```

pants is a launcher binary that delegates to the underlying version of Pants in each repo. This allows you to have multiple repos, each using an independent version of Pants.

If you run pants in a repo that is already configured to use Pants, it will read the repo's Pants version from the pants.toml config file, install that version if necessary, and then run it.

If you run pants in a repo that is not yet configured to use Pants, it will prompt you to set up a skeleton pants.toml that uses that latest stable version of Pants.

If you have difficulty installing Pants, see our getting help for community resources to help you resolve your issue.

### Upgrading Pants
The pants launcher binary will automatically install and use the Pants version specified in pants.toml, so upgrading Pants in a repo is as simple as editing pants_version in that file.

To upgrade the pants launcher binary itself, either:

- Use the package manager you used to install Pants. For example, with Homebrew: `brew update && brew upgrade pantsbuild/tap/pants`.
- Use its built-in self-update functionality: `SCIE_BOOT=update pants`.

### Cookiecutter templates
- Project template:
```
cookiecutter templates/template-project -o services
```
- Infra template:
```
cookiecutter templates/template-infra -o infra-packages
```

### CI
- **Pants CI**: `.github/workflows/test-library.yml`
  - Runs `fmt --check`, `lint`, and `test` with Pants
  - Uses change detection on PRs; full runs on pushes to `main`
  - Executes in container image `ghcr.io/<owner>/<repo>-ci:latest`

- **Terraform Modules CI**: `.github/workflows/validate-modules.yml`
  - Runs Terraform pre-commit hooks (fmt/validate/docs/tflint)
  - Detects changed modules under `infra-packages/**` and runs `init/validate/test` per module

- **CI image build**: `.github/workflows/build-ci-image.yml`
  - Builds `.github/ci.Dockerfile` into `ghcr.io/<owner>/<repo>-ci:latest`
  - Triggered when the Dockerfile/workflow changes

### Terraform versioning with Pants
Modules commonly declare `required_version >= 1.13.0`. Pants downloads its own Terraform by default; pin it so validation matches your modules:
```
# in pants.toml
[download-terraform]
version = "1.13.0"

[subprocess-environment]
env_vars = ["PATH", "TF_PLUGIN_CACHE_DIR"]  # PATH for system tools, TF_PLUGIN_CACHE_DIR for Terraform plugin caching
```
Alternatively in CI, set:
```
PANTS_DOWNLOAD_TERRAFORM_VERSION=1.13.0
```

### Troubleshooting
- **Terraform Core mismatch**: If `terraform validate` reports an unsupported version (e.g., 1.9.0), pin `[download-terraform].version` to `1.13.0` as above.
- **YAML `::` parsing**: Quote or block multi-colon commands in GitHub Actions, e.g., `"./pants test ::"`.
- **Templates with `{{ ... }}`**: Pants ignores `templates/**` (see `pants.toml`) to avoid glob parsing of cookiecutter braces.
- **WSL DNS issues**: If Terraform or tooling cannot resolve hosts, configure WSL DNS (e.g., custom `/etc/resolv.conf`) and restart WSL.

### Useful references
- Pants docs: `https://www.pantsbuild.org/`
- Terraform docs: `https://developer.hashicorp.com/terraform/docs`
