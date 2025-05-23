<!--
Copyright 2025 Sophie Lund

This file is part of DX Scripts.

DX Scripts is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

DX Scripts is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along with DX Scripts. If not, see
<https://www.gnu.org/licenses/>.
-->

# AWS

To use the AWS library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/aws.bash"
```

See [`aws.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/aws.bash) for the full implementations of these functions.

## `list_aws_environment_names`

=== "Description"

    Lists the names of all of the AWS environments configured on the local system.

    It does this by looking at the `~/.aws/config` file and filtering the names by the prefix provided.

    ```bash
    $ list_aws_environment_names
    development
    staging
    production
    ```

    You need to provide the `DX_SCRIPTS_AWS_PROFILE_PREFIX` environment variable for this to work. It is a prefix for profiles to filter by.

=== "Usage"

    **Usage:** `list_aws_environment_names`

=== "Environment variables"

    * `DX_SCRIPTS_AWS_PROFILE_PREFIX`: The prefix to filter the environment names by. This is usually the name of the project. *(required)*
    * `DX_SCRIPTS_AWS_CONFIG_PATH`: The path to the AWS config file. If not set, it will default to `~/.aws/config`.

=== "Return codes"

    It will return:

     * 0 on success.
     * 1 if `DX_SCRIPTS_AWS_PROFILE_PREFIX` is not set.
     * 2 if there is no `~/.aws/config` file.
     * 3 if there are no profiles starting with `<prefix>`.

=== "Errors"

    This function does not throw any errors.

## `login_to_aws_sso`

=== "Description"

    Logs into an AWS SSO environment.

    ```bash
    $ login_to_aws_sso development
    ```

    See [`list_aws_environment_names`](#list_aws_environment_names) for more information on how environments are resolved.

=== "Usage"

    **Usage:** `login_to_aws_sso <environment>`

    **Options:**

     * `<environment>`: The name of the environment to log in to.

=== "Environment variables"

    See [`list_aws_environment_names`](#list_aws_environment_names) for more information on the environment variables used.

=== "Return codes"

    See [`list_aws_environment_names`](#list_aws_environment_names) for more information on the return codes.
    It will return:
    
     * 0 on success.
     * 1 if `DX_SCRIPTS_AWS_PROFILE_PREFIX` is not set. *(from [`list_aws_environment_names`](#list_aws_environment_names))*
     * 2 if there is no `~/.aws/config` file. *(from [`list_aws_environment_names`](#list_aws_environment_names))*
     * 3 if there are no profiles starting with `<prefix>`. *(from [`list_aws_environment_names`](#list_aws_environment_names))*
     * 4 if the environment is not found.

=== "Errors"

    This function does not throw any errors.

## `login_to_aws_endpoint`

=== "Description"

    Logs into a specific local endpoint that is compatible with the AWS API.

    ```bash
    $ login_to_aws_endpoint http://localhost:8000 us-east-1
    ```

    This only affects the current shell, but then all AWS API calls will go to this local endpoint instead of AWS itself.

=== "Usage"

    **Usage:** `login_to_aws_endpoint <endpoint url> <region>`

    **Options:**

     * `<endpoint url>`: The URL to log into.
     * `<region>`: The AWS region to use. For most endpoints, this doesn't matter.

=== "Environment variables"

    This function does not use any environment variables.

=== "Return codes"

    It will always return 0.

=== "Errors"

    This function does not throw any errors.
