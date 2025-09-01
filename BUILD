# Root BUILD file for the entire repository

# Global Python requirements that can be used by all targets
python_requirements(
    name="reqs",
    source="3rdparty/python/python-reqs.txt",
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

files(
    name="packages_src",
    sources=["packages/**"],
)

files(
    name="services_src",
    sources=["services/**"],
)

python_sources(
    name="root",
)
