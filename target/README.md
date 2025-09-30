this dir is for PEX binary wrappers to allow runnables in cli via pants, it points to @3rdparty/ BUILD file

any runnable in this dir can be run by prefixing the normal cli command with ->
'pants run //target:<tool_name> <cli_command>'

for example ->
pants run //target:cookiecutter -- templates/template-infra -o infra-packages/
