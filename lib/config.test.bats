#!/usr/bin/env bats

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

. "./lib/config.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
}

@test "get_config_value > success" {
    run get_config_value "TEST"

    assert_success
    assert_output "hello, world"
}

@test "get_config_value > failure" {
    run get_config_value "TEST2"

    assert_success
    assert_output ""
}

@test "require_config_value > success" {
    run require_config_value "TEST"

    assert_success
    assert_output "hello, world"
}

@test "require_config_value > failure" {
    run require_config_value "TEST2"

    assert_failure
}
