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
SCRIPT_DIRECTORY_PROMPTS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_PROMPTS

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

[[ -z "${SCRIPT_DIRECTORY_LOGGING:-}" ]] && . "${SCRIPT_DIRECTORY_PROMPTS}/logging.bash"

# Private functions
# --------------------------------------------------------------------------------------------------

# These should all be prefixed with '_'

function _confirm_user_consent_helper {
    local default="${1}"
    local message_color="${2}"
    local message="${3}"

    if [[ -z "${message_color}" ]]; then
        die "Message color must be provided"
    fi

    if [[ -z "${message}" ]]; then
        die "Message must be provided"
    fi

    while true; do
        printf "%b%s\033[0;0m " "${message_color}" "${message}"

        case "${default}" in
            y|Y)
                printf "[Y/n] "
                ;;
            n|N)
                printf "[y/N] "
                ;;
            *)
                printf "[y/n] "
                ;;
        esac

        read -r response

        if [[ -z "${response}" ]]; then
            response="${default}"
        fi

        case "${response}" in
            y|Y)
                break
                ;;
            n|N)
                die "User did not consent - exiting..."
                ;;
            *)
                log_error "Invalid response: '${response}'"
                ;;
        esac
    done
}

# Public functions
# --------------------------------------------------------------------------------------------------

function confirm_user_consent_neutral {
    local message="$1"

    _confirm_user_consent_helper "" "\033[1;37m" "${message}"
}

function confirm_user_consent_safe {
    local message="$1"

    _confirm_user_consent_helper "y" "\033[1;37m" "${message}"
}

function confirm_user_consent_dangerous {
    local message="$1"

    _confirm_user_consent_helper "n" "\033[1;31m" "${message}"
}
