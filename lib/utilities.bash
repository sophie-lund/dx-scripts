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

# Check if this script has already been sourced
if [[ -n "${SCRIPT_DIRECTORY_UTILITIES:-}" ]]; then
    return 0
fi

# Get the directory of the current script
SCRIPT_DIRECTORY_UTILITIES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_UTILITIES

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

. "${SCRIPT_DIRECTORY_UTILITIES}/logging.bash"
. "${SCRIPT_DIRECTORY_UTILITIES}/prompts.bash"

# Public functions
# --------------------------------------------------------------------------------------------------

function print_output_on_error {
    local tempfile
    tempfile="$(mktemp)" || return

    if ! "$@" > "${tempfile}" 2>&1; then
        cat "${tempfile}"
        rm -f "${tempfile}"
        return 1
    fi

    rm -f "${tempfile}"
}

function capture_command_output {
    local tempfile
    tempfile="$(mktemp)" || return

    CAPTURE_EXIT_STATUS=0
    "$@" > "${tempfile}" || CAPTURE_EXIT_STATUS="${?}"
    export CAPTURE_EXIT_STATUS

    # Disable warning because this is used outside this function
    # shellcheck disable=SC2034
    CAPTURE_STDOUT="$(cat "${tempfile}")"
    export CAPTURE_STDOUT
    
    rm -f "${tempfile}"

    if [[ "${CAPTURE_EXIT_STATUS}" -ne 0 ]]; then
        return "${CAPTURE_EXIT_STATUS}"
    fi
}

function get_current_project_directory {
    if [[ -n "${DX_SCRIPTS_PROJECT_DIRECTORY:-}" ]]; then
        printf "%s" "${DX_SCRIPTS_PROJECT_DIRECTORY}"
        return 0
    fi

    local current_directory="${SCRIPT_DIRECTORY_UTILITIES}"

    while true; do
        if [[ -d "${current_directory}/.git" ]]; then
            git rev-parse --show-superproject-working-tree --show-toplevel | head -1
            return 0
        fi

        if [[ "${current_directory}" != "/" ]]; then
            current_directory="$(realpath "${current_directory}/..")"
        else
            break
        fi
    done

    log_error "Script at '${SCRIPT_DIRECTORY_UTILITIES}' is not within a project directory"
    log_info "Please make sure there is a Git repository in the parent directories"
    exit 1
}

function clean_git_ignored {
    local project_directory
    project_directory="$(get_current_project_directory)"

    if [[ -z "${project_directory}" ]]; then
        log_error "Could not find the project directory"
        return 1
    fi

    local output
    output="$(cd "${project_directory}" && git clean -ndX)"

    if [[ -n "${output}" ]]; then
        log_warning "The following files are ignored by Git and will be removed:"

        printf "%s\n" "${output}" | while read -r line; do
            if [[ -z "${line}" ]]; then
                continue
            fi

            if [[ "${line}" == "Would remove "* ]]; then
                line="${line#Would remove }"
            fi

            printf "  %q\n" "${line}"
        done

        confirm_user_consent_safe "Are you sure you want to remove these files?"

        (cd "${project_directory}" && git clean -qfdX)

        log_info "Clean successful"
    else
        log_info "Nothing to clean"
    fi
}
