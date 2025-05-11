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

. "./lib/utilities.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
    load "../external/bats-file/load.bash"

    TEST_TEMP_DIR="$(temp_make)"
}

function teardown {
    temp_del "${TEST_TEMP_DIR}"
}

@test "print_output_on_error > success" {
    run print_output_on_error ls /

    assert_success
    assert_output ""
}

@test "print_output_on_error > error, no output" {
    run print_output_on_error exit 1

    assert_failure
    assert_output ""
}

@test "print_output_on_error > error, with stdout" {
    run print_output_on_error bash -c 'printf 'dummy' && exit 1'

    assert_failure
    assert_output "dummy"
}

@test "print_output_on_error > error, with stderr" {
    run print_output_on_error bash -c 'printf 'dummy' >&2 && exit 1'

    assert_failure
    assert_output "dummy"
}

@test "capture_command_output > success, no output" {
    capture_command_output bash -c 'exit 0'

    assert_equal "${CAPTURE_EXIT_STATUS}" 0
    assert_equal "${CAPTURE_STDOUT}" ""
}

@test "capture_command_output > success, with stdout" {
    capture_command_output printf 'dummy'

    assert_equal "${CAPTURE_EXIT_STATUS}" 0
    assert_equal "${CAPTURE_STDOUT}" "dummy"
}

@test "capture_command_output > success, with stderr" {
    capture_command_output bash -c 'printf 'dummy' >&2'

    assert_equal "${CAPTURE_EXIT_STATUS}" 0
    assert_equal "${CAPTURE_STDOUT}" ""
}

@test "capture_command_output > failure, no output" {
    set +e # this is needed unfortunately
    capture_command_output bash -c 'exit 3'
    set -e

    assert_equal "${CAPTURE_EXIT_STATUS}" 3
    assert_equal "${CAPTURE_STDOUT}" ""
}

@test "capture_command_output > failure, with stdout" {
    set +e # this is needed unfortunately
    capture_command_output bash -c 'printf 'dummy' && exit 3'
    set -e

    assert_equal "${CAPTURE_EXIT_STATUS}" 3
    assert_equal "${CAPTURE_STDOUT}" "dummy"
}

@test "capture_command_output > failure, with stderr" {
    set +e # this is needed unfortunately
    capture_command_output bash -c 'printf 'dummy' >&2 && exit 3'
    set -e

    assert_equal "${CAPTURE_EXIT_STATUS}" 3
    assert_equal "${CAPTURE_STDOUT}" ""
}

@test "get_current_project_directory > smoke" {
    run get_current_project_directory

    assert_success
    assert_output "$(pwd)"
}

@test "get_current_project_directory > env override" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="/tmp"

    run get_current_project_directory

    assert_success
    assert_output "/tmp"
}

@test "clean_git_ignored > nothing to clean" {
    (
        cd "${TEST_TEMP_DIR}"
        git init
        git config user.email "example@example.com"
        git config user.name "Example"
        git branch -m main
        touch not-ignored
        git add not-ignored
        git commit -m "initial commit"
    )

    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    run clean_git_ignored

    assert_output --partial "Nothing to clean"
    assert_success

    rm -rf "${TEST_TEMP_DIR}/.git"
}

@test "clean_git_ignored > clean one file" {
    (
        cd "${TEST_TEMP_DIR}"
        git init
        git config user.email "example@example.com"
        git config user.name "Example"
        git branch -m main
        touch not-ignored
        echo 'ignored' > .gitignore
        git add not-ignored
        git add .gitignore
        git commit -m "initial commit"
        touch ignored
    )

    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    run bats_pipe printf "y\n" \| clean_git_ignored

    assert_output --partial "The following files are ignored by Git and will be removed:"
    assert_output --partial "  ignored"
    assert_output --partial "Are you sure you want to remove these files?"
    assert_output --partial "Y/n"
    assert_output --partial "Clean successful"
    assert_success

    assert [ ! -f "${TEST_TEMP_DIR}/ignored" ]
    assert [ -f "${TEST_TEMP_DIR}/not-ignored" ]

    rm -rf "${TEST_TEMP_DIR}/.git"
}
