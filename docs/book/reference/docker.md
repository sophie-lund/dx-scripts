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
    run_docker_compose docker/docker-compose.yml build
    ```

=== "Usage"

    **Usage:** `run_docker_compose <compose file> [args...]`

     This function takes one positional argument, the path of `docker-compose.yml` relative to your project directory. It then takes any number of arguments that are forwarded to the `docker compose` command.

     For example, in this command `ps -a` are forwarded to `docker compose`:

     ```bash
     run_docker_compose docker/docker-compose.yml ps -a
     ```

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    It will exit the script with exit code 1 if:
     * The env file does not exist.
     * `COMPOSE_PROJECT_NAME` is not set in the env file for the project.

## `is_docker_compose_project_running`

=== "Description"

    Checks if the Docker Compose project is currently running. If there is at least one container running, it will consider the project to be running.

    ```bash
    is_docker_compose_project_running docker/docker-compose.yml
    ```

=== "Usage"

    **Usage:** `is_docker_compose_project_running <compose file>`

     This function takes one positional argument, the path of `docker-compose.yml` relative to your project directory.

=== "Return codes"

    It will return 0 if the project is running and 1 if it is not running.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_clean_volumes`

=== "Description"

    Deletes any volumes that are used by the project. This only works when the project is not running. It will ask for user confirmation.

    ```bash
    docker_clean_volumes docker/docker-compose.yml
    ```

=== "Usage"

    **Usage:** `docker_clean_volumes <compose file>`

     This function takes one positional argument, the path of `docker-compose.yml` relative to your project directory.

=== "Return codes"

    It will return 0 on success and a non-zero exit code on failure, such as if the project is still running.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_compose_down`

=== "Description"

    Brings down Docker Compose containers. It can either bring down just one container by name:

    ```bash
    docker_compose_down docker/docker-compose.yml my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    docker_compose_down docker/docker-compose.yml
    ```

=== "Usage"

    **Usage:** `docker_compose_down <compose file> [container name]`

    **Options:**

     * `<compose file`>: The path of `docker-compose.yml` relative to your project directory.
     * `[container name]`: The name of the container to bring down *(optional)*.
        * If omitted, all containers will be brought down.

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_compose_up`

=== "Description"

    Brings up Docker Compose containers. It can either bring up just one container by name:

    ```bash
    docker_compose_up docker/docker-compose.yml my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    docker_compose_up docker/docker-compose.yml
    ```

    It will also re-build or pull any images that are used in the project.

=== "Usage"

    **Usage:** `docker_compose_up <compose file> [container name]`

    **Options:**

     * `<compose file>`: The path of `docker-compose.yml` relative to your project directory.
     * `[container name]`: The name of the container to bring up *(optional)*.
        * If omitted, all containers will be brought up.

=== "Return codes"

    It will return the same exit status as the `docker compose` command. Note that multiple commands are called and it will return the first non-zero exit code.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `docker_compose_restart`

=== "Description"

    Restarts Docker Compose containers. It can either restart just one container by name:

    ```bash
    docker_compose_restart docker/docker-compose.yml my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    docker_compose_restart docker/docker-compose.yml
    ```

    This is equivalent to calling `docker_compose_down` and then `docker_compose_up` immediately after.

=== "Usage"

    **Usage:** `docker_compose_restart <compose file> [container name]`

    **Options:**

     * `<compose file`>: The path of `docker-compose.yml` relative to your project directory.
     * `[container name]`: The name of the container to restart *(optional)*.
        * If omitted, all containers will be restarted.

=== "Return codes"

    It will return the same exit status as the `docker compose` command. Note that multiple commands are called and it will return the first non-zero exit code.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `tail_docker_compose_logs`

=== "Description"

    Watches the logs of Docker Compose containers. You can either watch the logs of just one container by name:

    ```bash
    tail_docker_compose_logs docker/docker-compose.yml my-container
    ```

    Or all of them at once by omitting the name:

    ```bash
    tail_docker_compose_logs docker/docker-compose.yml
    ```

=== "Usage"

    **Usage:** `tail_docker_compose_logs <compose file> [container name]`

    **Options:**

     * `<compose file>`: The path of `docker-compose.yml` relative to your project directory.
     * `[container name]`: The name of the container to watch *(optional)*.
        * If omitted, all containers will be watched.

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `exec_docker_compose_shell `

=== "Description"

    Enters an interactive shell in a Docker Compose container.

    ```bash
    exec_docker_compose_shell docker/docker-compose.yml my-container
    ```

    You can also pass in a command to run in the container:

    ```bash
    exec_docker_compose_shell docker/docker-compose.yml my-container "echo hello, world"
    ```

    It must be passed in as a single string argument, like above.

    It will try to use `/bin/bash` if it is available, otherwise it will fall back to `/bin/sh`.

=== "Usage"

    **Usage:** `exec_docker_compose_shell <compose file> <container name> [command]`

    **Options:**

     * `<compose file>`: The path of `docker-compose.yml` relative to your project directory.
     * `<container name>`: The name of the container to shell into.
     * `[command]`: The command to run in the container *(optional)*.
        * If omitted, an interactive shell will be opened.

=== "Return codes"

    It will return the same exit status as the `docker compose` command.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

## `print_docker_compose_status`

=== "Description"

    Prints the status of all of the containers in a Docker Compose project.

    ```bash
    print_docker_compose_status docker/docker-compose.yml
    ```

=== "Usage"

    **Usage:** `print_docker_compose_status <compose file>`

    **Options:**

     * `<compose file>`: The path of `docker-compose.yml` relative to your project directory.

=== "Return codes"

    It will always return 0.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

    It will also throw an error if your terminal is less than 100 characters wide, as it will not be able to print the status correctly.

## `watch_docker_compose_status`

=== "Description"

    Watches the status of all of the containers in a Docker Compose project, updating every 5 seconds.

    ```bash
    watch_docker_compose_status docker/docker-compose.yml
    ```

=== "Usage"

    **Usage:** `watch_docker_compose_status <compose file>`

    **Options:**

     * `<compose file>`: The path of `docker-compose.yml` relative to your project directory.

=== "Return codes"

    It will always return 0.

=== "Errors"

    See [`run_docker_compose`](#run_docker_compose) for the errors that will throw.

    It will also throw an error if your terminal is less than 100 characters wide, as it will not be able to print the status correctly.
