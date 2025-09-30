# target/BUILD


# A runnable binary for the Cookiecutter tool.
pex_binary(
    name="cookiecutter",
    entry_point="cookiecutter.cli:main",
    dependencies=["//3rdparty/tools:tools-reqs#cookiecutter"],
    resolve="tools",
)

# A runnable binary for Metaflow on CLI.
pex_binary(
    name="Metaflow",
    entry_point="Metaflow.cli:main", #evalute entry_point usage
    dependencies=["//3rdparty/python:python-reqs#Metaflow"],
    resolve="python",
)

pex_binary(
    name="pre-commit",
    entry_point="pre-commit.cli:main", #evalute entry_point usage
    dependencies=["//3rdparty/tools:tools-reqs#pre-commit"],
    resolve="tools",
)
