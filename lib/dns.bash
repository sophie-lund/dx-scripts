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
SCRIPT_DIRECTORY_BOOTSTRAP="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_BOOTSTRAP

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

[[ -z "${SCRIPT_DIRECTORY_UTILITIES:-}" ]] && . "${SCRIPT_DIRECTORY_BOOTSTRAP}/utilities.bash"
[[ -z "${SCRIPT_DIRECTORY_LOGGING:-}" ]] && . "${SCRIPT_DIRECTORY_BOOTSTRAP}/logging.bash"
[[ -z "${SCRIPT_DIRECTORY_DEPENDENCY_PREDICATES:-}" ]] && . "${SCRIPT_DIRECTORY_BOOTSTRAP}/dependency-predicates.bash"

# Private functions
# --------------------------------------------------------------------------------------------------

# These should all be prefixed with '_'

function _flush_dns_cache_macos {
    if ! sudo dnscacheutil -flushcache; then
        die "Failed to flush DNS cache"
    fi

    if ! sudo killall -HUP mDNSResponder; then
        die "Failed to flush DNS cache"
    fi

    log_info "Successfully flushed DNS cache"
}

function _flush_dns_cache_linux {
    if ! does_command_exist systemctl; then
        die "Automatic flushing for DNS cache on Linux distros without systemctl is not yet supported"
    fi

    if ! sudo systemctl restart systemd-resolved; then
        die "Failed to flush DNS cache"
    fi

    log_info "Successfully flushed DNS cache"
}

# Public functions
# --------------------------------------------------------------------------------------------------

function flush_dns_cache {
    if is_macos; then
        _flush_dns_cache_macos
    elif is_linux; then
        _flush_dns_cache_linux
    else
        die "Automatic flushing for DNS cache on this OS is not yet supported"
    fi
}
