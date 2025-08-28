# Root BUILD file for the entire repository

# Global Python requirements that can be used by all targets
python_requirements(
    name="reqs",
    source="pyproject.toml",
)

# Repository-wide shell sources for scripts
shell_sources(
    name="scripts",
    sources=["scripts/**/*.sh"],
)

# Global file targets for configuration files
files(
    name="config",
    sources=[
        "pyproject.toml",
        "pants.toml",
        ".pre-commit-config.yaml",
        ".terraform-docs.yml",
        ".gitignore",
    ],
)

# Documentation files
files(
    name="docs",
    sources=["README.md", "docs/**/*"],
)