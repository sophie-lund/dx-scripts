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

# Logging

To use the logging library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_LOGGING:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/logging.bash"
```

See [`logging.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/logging.bash) for the full implementations of these functions.

## `log_info`

=== "Description"

    Logs an informative message to the console.

    ```bash
    $ log_info "This is an informative message"
    [2025-05-04 12:06:56] [info] This is an informative message
    ```

=== "Usage"

    **Usage:** `log_error <message>`

    **Options:**

     * `<message>`: The message to log.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if:

    * The message is empty.
    * The message starts with a lowercase letter.
    * The message ends with a period (`...` is OK).

## `log_warning`

=== "Description"

    Logs a warning message to the console.

    ```bash
    $ log_warning "This is a warning message"
    [2025-05-04 12:06:56] [warning] This is a warning message
    ```

=== "Usage"

    **Usage:** `log_error <message>`

    **Options:**

     * `<message>`: The message to log.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if:

    * The message is empty.
    * The message starts with a lowercase letter.
    * The message ends with a period (`...` is OK).

## `log_error`

=== "Description"

    Logs a error message to the console. This will ***not*** exit the script.

    ```bash
    $ log_error "This is a error message"
    [2025-05-04 12:06:56] [error] This is a error message
    ```

=== "Usage"

    **Usage:** `log_error <message>`

    **Options:**

     * `<message>`: The message to log.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if:

    * The message is empty.
    * The message starts with a lowercase letter.
    * The message ends with a period (`...` is OK).

## `die`

=== "Description"

    Logs a error message to the console and exits the script with exit code 1.

    ```bash
    $ die "This is a error message"
    [2025-05-04 12:06:56] [error] This is a error message
    ```

=== "Usage"

    **Usage:** `die <message>`

    **Options:**

     * `<message>`: The message to log.

=== "Return codes"

    N/A since it will always exit the script with exit code 1.

=== "Errors"

    It will exit the script with exit code 1.

## `run_steps`

=== "Description"

    Runs a series of steps and logs their progress to the console. This is useful for long-running processes that can easily be broken down.

    It accepts a list of step functions which all have to be of this form:

    ```bash
    function step_<name> {
        case "${1}" in
            "title")
                printf "<title>"
                ;;
            "enabled")
                printf "<true|false>"
                ;;
            "run")
                # ...
                ;;
            *)
                die "Unexpected argument: ${1}"
                ;;
        esac
    }
    ```

    For example:

    ```bash
    function step_create_file {
        case "${1}" in
            "title")
                printf "Create file"
                ;;
            "enabled")
                printf "true"
                ;;
            "run")
                touch file.txt
                ;;
            *)
                die "Unexpected argument: ${1}"
                ;;
        esac
    }

    function step_delete_file {
        case "${1}" in
            "title")
                printf "Delete file"
                ;;
            "enabled")
                printf "true"
                ;;
            "run")
                rm file.txt
                ;;
            *)
                die "Unexpected argument: ${1}"
                ;;
        esac
    }

    $ run_steps \
        step_create_file \
        step_delete_file \
    ;

    [2025-05-04 12:06:56] [1/2] Create file
    [2025-05-04 12:06:56] [2/2] Delete file
    ```

    You can also disable some of the steps by using their `"enabled"` cases. For example:

    ```bash hl_lines="23-29 39"
    function step_create_file {
        case "${1}" in
            "title")
                printf "Create file"
                ;;
            "enabled")
                printf "true"
                ;;
            "run")
                touch file.txt
                ;;
            *)
                die "Unexpected argument: ${1}"
                ;;
        esac
    }

    function step_delete_file {
        case "${1}" in
            "title")
                printf "Delete file"
                ;;
            "enabled")
                if [[ "${PRESERVE_FILE:-}" == "true" ]]; then
                    printf "false"
                else
                    printf "true"
                fi
                ;;
            "run")
                rm file.txt
                ;;
            *)
                die "Unexpected argument: ${1}"
                ;;
        esac
    }

    $ PRESERVE_FILE=true run_steps \
        step_create_file \
        step_delete_file \
    ;

    [2025-05-04 12:06:56] [1/1] Create file
    ```

    Only `step_create_file` is run - and this is reflected in the number of steps printed to the console.

=== "Usage"

    **Usage:** `run_steps <steps...>`

    **Options:**

     * `<steps...>`: A list of function names to be run as steps.

     Each step function must accept one argument which may be any of `"title"`, `"enabled"`, or `"run"`.

     * `"title"` must print a string which will be printed to the console as the message.
     * `"enabled"` must print a string which is either `"true"` or `"false"`. This will determine if the step is run or not.
     * `"run"` is where the actual work is done. This function will be run if the `"enabled"` case returns `"true"`. 

=== "Return codes"

    It will return 0 if all steps are run successfully, otherwise it will return the error return code of the failed step.

=== "Errors"

    It will exit the script with exit code 1 if:

    * A `"enabled"` call prints a string that is not `"true"` or `"false"`.
    * A step is not a function.
