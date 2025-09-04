# target/BUILD

# A runnable binary for the Cookiecutter tool.
pex_binary(
    name="cookiecutter",
    entry_point="cookiecutter.cli:main",
    dependencies=["//3rdparty/tools:tools-reqs#cookiecutter"],
    resolve="tools",
)
