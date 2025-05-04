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
SCRIPT_DIRECTORY_AWS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_AWS

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

[[ -z "${SCRIPT_DIRECTORY_UTILITIES:-}" ]] && . "${SCRIPT_DIRECTORY_AWS}/utilities.bash"
[[ -z "${SCRIPT_DIRECTORY_LOGGING:-}" ]] && . "${SCRIPT_DIRECTORY_AWS}/logging.bash"
[[ -z "${SCRIPT_DIRECTORY_CONFIG:-}" ]] && . "${SCRIPT_DIRECTORY_AWS}/config.bash"

# Public functions
# --------------------------------------------------------------------------------------------------

# Lists all AWS profiles in ~/.aws/config that start with the given prefix.
#
# Case insensitive, but it will convert the results to lowercase.
#
# Arguments:
#   prefix -- The prefix to match against the profile names.
#
# Return codes:
#   0 -- The environment names were printed to stdout on separate lines.
#   1 -- There is no AWS config file
#   2 -- No AWS profiles found with the given prefix
function list_aws_environment_names {
    local prefix="${1}"

    local aws_config_path=${DX_SCRIPTS_AWS_CONFIG_PATH:-"${HOME}/.aws/config"}
    
    # If there is no AWS config file, then there are no profiles - return early
    if [[ ! -f "${aws_config_path}" ]]; then
        log_error "No AWS config file found at ${aws_config_path}"
        return 1
    fi

    local results
    results="$(grep -iE "^\[profile ${prefix}" "${aws_config_path}" | sed -E "s/^\[profile ${prefix}(.*)\]/\1/I" | tr '[:upper:]' '[:lower:]')"

    if [[ -z "${results}" ]]; then
        log_error "No AWS profiles found with prefix '${prefix}'"
        return 2
    fi

    # Print the results to stdout
    printf "%s\n" "${results}"
}

# Logs in to AWS using the given environment.
#
# It expects there to be profiles in ~/.aws/config that start with the given prefix, one for each
# possible environment. Case insensitive.
#
# Arguments:
#   prefix      -- The prefix to match against the profile names.
#   environment -- The environment to log in to.
#
# Return codes:
#   0 -- We are not logged in to the environment's AWS profile.
#   1 -- There is no AWS config file (from list_aws_environment_names)
#   2 -- No AWS profiles found with the given prefix (from list_aws_environment_names)
#   3 -- No AWS profile found for the given environment
#   4 -- SSO login failed
function login_to_aws_sso {
    local prefix="${1}"
    local environment="${2}"

    # Do error checking against the list of available environment names
    local environment_names=""
    if capture_command_output list_aws_environment_names "${prefix}"; then
        # This is set by capture_command_output
        # shellcheck disable=SC2154
        environment_names="${CAPTURE_STDOUT}"
    else
        # This is set by capture_command_output
        # shellcheck disable=SC2154
        return "${CAPTURE_EXIT_STATUS}"
    fi

    if ! grep -qiE "^${environment}$" <<< "${environment_names}"; then
        log_error "No AWS profile found for environment '${environment}'"
        return 3
    fi

    # Unset any existing AWS credentials
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_DEFAULT_REGION
    unset AWS_ENDPOINT_URL

    # Log in
    if aws --profile "${prefix}${environment}" sts get-caller-identity > /dev/null 2>&1; then
        log_info "Already logged in to AWS - setting profile to '${prefix}${environment}'"
    else
        aws sso login --profile "${prefix}${environment}" || return 4
    fi

    export AWS_PROFILE="${prefix}${environment}"
}

# Configures AWS to point to a specific endpoint URL.
#
# Arguments:
#   endpoint_url -- The URL of the endpoint to log in to.
#   region       -- The AWS region to use - 'us-east-1' is a sensible default.
function login_to_aws_endpoint {
    local endpoint_url="${1}"
    local region="${2}"

    # Unset any existing AWS credentials
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_DEFAULT_REGION
    unset AWS_ENDPOINT_URL

    # Set environment variables for local endpoint
    export AWS_ACCESS_KEY_ID="dummy"
    export AWS_SECRET_ACCESS_KEY="dummy"
    export AWS_DEFAULT_REGION="${region}"
    export AWS_ENDPOINT_URL="${endpoint_url}"
}
