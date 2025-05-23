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
if [[ -n "${SCRIPT_DIRECTORY_CONFIG:-}" ]]; then
    return 0
fi

# Get the directory of the current script
SCRIPT_DIRECTORY_CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_CONFIG

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

. "${SCRIPT_DIRECTORY_CONFIG}/utilities.bash"
. "${SCRIPT_DIRECTORY_CONFIG}/logging.bash"

# Private functions
# --------------------------------------------------------------------------------------------------

# These should all be prefixed with '_'

function _load_config_into_env {
    local current_project_directory
    current_project_directory="$(get_current_project_directory)"

    local env_path
    env_path="${current_project_directory}/.env"

    if [[ -f "${env_path}" ]]; then
        set -o allexport
        # Disable warning because dynamic paths cannot be resolved
        # shellcheck disable=SC1090
        source "${env_path}"
        set +o allexport
    fi

    IS_CONFIG_LOADED=true
}

# Public functions
# --------------------------------------------------------------------------------------------------

function get_config_value {
    local key="${1}"
    local default="${2:-}"

    if [[ -z "${IS_CONFIG_LOADED:-}" ]]; then
        _load_config_into_env
    fi

    local variable_value="${!key:-${default}}"

    printf "%s" "${variable_value}"
}

function require_config_value {
    local key="${1}"

    local variable_value
    variable_value="$(get_config_value "${key}" || true)"

    if [[ -z "${variable_value}" ]]; then
        die "Configuration value '${key}' is not set - please add it to '$(get_current_project_directory || true)/.env'"
    fi

    printf "%s" "${variable_value}"
}
