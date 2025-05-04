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

. "./lib/dependencies.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
}

@test "dependency_xcode_cli_tools > smoke" {
    run dependency_xcode_cli_tools get-name
    assert_success

    run dependency_xcode_cli_tools check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_xcode_cli_tools check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_xcode_cli_tools get-install-command
    assert_success

    run dependency_xcode_cli_tools get-brew-formula
    assert_success

    run dependency_xcode_cli_tools get-fallback-instructions-url
    assert_success

    run dependency_xcode_cli_tools get-fallback-instructions
    assert_success
}

@test "dependency_xcode > smoke" {
    run dependency_xcode get-name
    assert_success

    run dependency_xcode check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_xcode check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_xcode get-install-command
    assert_success

    run dependency_xcode get-brew-formula
    assert_success

    run dependency_xcode get-fallback-instructions-url
    assert_success

    run dependency_xcode get-fallback-instructions
    assert_success
}

@test "dependency_git > smoke" {
    run dependency_git get-name
    assert_success

    run dependency_git check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_git check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_git get-install-command
    assert_success

    run dependency_git get-brew-formula
    assert_success

    run dependency_git get-fallback-instructions-url
    assert_success

    run dependency_git get-fallback-instructions
    assert_success
}

@test "dependency_homebrew > smoke" {
    run dependency_homebrew get-name
    assert_success

    run dependency_homebrew check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_homebrew check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_homebrew get-install-command
    assert_success

    run dependency_homebrew get-brew-formula
    assert_success

    run dependency_homebrew get-fallback-instructions-url
    assert_success

    run dependency_homebrew get-fallback-instructions
    assert_success
}

@test "dependency_nvm > smoke" {
    run dependency_nvm get-name
    assert_success

    run dependency_nvm check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_nvm check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_nvm get-install-command
    assert_success

    run dependency_nvm get-brew-formula
    assert_success

    run dependency_nvm get-fallback-instructions-url
    assert_success

    run dependency_nvm get-fallback-instructions
    assert_success
}

@test "dependency_node > smoke" {
    run dependency_node get-name
    assert_success

    run dependency_node check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_node check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_node get-install-command
    assert_success

    run dependency_node get-brew-formula
    assert_success

    run dependency_node get-fallback-instructions-url
    assert_success

    run dependency_node get-fallback-instructions
    assert_success
}

@test "dependency_go > smoke" {
    run dependency_go get-name
    assert_success

    run dependency_go check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_go check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_go get-install-command
    assert_success

    run dependency_go get-brew-formula
    assert_success

    run dependency_go get-fallback-instructions-url
    assert_success

    run dependency_go get-fallback-instructions
    assert_success
}

@test "dependency_jq > smoke" {
    run dependency_jq get-name
    assert_success

    run dependency_jq check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_jq check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_jq get-install-command
    assert_success

    run dependency_jq get-brew-formula
    assert_success

    run dependency_jq get-fallback-instructions-url
    assert_success

    run dependency_jq get-fallback-instructions
    assert_success
}

@test "dependency_pulumi > smoke" {
    run dependency_pulumi get-name
    assert_success

    run dependency_pulumi check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_pulumi check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_pulumi get-install-command
    assert_success

    run dependency_pulumi get-brew-formula
    assert_success

    run dependency_pulumi get-fallback-instructions-url
    assert_success

    run dependency_pulumi get-fallback-instructions
    assert_success
}

@test "dependency_cocoapods > smoke" {
    run dependency_cocoapods get-name
    assert_success

    run dependency_cocoapods check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_cocoapods check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_cocoapods get-install-command
    assert_success

    run dependency_cocoapods get-brew-formula
    assert_success

    run dependency_cocoapods get-fallback-instructions-url
    assert_success

    run dependency_cocoapods get-fallback-instructions
    assert_success
}

@test "dependency_docker > smoke" {
    run dependency_docker get-name
    assert_success

    run dependency_docker check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_docker check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_docker get-install-command
    assert_success

    run dependency_docker get-brew-formula
    assert_success

    run dependency_docker get-fallback-instructions-url
    assert_success

    run dependency_docker get-fallback-instructions
    assert_success
}

@test "dependency_aws_cli > smoke" {
    run dependency_aws_cli get-name
    assert_success

    run dependency_aws_cli check-enabled
    assert_output --regexp "true|false"
    assert_success

    run dependency_aws_cli check-installed
    assert_output --regexp "true|false"
    assert_success

    run dependency_aws_cli get-install-command
    assert_success

    run dependency_aws_cli get-brew-formula
    assert_success

    run dependency_aws_cli get-fallback-instructions-url
    assert_success

    run dependency_aws_cli get-fallback-instructions
    assert_success
}
