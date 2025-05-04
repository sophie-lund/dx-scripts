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
[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && . "${SCRIPT_DIRECTORY_BOOTSTRAP}/prompts.bash"
[[ -z "${SCRIPT_DIRECTORY_DEPENDENCY_PREDICATES:-}" ]] && . "${SCRIPT_DIRECTORY_BOOTSTRAP}/dependency-predicates.bash"
[[ -z "${SCRIPT_DIRECTORY_DEPENDENCIES:-}" ]] && . "${SCRIPT_DIRECTORY_BOOTSTRAP}/dependencies.bash"

# Public functions
# --------------------------------------------------------------------------------------------------

# Installs a series of dependencies in order.
#
# Arguments:
#   dependencies... -- The dependencies to install.
#
# Each dependency is a function that is called. It must be of this form:
#
# function dependency_<name> {
#     case "$1" in
#         "get-name")
#             printf "<name>"
#             ;;
#         "dependencies")
#             printf "<dependency1> <dependency2>"
#             ;;
#         "check-enabled")
#             printf "true"
#             ;;
#         "check-installed")
#             printf "true"
#             ;;
#         "get-install-command")
#             printf "<command>"
#             ;;
#         "get-brew-formula")
#             printf "<formula>"
#             ;;
#         "get-fallback-instructions-url")
#             printf "<url>"
#             ;;
#         "get-fallback-instructions")
#             printf "<instructions>"
#             ;;
#     esac
# }
function ensure_dependencies_installed {
    # Check for dependency order
    local dependencies_so_far=()
    for dependency in "$@"; do
        if [[ "${#dependencies_so_far[@]}" -gt 0 ]] && [[ " ${dependencies_so_far[@]} " =~ [[:space]]"${dependency}"[[:space]] ]]; then
            die "Dependency '${dependency}' is listed multiple times"
        fi

        for sub_dependency in $(${dependency} list-dependencies); do
            if [[ "${#dependencies_so_far[@]}" -gt 0 ]] && [[ " ${dependencies_so_far[@]} " =~ [[:space]]"${sub_dependency}"[[:space]] ]]; then
                die "Dependency '${dependency}' depends on '${sub_dependency}' which was not listed before '${dependency}'"
            fi
        done
    done

    # Filter dependencies to only those that are enabled
    local dependencies_filtered=()
    for dependency in "$@"; do
        local enabled
        enabled="$(${dependency} check-enabled)"
        case "${enabled}" in
            "true")
                dependencies_filtered+=("${dependency}")
                ;;
            "false")
                ;;
            *)
                die "Dependency '${dependency}' returned an invalid value for enabled check '${enabled}' - allowed are 'true' and 'false'"
                ;;
        esac
    done

    # If no dependencies are enabled, return early
    if [[ ${#dependencies_filtered[@]} -eq 0 ]]; then
        return 0
    fi

    # Create arrays to aggregate bulk operations
    brew_formulae=()

    # Install the dependencies
    for dependency in "${dependencies_filtered[@]}"; do
        # Get the name of the dependency
        local name
        name="$(${dependency} get-name || true)"

        if [[ -z "${name}" ]]; then
            die "Dependency '${dependency}' returned an empty name"
        fi

        # Check if it is already ready
        local check_installed
        check_installed="$(${dependency} check-installed || true)"

        case "${check_installed}" in
            "true")
                log_info "${name} is ready"
                continue
                ;;
            "false")
                ;;
            *)
                die "Dependency '${dependency}' returned an invalid value for 'check-installed' '${check_installed}' - allowed are 'true' and 'false'"
                ;;
        esac

        # Extract the different install methods
        local install_command
        install_command="$(${dependency} get-install-command || true)"
        
        local brew_formula
        if is_macos; then
            brew_formula="$(${dependency} get-brew-formula || true)"
        else
            brew_formula=""
        fi
        
        local fallback_instructions_url
        fallback_instructions_url="$(${dependency} get-fallback-instructions-url || true)"
        
        local fallback_instructions
        fallback_instructions="$(${dependency} get-fallback-instructions || true)"

        # If there is an install command, run it
        if [[ -n "${install_command}" ]]; then
            log_error "${name} must be installed for this project to work"
            printf "\n"
            printf "You can install it by running this command:\n"
            printf "\n"
            printf "  \033[0;90m\$\033[0;0m %s\n" "${install_command}"
            printf "\n"

            confirm_user_consent_safe "Would you like to run this command now?"

            if ! eval "${install_command}"; then
                die "Error while installing ${name}"
            fi
        
        # If there is a Homebrew formula, add it to the list
        elif [[ -n "${brew_formula}" ]]; then
            brew_formulae+=("${brew_formula}")
        
        # If there is a fallback instructions URL, print it
        elif [[ -n "${fallback_instructions_url}" ]]; then
            log_error "${name} must be installed for this project to work"
            printf "\n"
            printf "Please follow these instructions and re-run this setup:\n"
            printf "\n"
            printf "%s\n" "${fallback_instructions_url}"
            printf "\n"
            exit 1

        # If there are fallback instructions, print them
        elif [[ -n "${fallback_instructions}" ]]; then
            log_error "${name} must be installed for this project to work"
            printf "\n"
            printf "%s\n" "${fallback_instructions}"
            printf "\n"
            printf "Then, please re-run this setup.\n"
            printf "\n"
            exit 1
        else
            die "Dependency '${dependency}' does not have any installation methods provided"
        fi
    done

    # Install Homebrew formulae if any were found
    if [[ ${#brew_formulae[@]} -gt 0 ]]; then
        log_info "Installing Homebrew formulae: ${brew_formulae[*]}"
        
        if ! brew install "${brew_formulae[@]}"; then
            die "Error while installing Homebrew formulae"
        fi
    fi
}

function ensure_aws_profile_configured {
    local sso_session_name="${1}"
    local sso_start_url="${2}"
    local sso_region="${3}"
    local role_name="${4}"
    local account_name="${5}"
    local profile_name="${6}"

    local error_message=""
    local aws_config_path="${HOME}/.aws/config"

    if [[ ! -f "${aws_config_path}" ]]; then
        error_message="AWS CLI config file not found at ${aws_config_path}"
    elif ! grep -q "sso-session ${sso_session_name}" "${aws_config_path}"; then
        error_message="AWS CLI config file does not contain an SSO session named '${sso_session_name}'"
    elif ! grep -q "profile ${profile_name}" "${aws_config_path}"; then
        error_message="AWS CLI config file does not contain a profile named '${profile_name}'"
    fi

    if [[ -n "${error_message}" ]]; then
        log_error "${error_message}"
        printf "\n"
        printf "You can create it by running this command:\n"
        printf "\n"
        printf "  \033[0;90m\$\033[0;0m aws configure sso\n"
        printf "\n"
        printf "... with these inputs:\n"
        printf "\n"
        printf "\n  SSO session name: \033[1;37m%s\033[0;0m\n" "${sso_session_name}"
        printf "\n  SSO start URL: \033[1;37m%s\033[0;0m\n" "${sso_start_url}"
        printf "\n  SSO region: \033[1;37m%s\033[0;0m\n" "${sso_region}"
        printf "\n  SSO registration scopes: \033[0;90m(leave blank)\033[0;0m\n"
        printf "\n"
        printf "  Choose the account: \033[1;37m%s\033[0;0m\n" "${account_name}"
        printf "  Choose the role: \033[1;37m%s\033[0;0m\n" "${role_name}"
        printf "\n"
        printf "  CLI default client region: \033[1;37m%s\033[0;0m\n" "${sso_region}"
        printf "  CLI default output format: \033[0;90m(leave blank)\033[0;0m\n"
        printf "  CLI profile name: \033[1;37m%s\033[0;0m\n" "${profile_name}"
        printf "\n"

        confirm_user_consent_safe "Would you like to run this command now?"

        printf "\n"
        printf "Enter in the values above!\n"
        printf "\n"

        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_DEFAULT_REGION
        unset AWS_ENDPOINT_URL
        
        aws configure sso
    fi
}

function ensure_etc_hosts_entries_configured {
    local hosts_to_add=()

    for host in "$@"; do
        if ! grep -qE "${host}\$" /etc/hosts; then
            hosts_to_add+=("${host}")
        fi
    done

    if [[ ${#hosts_to_add[@]} -eq 0 ]]; then
        return 0
    fi

    log_error "These lines are required in your '/etc/hosts' file for this project to work:"

    printf "\n"

    for host in "${hosts_to_add[@]}"; do
        printf "127.0.0.1       %s\n" "${host}"
    done

    printf "\n"
    printf "Please add them and re-run this setup.\n"
    printf "\n"

    exit 1
}
