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

. "./lib/dependency-predicates.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
}

@test "is_linux > smoke" {
    run is_linux

    assert_output ""
}

@test "is_macos > smoke" {
    run is_macos

    assert_output ""
}

@test "at least one OS check is true" {
    run is_macos || is_linux

    assert_output ""
    assert_success
}

@test "is_host_os_supported > smoke" {
    run is_host_os_supported macos

    assert_output ""
}

@test "is_host_os_supported > all" {
    run is_host_os_supported macos linux

    assert_output ""
    assert_success
}

@test "does_command_exist > success" {
    run does_command_exist "ls"

    assert_success
    assert_output ""
}

@test "does_command_exist > failure" {
    run does_command_exist "this-command-does-not-exist"

    assert_failure
    assert_output ""
}

@test "are_xcode_cli_tools_installed > smoke" {
    if is_macos; then
        run are_xcode_cli_tools_installed

        assert_output ""
    fi
}

@test "is_xcode_installed > smoke" {
    if is_macos; then
        run is_xcode_installed

        assert_output ""
    fi
}

@test "try_get_nvm_directory > smoke" {
    run try_get_nvm_directory

    assert_success
}

@test "is_nvm_installed > smoke" {
    run is_nvm_installed

    assert_output ""
}

@test "is_docker_compose_2x_installed > smoke" {
    run is_docker_compose_2x_installed

    assert_output ""
}

@test "are_docker_engine_metrics_enabled > smoke" {
    run are_docker_engine_metrics_enabled

    assert_output ""
}
