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

# Docker

To use the Docker library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/docker.bash"
```

See [`docker.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/docker.bash) for the full implementations of these functions.

## `run_docker_compose`

=== "Description"

    Runs the `docker compose` command with forwarded arguments, but makes sure that the env file and the correct `docker-compose.yml` file are used.

    ```bash
    run_docker_compose build
    ```

=== "Usage"

    **Usage:** `run_docker_compose [args...]`

     It takes any number of arguments that are forwarded to the `docker compose` command.

     For example, in this command `ps -a` are forwarded to `docker compose`:

     ```bash
     run_docker_compose ps -a
     ```

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    It will exit the script with exit code 1 if:
     * The env file does not exist.
     * `COMPOSE_PROJECT_NAME` is not set in the env file for the project.
     * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH` is not set in the env file for the project.

## `is_docker_compose_project_running`

=== "Description"

    Checks if the Docker Compose project is currently running. If there is at least one container running, it will consider the project to be running.

    ```bash
    is_docker_compose_project_running
    ```

=== "Usage"

    **Usage:** `is_docker_compose_project_running`

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return 0 if the project is running and 1 if it is not running.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_clean_volumes`

=== "Description"

    Deletes any volumes that are used by the project. This only works when the project is not running. It will ask for user confirmation.

    ```bash
    docker_clean_volumes
    ```

=== "Usage"

    **Usage:** `docker_clean_volumes`

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return 0 on success and a non-zero exit code on failure, such as if the project is still running.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_compose_down`

=== "Description"

    Brings down Docker Compose containers. It can either bring down just one container by name:

    ```bash
    docker_compose_down my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    docker_compose_down
    ```

=== "Usage"

    **Usage:** `docker_compose_down [container name]`

    **Options:**

     * `[container name]`: The name of the container to bring down *(optional)*.
        * If omitted, all containers will be brought down.

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_compose_up`

=== "Description"

    Brings up Docker Compose containers. It can either bring up just one container by name:

    ```bash
    docker_compose_up my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    docker_compose_up
    ```

    It will also re-build or pull any images that are used in the project.

=== "Usage"

    **Usage:** `docker_compose_up [container name]`

    **Options:**

     * `[container name]`: The name of the container to bring up *(optional)*.
        * If omitted, all containers will be brought up.

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return the same exit status as the `docker compose` command. Note that multiple commands are called and it will return the first non-zero exit code.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_compose_restart`

=== "Description"

    Restarts Docker Compose containers. It can either restart just one container by name:

    ```bash
    docker_compose_restart my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    docker_compose_restart
    ```

    This is equivalent to calling `docker_compose_down` and then `docker_compose_up` immediately after.

=== "Usage"

    **Usage:** `docker_compose_restart [container name]`

    **Options:**

     * `[container name]`: The name of the container to restart *(optional)*.
        * If omitted, all containers will be restarted.

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return the same exit status as the `docker compose` command. Note that multiple commands are called and it will return the first non-zero exit code.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `tail_docker_compose_logs`

=== "Description"

    Watches the logs of Docker Compose containers. You can either watch the logs of just one container by name:

    ```bash
    tail_docker_compose_logs my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    tail_docker_compose_logs
    ```

=== "Usage"

    **Usage:** `tail_docker_compose_logs [container name]`

    **Options:**

     * `[container name]`: The name of the container to watch *(optional)*.
        * If omitted, all containers will be watched.

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `exec_docker_compose_shell `

=== "Description"

    Enters an interactive shell in a Docker Compose container.

    ```bash
    exec_docker_compose_shell my-container
    ```

    You can also pass in a command to run in the container:

    ```bash
    exec_docker_compose_shell my-container "echo hello, world"
    ```

    It must be passed in as a single string argument, like above.

    It will try to use `/bin/bash` if it is available, otherwise it will fall back to `/bin/sh`.

=== "Usage"

    **Usage:** `exec_docker_compose_shell <container name> [command]`

    **Options:**

     * `<container name>`: The name of the container to shell into.
     * `[command]`: The command to run in the container *(optional)*.
        * If omitted, an interactive shell will be opened.

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `print_docker_compose_status`

=== "Description"

    Prints the status of all of the containers in a Docker Compose project.

    ```bash
    print_docker_compose_status
    ```

=== "Usage"

    **Usage:** `print_docker_compose_status`

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will always return 0.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

    It will also throw an error if your terminal is less than 100 characters wide, as it will not be able to print the status correctly.

## `watch_docker_compose_status`

=== "Description"

    Watches the status of all of the containers in a Docker Compose project, updating every 5 seconds.

    ```bash
    watch_docker_compose_status
    ```

=== "Usage"

    **Usage:** `watch_docker_compose_status`

=== "Environment variables"

    * `DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH`: The path to the `docker-compose.yml` file relative to the current project directory. *(required)*
    * `DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS`: Any additional arguments to pass to the `docker compose` command. *(optional)*

=== "Return codes"

    It will always return 0.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

    It will also throw an error if your terminal is less than 100 characters wide, as it will not be able to print the status correctly.
