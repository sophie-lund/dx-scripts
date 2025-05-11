#!/bin/bash

# Copyright 2025 Sophie Lund
#
# This file is part of DX Scripts.
#
# DX Scripts is free software: you can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# DX Scripts is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with DX Scripts. If not,
# see <https://www.gnu.org/licenses/>.

# Standard prelude - put this at the top of all scripts
# --------------------------------------------------------------------------------------------------

# Check if this script has already been sourced
if [[ -n "${SCRIPT_DIRECTORY_DOCKER:-}" ]]; then
    return 0
fi

# Get the directory of the current script
SCRIPT_DIRECTORY_DOCKER="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_DOCKER

# Set flags
set -o errexit # abort on nonzero exit status
set -o nounset # abort on unbound variable
set -o pipefail # don't hide errors within pipes

# Ensure that the script is sourced, not being run in its own shell
if [[ "$0" = "${BASH_SOURCE[0]}" ]]; then
    printf "error: script must be sourced\n"
    exit 1
fi

# Source dependencies
# --------------------------------------------------------------------------------------------------

. "${SCRIPT_DIRECTORY_DOCKER}/utilities.bash"
. "${SCRIPT_DIRECTORY_DOCKER}/logging.bash"
. "${SCRIPT_DIRECTORY_DOCKER}/prompts.bash"

# Private functions
# --------------------------------------------------------------------------------------------------

# These should all be prefixed with '_'

function _format_docker_compose_status {
    local docker_compose_relative_path
    docker_compose_relative_path="$(require_config_value DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH)"

    printf "\033[0;90m┌──────────────────────────────────────────┬────────────┬───────────┬───────────┬──────────────────────────────────────┐\033[0;0m\n"
    printf "\033[0;90m│\033[1;37m Service                                  \033[0;90m│\033[1;37m State      \033[0;90m│\033[1;37m Exit code \033[0;90m│\033[1;37m Health    \033[0;90m│\033[1;37m Message                              \033[0;90m│\033[0;0m\n"
    printf "\033[0;90m├──────────────────────────────────────────┼────────────┼───────────┼───────────┼──────────────────────────────────────┤\033[0;0m\n"

    run_docker_compose ps --all --format json --no-trunc |
        while IFS= read -r line; do
            # The name of the service - 40 characters max
            service="$(echo "${line}" | jq -r .Service)"

            # The status of the service - the longest is 'restarting' at 10 characters
            state="$(echo "${line}" | jq -r .State)"

            # The exit code - 9 characters for the header
            exit_code="$(echo "${line}" | jq -r .ExitCode)"

            # A status message - 15 characters max
            status="$(echo "${line}" | jq -r .Status)"

            health="$(echo "${line}" | jq -r .Health)"
            
            if [[ "${#status}" -gt 36 ]]; then
                status="$(echo "${status}" | cut -c 1-33)..."
            fi

            state_color=""
            case "${state}" in
                "created")
                    state_color="\033[0;34m"
                    ;;
                "dead")
                    state_color="\033[0;31m"
                    ;;
                "exited")
                    if [[ "${exit_code}" -eq "0" ]]; then
                        state_color="\033[0;32m"
                    else
                        state_color="\033[0;31m"
                    fi
                    ;;
                "paused")
                    state_color="\033[0;33m"
                    ;;
                "restarting")
                    state_color="\033[0;34m"
                    ;;
                "running")
                    state_color="\033[0;32m"
                    ;;
                *)
                    ;;
            esac

            exit_code_color=""
            case "${exit_code}" in
                "0")
                    exit_code_color="\033[0;32m"
                    ;;
                *)
                    exit_code_color="\033[0;31m"
                    ;;
            esac

            health_color=""
            case "${health}" in
                "healthy")
                    health_color="\033[0;32m"
                    ;;
                "starting")
                    health_color="\033[0;34m"
                    ;;
                *)
                    health_color="\033[0;31m"
                    ;;
            esac

            printf "\033[0;90m│\033[0;0m %-40s \033[0;90m│ ${state_color}%-10s \033[0;90m│ ${exit_code_color}%-9s \033[0;90m│ ${health_color}%-9s \033[0;90m│ %-36s \033[0;90m│\033[0;0m\n" "${service}" "${state}" "${exit_code}" "${health}" "${status}"
        done

    printf "\033[0;90m└──────────────────────────────────────────┴────────────┴───────────┴───────────┴──────────────────────────────────────┘\033[0;0m\n"
}

# Public functions
# --------------------------------------------------------------------------------------------------

function run_docker_compose {
    local current_project_directory
    current_project_directory="$(get_current_project_directory)"

    local docker_compose_relative_path
    docker_compose_relative_path="$(require_config_value DX_SCRIPTS_DOCKER_COMPOSE_RELATIVE_PATH)"

    local additional_args
    additional_args="$(get_config_value DX_SCRIPTS_DOCKER_COMPOSE_ADDITIONAL_ARGS)"

    local docker_compose_path="${current_project_directory}/${docker_compose_relative_path}"

    local env_path
    env_path="${current_project_directory}/.env"

    if [[ ! -f "${docker_compose_path}" ]]; then
        die "Docker Compose file '${docker_compose_path}' does not exist"
    fi

    if ! grep -qiE '^COMPOSE_PROJECT_NAME=' "${env_path}"; then
        die "COMPOSE_PROJECT_NAME is not set in '${env_path}' - please add it to prevent conflicts with other Docker compose projects"
    fi

    (
        # We explicitly want additional_args to be tokenized
        # shellcheck disable=SC2086
        cd "${current_project_directory}" &&
        docker compose \
            --file "${docker_compose_path}" \
            --env-file "${env_path}" \
            ${additional_args} \
            "${@}"
    )
}

function is_docker_compose_project_running {
    # shellcheck disable=SC2310
    if [[ -n "$(run_docker_compose ps --quiet || true)" ]]; then
        return 0
    else
        return 1
    fi
}

function docker_clean_volumes {
    local prefix
    prefix="$(require_config_value "COMPOSE_PROJECT_NAME")"

    # Make sure the project is not running
    if is_docker_compose_project_running; then
        log_error "Docker Compose project is running - please stop it before cleaning up volumes"
        return 1
    fi

    # Get the list of volumes to remove
    if ! capture_command_output docker volume ls --filter "name=${prefix}*" --quiet; then
        # This is set by capture_command_output
        # shellcheck disable=SC2154
        return "${CAPTURE_EXIT_STATUS}"
    fi

    local volumes_to_remove
    # This is set by capture_command_output
    # shellcheck disable=SC2154
    volumes_to_remove="${CAPTURE_STDOUT}"

    # Confirm with the user
    log_info "The following Docker volumes will be removed:"

    printf "%s" "${volumes_to_remove}" | while read -r volume_name; do
        log_info "  ${volume_name}"
    done

    confirm_user_consent_safe "Are you sure you want to remove them?"

    # Remove them
    printf "%s" "${volumes_to_remove}" | while read -r volume_name; do
        log_info "Removing Docker volume '${volume_name}'..."
        docker volume rm -f "${volume_name}"
    done
}

function docker_compose_down {
    local container_name="${1:-}"

    if [[ -z "${container_name}" ]]; then
        log_info "Bringing down all Docker containers..."
        run_docker_compose down --remove-orphans
    else
        log_info "Bringing down Docker container '${container_name}'..."
        run_docker_compose down --remove-orphans "${container_name}"
    fi
}

function docker_compose_up {
    local container_name="${1:-}"

    log_info "Pulling Docker images..."

    run_docker_compose pull

    log_info "Building Docker images..."

    run_docker_compose build
    
    if [[ -z "${container_name}" ]]; then
        log_info "Bringing up all Docker containers..."
        run_docker_compose up --detach
    else
        log_info "Bringing up Docker container '${container_name}'..."
        run_docker_compose up --detach "${container_name}"
    fi
}

function docker_compose_restart {
    local container_name="${1:-}"

    docker_compose_down "${container_name}"
    docker_compose_up "${container_name}"
}

function tail_docker_compose_logs {
    local container_name="${1:-}"

    if [[ -z "${container_name}" ]]; then
        log_info "Tailing logs for all Docker containers..."
        run_docker_compose logs --follow
    else
        log_info "Tailing logs for Docker container '${container_name}'..."
        run_docker_compose logs --follow "${container_name}"
    fi
}

function exec_docker_compose_shell {
    local container_name="${1}"
    local command="${2:-}"

    if run_docker_compose exec -it "${container_name}" 'test -f /bin/bash' 2>&1 >/dev/null; then
        # Run BASH if we have it
        if [[ -z "${command}" ]]; then
            run_docker_compose exec -it "${container_name}" /bin/bash
        else
            run_docker_compose exec -it "${container_name}" /bin/bash -c "${command}"
        fi
    else
        # Otherwise, fall back to whatever /bin/sh is
        if [[ -z "${command}" ]]; then
            run_docker_compose exec -it "${container_name}" /bin/sh
        else
            run_docker_compose exec -it "${container_name}" /bin/sh -c "${command}"
        fi
    fi
}

function print_docker_compose_status {
    if [[ "$(tput cols || true)" -lt 120 ]]; then
        die_error "Please resize your terminal to at least 100 columns wide"
    fi

    # We do this so that it doesn't print slowly
    local output
    output="$(_format_docker_compose_status)"

    printf "%b\n" "${output}"
}

function watch_docker_compose_status {
    if [[ "$(tput cols || printf "0" || true)" -lt 120 ]]; then
        die_error "Please resize your terminal to at least 100 columns wide"
    fi

    local output

    while true; do
        output="$(_format_docker_compose_status)"
        clear
        printf "%b\n\n\033[0;90mLast updated %s (updates every 5 seconds)\033[0;0m\n" "${output}" "$(date "+%H:%M:%S %Z" || true)"
        sleep 5
    done
}
