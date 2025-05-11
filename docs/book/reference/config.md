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

# Config

To use the config library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/config.bash"
```

See [`config.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/config.bash) for the full implementations of these functions.

## `get_config_value`

=== "Description"

    Reads the `.env` file in the [current project directory](./utilities.md#get_current_project_directory) and prints the value of the specified key. If the key is not in the file, it will be read from the shell environment.

    ```bash
    $ cat .env
    MY_CONFIG_VALUE="hello, world"

    $ get_config_value MY_CONFIG_VALUE
    hello, world
    ```

=== "Usage"

    **Usage:** `get_config_value <key>`

    **Options:**

     * `<key>`: The name of the environment variable.

=== "Environment variables"

    This function does not use any environment variables.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if the current project directory cannot be found.

## `require_config_value`

=== "Description"

    Reads the `.env` file in the [current project directory](./utilities.md#get_current_project_directory) and prints the value of the specified key. If the key is not in the file, it will be read from the shell environment.

    If the key is not found or is an empty string, it will print an error message and exit the script with exit code 1.

    ```bash
    $ cat .env
    MY_CONFIG_VALUE="hello, world"

    $ require_config_value MY_CONFIG_VALUE
    hello, world
    ```

=== "Usage"

    **Usage:** `require_config_value <key>`

    **Options:**

     * `<key>`: The name of the environment variable.

=== "Environment variables"

    This function does not use any environment variables.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if the current project directory cannot be found or if the key is nonexistent or empty.
