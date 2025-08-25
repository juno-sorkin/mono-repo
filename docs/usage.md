# Developer Quickstart (Linux/WSL)

This guide provides the necessary steps to configure your local development environment using [Homebrew on Linux (Linuxbrew)](https://docs.brew.sh/Homebrew-on-Linux). Following these instructions is the recommended way to ensure all pre-commit checks run correctly.

### Step 1: Install Homebrew (One-Time Setup)

If you do not have Homebrew installed, run the following command and follow the on-screen instructions. This only needs to be done once per system.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
*After installation, the script will prompt you to run a few commands to add Homebrew to your `PATH`. Make sure to complete that step before proceeding.*

### Step 2: Install Project Dependencies

With Homebrew installed, you can now install all the necessary tools with a single command.

```bash
brew install tflint terraform-docs
```

### Step 3: Configure the Project Environment

Now, set up the project-specific components. This requires the Conda environment to be active because `pre-commit` is installed there.

**Activate Conda Environment:**
```bash
conda activate self-test
```

**Install Git Hooks:**
This command uses the `pre-commit` package from your Conda environment to set up the git hooks in this repository. This only needs to be done once per project.
```bash
pre-commit install
```

### Step 4: Verify the Setup

To ensure all system tools and Python packages are working together correctly, run all the hooks against all files in the repository. Make sure your `self-test` Conda environment is still active.

```bash
pre-commit run --all-files
```

If all checks pass, your local environment is correctly configured. The hooks will now run automatically on every `git commit`.
