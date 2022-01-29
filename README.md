# api_template


## initialize the environment

### linux

First, run the lib/setup/linux/init_environment.sh script. This will create \
a .sh_api_env file in the root of your project, and inject it into your ~/.bashrc, \
~/.bash_profile, and/or ~/.zshrc files to run as a sourced script if it is present.

it will set things like the version of node to use, version of python to use, \
the path, and any other variables you need set. To add or override the defaults \
provided, add them as exported variables to:

lib/conf/linux/environment_variables_custom_or_override

If you change environment variables in the files, you must re-run init_environment.sh \
to update the generated files.
