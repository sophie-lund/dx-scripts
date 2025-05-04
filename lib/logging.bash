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
SCRIPT_DIRECTORY_LOGGING="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# This is used by other scripts to check if this script has been sourced
# shellcheck disable=SC2034
readonly SCRIPT_DIRECTORY_LOGGING

# Set flags
set -o errexit # abort on nonzero exit status
set -o nounset # abort on unbound variable
set -o pipefail # don't hide errors within pipes

# Ensure that the script is sourced, not being run in its own shell
if [[ "$0" = "${BASH_SOURCE[0]}" ]]; then
    printf "error: script must be sourced\n"
    exit 1
fi

# Private functions
# --------------------------------------------------------------------------------------------------

# These should all be prefixed with '_'

# Print a log message with a configurable severity to stderr.
#
# Arguments:
#   severity -- The string to represent the severity level
#   color    -- The color escape code to use for the severity level
#   message  -- The message to print
function _log_with_severity {
    local severity="${1}"
    local color="${2}"
    local message="${3}"

    if printf "%s" "${message}" | grep -qE "^[a-z].+"; then
        die "Log messages must start with a capital letter: '${message}'"
    fi

    if printf "%s" "${message}" | grep -qE "[^.]\\.$"; then
        die "Log messages must not end with a period '.': '${message}'"
    fi

    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

    printf "\033[0;90m[%s]\033[0;0m %b[%s]\033[0;0m \033[1m%s\033[0;0m\n" "${timestamp}" "${color}" "${severity}" "${message}" >&2
}

# Public functions
# --------------------------------------------------------------------------------------------------

# Logs information.
#
# Arguments:
#   message -- The message to log
function log_info {
    local message="${1}"

    _log_with_severity "info" "\033[1;32m" "${message}"
}

# Logs a warning.
#
# Arguments:
#   message -- The message to log
function log_warning {
    local message="${1}"

    _log_with_severity "warning" "\033[1;33m" "${message}"
}

# Logs an error.
#
# Arguments:
#   message -- The message to log
function log_error {
    local message="${1}"

    _log_with_severity "error" "\033[1;31m" "${message}"
}

# Logs an error and exits the script with exit status 1.
#
# Arguments:
#   message -- The message to log
function die {
    local message="${1}"

    log_error "${message}"
    exit 1
}

# Runs a series of steps in order, logging the results.
#
# Arguments:
#   steps... -- The steps to run.
#
# Each step is a function that is called. It must be of this form:
#
# function step_<name> {
#     case "$1" in
#         "title")
#             printf "<title>"
#             ;;
#         "enabled")
#             printf "true"
#             ;;
#         "run")
#             # ...
#             ;;
#     esac
# }
function run_steps {
    # Filter steps to only those that are enabled
    local steps_filtered=()
    for step in "$@"; do
        local enabled
        enabled="$(${step} enabled)"
        case "${enabled}" in
            "true")
                steps_filtered+=("${step}")
                ;;
            "false")
                ;;
            *)
                die "Step '${step}' returned an invalid value for enabled check '${enabled}' - allowed are 'true' and 'false'"
                ;;
        esac
    done

    if [[ ${#steps_filtered[@]} -eq 0 ]]; then
        return 0
    fi

    # Execute the steps
    local index=1
    for step in "${steps_filtered[@]}"; do
        if [[ "$(type -t "${step}" || true)" != "function" ]]; then
            die "Step '${step}' is not a function"
        fi

        _log_with_severity "${index}/${#steps_filtered[@]}" "\033[1;36m" "$(${step} title || true)"
        ${step} run

        index="$((index + 1))"
    done
}
