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

# Dependency predicates

To use the dependency predicates library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/dependency-predicates.bash"
```

See [`dependency-predicates.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/dependency-predicates.bash) for the full implementations of these functions.

## `is_linux`

=== "Description"

    Checks if the current system is Linux.

    ```bash
    $ is_linux
    ```

=== "Usage"

    **Usage:** `is_linux`

     This function does not take any arguments.

=== "Return codes"

    It will return:

    * `0` if the system is Linux.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `is_macos`

=== "Description"

    Checks if the current system is macOS.

    ```bash
    $ is_macos
    ```

=== "Usage"

    **Usage:** `is_macos`

     This function does not take any arguments.

=== "Return codes"

    It will return:

    * `0` if the system is macOS.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `is_host_os_supported`

=== "Description"

    Checks if the current system is in a list of given OSs.

    ```bash
    $ is_host_os_supported linux macos
    ```

=== "Usage"

    **Usage:** `is_host_os_supported [os...]`

    **Options:**

     * `[os...]`: A list of OSs to check against. The following OSs are supported:
        * `linux`
        * `macos`

=== "Return codes"

    It will return:

    * `0` if the system is supported (is in the provided list).
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `does_command_exist`

=== "Description"

    Checks if the command can be called.

    ```bash
    $ does_command_exist ls
    ```

    This supports binary files in the path, shell aliases, and shell functions.

=== "Usage"

    **Usage:** `does_command_exist <command>`

    **Options:**

     * `<command>`: The command for which to check.

=== "Return codes"

    It will return:

    * `0` if the command can be called.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `are_xcode_cli_tools_installed`

=== "Description"

    Checks if the Xcode CLI tools are installed.

    ```bash
    $ are_xcode_cli_tools_installed
    ```

=== "Usage"

    **Usage:** `are_xcode_cli_tools_installed`

    This function does not take any arguments.

=== "Return codes"

    It will return:

    * `0` if they are installed.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `is_xcode_installed`

=== "Description"

    Checks if the Xcode desktop app is installed.

    ```bash
    $ is_xcode_installed
    ```

=== "Usage"

    **Usage:** `is_xcode_installed`

    This function does not take any arguments.

=== "Return codes"

    It will return:

    * `0` if it is installed.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `try_get_nvm_directory`

=== "Description"

    Gets the NVM installation directory, if it exists.

    ```bash
    $ try_get_nvm_directory
    /home/user/.nvm
    ```

=== "Usage"

    **Usage:** `try_get_nvm_directory`

    This function does not take any arguments.

=== "Return codes"

    It will always return 0.

=== "Errors"

    This function does not throw any errors.

## `is_nvm_installed`

=== "Description"

    Checks if NVM is installed.

    ```bash
    $ is_nvm_installed
    ```

=== "Usage"

    **Usage:** `is_nvm_installed`

    This function does not take any arguments.

=== "Return codes"

    It will return:

    * `0` if it is installed.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `is_docker_compose_2x_installed`

=== "Description"

    Checks if Docker Compose is installed and is at least version 2.x.

    ```bash
    $ is_docker_compose_2x_installed
    ```

=== "Usage"

    **Usage:** `is_docker_compose_2x_installed`

    This function does not take any arguments.

=== "Return codes"

    It will return:

    * `0` if it is installed.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.

## `are_docker_engine_metrics_enabled`

=== "Description"

    Checks if Docker Engine has the metrics endpoint enabled.

    ```bash
    $ are_docker_engine_metrics_enabled
    ```

=== "Usage"

    **Usage:** `are_docker_engine_metrics_enabled`

    This function does not take any arguments.

=== "Return codes"

    It will return:

    * `0` if they are enabled.
    * `1` otherwise.

=== "Errors"

    This function does not throw any errors.
