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
if [[ -n "${SCRIPT_DIRECTORY_DEPENDENCY_PREDICATES:-}" ]]; then
    return 0
fi

# Get the directory of the current script
SCRIPT_DIRECTORY_DEPENDENCY_PREDICATES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_DEPENDENCY_PREDICATES

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

. "${SCRIPT_DIRECTORY_DEPENDENCY_PREDICATES}/utilities.bash"

# Public functions
# --------------------------------------------------------------------------------------------------

function is_linux {
    if [[ "$(uname -s || true)" == "Linux" ]]; then
        return 0
    fi

    return 1
}

function is_macos {
    if [[ "$(uname -s || true)" == "Darwin" ]]; then
        return 0
    fi

    return 1
}

function is_host_os_supported {
    if [[ -z "${1:-}" ]]; then
        die "No OS specified as argument - allowed are: linux, macos"
    fi

    for os in "$@"; do
        case "${os}" in
            "linux")
                if is_linux; then
                    return 0
                fi
                ;;
            "macos")
                if is_macos; then
                    return 0
                fi
                ;;
            *)
                die "Unknown OS '${os}' - allowed are: linux, macos"
                ;;
        esac
    done

    return 1
}

function does_command_exist {
    local command="${1}"

    if command -v "${command}" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function are_xcode_cli_tools_installed {
    if ! is_macos; then
        die "This function is only supported on macOS"
    fi

    if [[ -d "$(xcode-select -p 2>/dev/null || true)" ]]; then
        return 0
    else
        return 1
    fi
}

function is_xcode_installed {
    if ! is_macos; then
        die "This function is only supported on macOS"
    fi

    if xcodebuild -version > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function try_get_nvm_directory {
    if [[ -n "${NVM_DIR:-}" ]]; then
        printf "%s" "${NVM_DIR}"
    elif [[ -d "${HOME}/.nvm" ]]; then
        printf "%s/.nvm" "${HOME}"
    fi
}

function is_nvm_installed {
    if [[ -n "$(try_get_nvm_directory || true)" ]] && [[ -f "$(try_get_nvm_directory || true)/nvm.sh" ]]; then
        return 0
    else
        return 1
    fi
}

function is_docker_compose_2x_installed {
    if ! does_command_exist docker; then
        return 1
    fi

    if ! docker compose version > /dev/null 2>&1; then
        return 1
    fi

    return 0
}

function are_docker_engine_metrics_enabled {
    if [[ -n "$(curl --max-time 2 --silent "http://localhost:9323/metrics" | grep --ignore-case engine_daemon_engine_info 2>/dev/null || true)" ]]; then
        return 0
    else
        return 1
    fi
}
