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
if [[ -n "${SCRIPT_DIRECTORY_DEPENDENCIES:-}" ]]; then
    return 0
fi

# Get the directory of the current script
SCRIPT_DIRECTORY_DEPENDENCIES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_DEPENDENCIES

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

. "${SCRIPT_DIRECTORY_DEPENDENCIES}/utilities.bash"
. "${SCRIPT_DIRECTORY_DEPENDENCIES}/logging.bash"
. "${SCRIPT_DIRECTORY_DEPENDENCIES}/prompts.bash"

# Public functions
# --------------------------------------------------------------------------------------------------

function dependency_xcode_cli_tools {
    case "${1}" in
        "get-name")
            printf "Xcode CLI tools"
            ;;
        "list-dependencies")
            ;;
        "check-enabled")
            if is_macos; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "check-installed")
            if are_xcode_cli_tools_installed; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            printf "xcode-select --install"
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_xcode {
    case "${1}" in
        "get-name")
            printf "Xcode desktop app"
            ;;
        "list-dependencies")
            ;;
        "check-enabled")
            if is_macos; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "check-installed")
            if is_xcode_installed; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            printf "Please install it from the App Store."
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_git {
    case "${1}" in
        "get-name")
            printf "Git"
            ;;
        "list-dependencies")
            printf "dependency_xcode_cli_tools"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist git; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            printf "git-all"
            ;;
        "get-fallback-instructions-url")
            printf "https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_homebrew {
    case "${1}" in
        "get-name")
            printf "Homebrew"
            ;;
        "list-dependencies")
            printf "dependency_xcode_cli_tools"
            ;;
        "check-enabled")
            if is_macos; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "check-installed")
            if does_command_exist brew; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            printf "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_nvm {
    case "${1}" in
        "get-name")
            printf "NVM"
            ;;
        "list-dependencies")
            printf "dependency_xcode_cli_tools"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if is_nvm_installed; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            printf "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_node {
    case "${1}" in
        "get-name")
            printf "Node.JS"
            ;;
        "list-dependencies")
            printf "dependency_nvm"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist node; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            local node_version="--lts"
            if [[ -f "$(get_current_project_directory || true)/.nvmrc" ]]; then
                node_version="$(cat "$(get_current_project_directory || true)/.nvmrc" || true)"
            fi

            printf ". \"%s/nvm.sh\" && nvm install %s" "$(try_get_nvm_directory || true)" "${node_version}"
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_go {
    case "${1}" in
        "get-name")
            printf "Go"
            ;;
        "list-dependencies")
            printf "dependency_xcode_cli_tools"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist go; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            printf "https://golang.org/doc/install"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_jq {
    case "${1}" in
        "get-name")
            printf "jq"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist jq; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "jq"
            ;;
        "get-apt-package")
            printf "jq"
            ;;
        "get-fallback-instructions-url")
            printf "https://jqlang.github.io/jq/download/"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_pulumi {
    case "${1}" in
        "get-name")
            printf "Pulumi"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist pulumi; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "pulumi/tap/pulumi"
            ;;
        "get-fallback-instructions-url")
            printf "https://www.pulumi.com/docs/iac/download-install/"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_cocoapods {
    case "${1}" in
        "get-name")
            printf "Cocoapods"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            if is_macos; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "check-installed")
            if does_command_exist pod; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "cocoapods"
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_docker {
    case "${1}" in
        "get-name")
            printf "Docker"
            ;;
        "list-dependencies")
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist docker; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            printf "https://docs.docker.com/desktop/"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_aws_cli {
    case "${1}" in
        "get-name")
            printf "AWS CLI v2"
            ;;
        "list-dependencies")
            printf "dependency_xcode_cli_tools"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist aws; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            printf "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_cmake {
    case "${1}" in
        "get-name")
            printf "CMake"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist cmake; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "cmake"
            ;;
        "get-apt-package")
            printf "cmake"
            ;;
        "get-fallback-instructions-url")
            printf "%s" "https://cmake.org/cmake/help/book/mastering-cmake/chapter/Getting%20Started.html"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_pipx {
    case "${1}" in
        "get-name")
            printf "Pipx"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist pipx; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            if is_macos; then
                printf "brew install pipx && pipx ensurepath"
            elif is_linux; then
                printf "apt install pipx && pipx ensurepath"
            fi
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            printf "https://pipx.pypa.io/stable/installation/"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_conan {
    case "${1}" in
        "get-name")
            printf "Conan"
            ;;
        "list-dependencies")
            printf "dependency_pipx"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist conan; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            printf "pipx install conan"
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_doxygen {
    case "${1}" in
        "get-name")
            printf "Doxygen"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist doxygen; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "doxygen"
            ;;
        "get-apt-package")
            printf "doxygen"
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            printf "Please search for how to install Doxygen on your OS."
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_mkdocs {
    case "${1}" in
        "get-name")
            printf "MkDocs"
            ;;
        "list-dependencies")
            printf "dependency_pipx"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist mkdocs; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            printf "pipx install mkdocs && pipx inject mkdocs mkdocs-material"
            ;;
        "get-brew-formula")
            ;;
        "get-apt-package")
            ;;
        "get-fallback-instructions-url")
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_lcov {
    case "${1}" in
        "get-name")
            printf "LCOV"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist lcov; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "lcov"
            ;;
        "get-apt-package")
            printf "lcov"
            ;;
        "get-fallback-instructions-url")
            printf "https://lcov.readthedocs.io/en/latest/"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_just {
    case "${1}" in
        "get-name")
            printf "Just"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist just; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "just"
            ;;
        "get-apt-package")
            printf "just"
            ;;
        "get-fallback-instructions-url")
            printf "https://github.com/casey/just?tab=readme-ov-file#packages"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}

function dependency_shellcheck {
    case "${1}" in
        "get-name")
            printf "ShellCheck"
            ;;
        "list-dependencies")
            printf "dependency_homebrew"
            ;;
        "check-enabled")
            printf "true"
            ;;
        "check-installed")
            if does_command_exist shellcheck; then
                printf "true"
            else
                printf "false"
            fi
            ;;
        "get-install-command")
            ;;
        "get-brew-formula")
            printf "shellcheck"
            ;;
        "get-apt-package")
            printf "shellcheck"
            ;;
        "get-fallback-instructions-url")
            printf "https://github.com/koalaman/shellcheck#user-content-installing"
            ;;
        "get-fallback-instructions")
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}
