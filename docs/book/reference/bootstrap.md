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

# Bootstrap

To use the bootstrap library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/bootstrap.bash"
```

See [`bootstrap.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/bootstrap.bash) for the full implementations of these functions.

## `ensure_dependencies_installed`

=== "Description"

    Takes in a list of dependencies and makes sure that they are all installed on the local system.

    ```bash
    $ ensure_dependencies_installed \
        dependency_xcode_cli_tools \
        dependency_homebrew \
      ;
    ```

    See [What is a dependency?](./dependencies.md#what-is-a-dependency) for information about what `dependency_xcode_cli_tools` and `dependency_homebrew` are in this example.

=== "Usage"

    **Usage:** `ensure_dependencies_installed <dependencies...>`

    **Options:**

     * `<dependencies...>`: A list of dependencies to check.

=== "Return codes"

    It will return 0 on success and a non-zero value if anything fails.

=== "Errors"

    It will throw an error if:
     * any of the dependencies are not declared correctly.
     * any dependencies are listed more than once.
     * dependencies are not installed in the right order.

## `ensure_aws_profile_configured`

=== "Description"

    Ensures that the provided AWS profile is configured in the `~/.aws/config` file.

    ```bash
    $ ensure_aws_profile_configured \
        my-project \
        'https://d-xxxxxxxxxx.awsapps.com/start' \
        us-east-1 \
        AdministratorAccess \
        my-project-development \
        my-project-development
    ```

    It will use the provided values to guide the user through the process of configuring the AWS profile.

=== "Usage"

    **Usage:** `ensure_aws_profile_configured <sso session name> <sso start url> <sso region> <role name> <account name> <profile name>`

    **Options:**

     * `<sso session name>`: A name to use for the SSO session so that it may be reused in the future.
     * `<sso start url>`: The URL to use to start the SSO session.
     * `<sso region>`: The region to use for the SSO session.
     * `<role name>`: The name of the role to use for the profile.
     * `<account name>`: The name of the account to use for the profile.
     * `<profile name>`: What to call the profile.

=== "Return codes"

    It will return 0 on success and a non-zero value if anything fails.

=== "Errors"

    This function does not throw any errors.

## `ensure_etc_hosts_entries_configured`

=== "Description"

    Ensures that all the provided hosts all point to localhost in the `/etc/hosts` file.

    ```bash
    $ ensure_etc_hosts_entries_configured \
        api.local.my-project.com \
        api.internal.my-project.com
    ```

=== "Usage"

    **Usage:** `ensure_etc_hosts_entries_configured <hosts...>`

    **Options:**

     * `<hosts...>`: A list of hosts to check.

=== "Return codes"

    It will return 0 on success and a non-zero value if anything fails.

=== "Errors"

    This function will exit the script and ask the user to add the entries to the `/etc/hosts` file if they are not already there.
