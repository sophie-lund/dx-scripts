#!/bin/bash

# Copyright 2025 Sophie Lund
#
# This file is part of Sophie's DX Scripts.
#
# Sophie's DX Scripts is free software: you can redistribute it and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Sophie's DX Scripts is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Sophie's DX Scripts.
# If not, see <https://www.gnu.org/licenses/>.

# Standard prelude - put this at the top of all scripts
# --------------------------------------------------------------------------------------------------

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

# Check if the scripts have already been sourced using their 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_UTILITIES:-}" ]] && . "${SCRIPT_DIRECTORY_CONFIG}/utilities.bash"
[[ -z "${SCRIPT_DIRECTORY_LOGGING:-}" ]] && . "${SCRIPT_DIRECTORY_CONFIG}/logging.bash"

# Private functions
# --------------------------------------------------------------------------------------------------

# These should all be prefixed with '_'

function _load_config_into_env {
    local current_project_directory
    current_project_directory="$(get_current_project_directory)"

    local env_path
    env_path="${current_project_directory}/${DX_SCRIPTS_ENV_FILENAME:-".env"}"

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

# Gets a configuration value from the environment.
#
# It will load the .env file from the project directory if it hasn't been loaded yet. It will print
# nothing to stdout if the key is not set in the environment.
#
# Arguments:
#   key -- The key to look up in the configuration - this is the same as the name of the environment
#          variable.
function get_config_value {
    local key="${1}"

    if [[ -z "${IS_CONFIG_LOADED:-}" ]]; then
        _load_config_into_env
    fi

    local variable_value="${!key:-}"

    printf "%s" "${variable_value}"
}

# Gets a configuration value from the environment and dies if it is not set.
#
# See 'get_config_value' for more information.
#
# Errors:
#   It will die if the key is not set in the environment.
function require_config_value {
    local key="${1}"

    local variable_value
    variable_value="$(get_config_value "${key}" || true)"

    if [[ -z "${variable_value}" ]]; then
        die "Configuration value '${key}' is not set - please add it to '$(get_current_project_directory || true)/.env'"
    fi

    printf "%s" "${variable_value}"
}
