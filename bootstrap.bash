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

# Get the directory of the current script
SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY

# Set flags
set -o errexit # abort on nonzero exit status
set -o nounset # abort on unbound variable
set -o pipefail # don't hide errors within pipes

# Ensure that the script is not sourced and is run as a command
if [[ "$0" != "${BASH_SOURCE[0]}" ]]; then
    printf "error: script cannot be sourced\n"
    exit 1
fi

# Source dependencies
# --------------------------------------------------------------------------------------------------

. "${SCRIPT_DIRECTORY}/lib/bootstrap.bash"
. "${SCRIPT_DIRECTORY}/lib/dependencies.bash"

# Main function
# --------------------------------------------------------------------------------------------------

function main {
    dependencies=(
        dependency_xcode_cli_tools
        dependency_git
        dependency_homebrew
    )

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        dependencies+=(
            dependency_docker
        )
    fi

    dependencies+=(
        dependency_pipx
        dependency_mkdocs
        dependency_just
        dependency_shellcheck
    )

    ensure_dependencies_installed "${dependencies[@]}"

    log_info "Pulling submodules..."

    git submodule update --init --recursive

    log_info "Bootstrapping complete"

    printf "\n"
    printf "Run \033[1;37mjust --list\033[0;0m to see a list of recipes that you can run to get started\n"
    printf "\n"
}

main
