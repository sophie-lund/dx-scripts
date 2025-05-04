#!/usr/bin/env bats

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

. "./lib/aws.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
    load "../external/bats-file/load.bash"

    TEST_TEMP_DIR="$(temp_make)"
}

function teardown {
    temp_del "${TEST_TEMP_DIR}"
}

@test "aws_list_profiles > no config file" {
    DX_SCRIPTS_AWS_CONFIG_PATH="${TEST_TEMP_DIR}/does-not-exist"
    
    run list_aws_environment_names "test-"

    assert_failure
}

@test "aws_list_profiles > empty config file" {
    DX_SCRIPTS_AWS_CONFIG_PATH="${TEST_TEMP_DIR}/empty"

    touch "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    
    run list_aws_environment_names "test-"

    assert_failure
}

@test "aws_list_profiles > file with profile with wrong prefix" {
    DX_SCRIPTS_AWS_CONFIG_PATH="${TEST_TEMP_DIR}/wrong-prefix"

    printf "[profile test2-test]\n" > "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_session = test\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_account_id = 000000000000\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_role_name = AdministratorAccess\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "region = us-east-1\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "[sso-session test]\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_start_url = https://d-0000000000.awsapps.com/start/#" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_region = us-east-1\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_registration_scopes = sso:account:access\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"

    run list_aws_environment_names "test-"

    assert_failure
}

@test "aws_list_profiles > file with profile with right prefix" {
    DX_SCRIPTS_AWS_CONFIG_PATH="${TEST_TEMP_DIR}/right-prefix"

    printf "[profile test-test]\n" > "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_session = test\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_account_id = 000000000000\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_role_name = AdministratorAccess\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "region = us-east-1\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "[sso-session test]\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_start_url = https://d-0000000000.awsapps.com/start/#" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_region = us-east-1\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_registration_scopes = sso:account:access\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"

    run list_aws_environment_names "test-"

    assert_success
    assert_output "test"
}

@test "aws_list_profiles > file with profile with multiple environments" {
    DX_SCRIPTS_AWS_CONFIG_PATH="${TEST_TEMP_DIR}/multiple-environments"

    printf "[profile test-development]\n" > "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_session = test\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_account_id = 000000000000\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_role_name = AdministratorAccess\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "region = us-east-1\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "[profile test-production]\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_session = test\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_account_id = 000000000000\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_role_name = AdministratorAccess\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "region = us-east-1\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "[sso-session test]\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_start_url = https://d-0000000000.awsapps.com/start/#" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_region = us-east-1\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"
    printf "sso_registration_scopes = sso:account:access\n" >> "${DX_SCRIPTS_AWS_CONFIG_PATH}"

    run list_aws_environment_names "test-"

    assert_success
    printf 'development\nproduction' | assert_output
}
