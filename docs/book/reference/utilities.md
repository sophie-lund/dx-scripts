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

# Utilities

To use the utilities library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/utilities.bash"
```

See [`utilities.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/utilities.bash) for the full implementations of these functions.

## `print_output_on_error`

=== "Description"

    Runs a command and silences the output unless it exits with a non-zero exit code. Then it will print the command's combined output to `stdout` and `stderr` both to both`stdout`.

    ```bash
    $ print_output_on_error ls /

    $ print_output_on_error ls /nonexistant
    "/nonexistant": No such file or directory (os error 2)
    ```

=== "Usage"

    **Usage:** `print_output_on_error <command...>`

    **Options:**

     * `<command...>`: The command to run, as-is. Note that pipes will not be included in the command by default.

=== "Environment variables"

    This function does not use any environment variables.

=== "Return codes"

    It will return 0 if the command succeeds, and 1 if it fails.

=== "Errors"

    This function does not throw any errors.

## `capture_command_output`

=== "Description"

    Runs a command and captures both the output to `stdout` and the exit status. `stderr` is not captured.

    It will set two global variables:

    * `CAPTURE_STDOUT`: The output of the command.
    * `CAPTURE_EXIT_STATUS`: The exit status of the command.

    You have to use the values of those variables before this functionsi called again, as they will be overwritten.[^1]

    ```bash
    $ capture_command_output ls /

    $ echo $CAPTURE_STDOUT
    /Applications
    /cores
    /etc
    ...

    $ echo $CAPTURE_EXIT_STATUS
    0
    ```

=== "Usage"

    **Usage:** `capture_command_output <command...>`

    **Options:**

     * `<command...>`: The command to run, as-is. Note that pipes will not be included in the command by default.

=== "Environment variables"

    This function does not use any environment variables.

=== "Return codes"

    It will always return 0.

=== "Errors"

    This function does not throw any errors.

## `get_current_project_directory`

=== "Description"

    It finds and prints the current project directory. It looks for the highest-level Git repository relative to the `utilities.bash` script directory. If a parent Git repository is a submodule, it will find the parent Git repository.

    You can override the value returned by this function by setting the environment variable `DX_SCRIPTS_PROJECT_DIRECTORY`.

    ```bash
    $ get_current_project_directory
    /home/user/project

    $ DX_SCRIPTS_PROJECT_DIRECTORY=/here get_current_project_directory
    /here
    ```

=== "Usage"

     This function takes no arguments.

=== "Environment variables"

    * `DX_SCRIPTS_PROJECT_DIRECTORY`: Can be used to override the current project directory. If set, it will be used instead of the Git repository.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if the current project directory cannot be found.

## `clean_git_ignored`

=== "Description"

    Deletes all files in the current project directory (see [`get_current_project_directory](#get_current_project_directory)]) that are ignored in the Git repository via `.gitignore`.

    It will ask the user to confirm before they are deleted.

    ```bash
    $ clean_git_ignored
    [2025-05-04 12:06:56] [warning] The following files are ignored by Git and will be removed:
      "some/file.txt"
      "some/other/file.txt"
    Are you sure you want to remove these files? [y/N] y
    [2025-05-04 12:06:56] [info] Clean successful
    ```

=== "Usage"

     This function takes no arguments.

=== "Environment variables"

    This function does not use any environment variables.

=== "Return codes"

    It will always return 0 unless there is an error with `git`.

=== "Errors"

    It will exit the script with exit code 1 if the current project directory cannot be found.

[^1]: I know this is bad coding practice, but it's a utility function that isn't used a ton so like... forgive me cause I'm cute?.
