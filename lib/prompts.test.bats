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

. "./lib/prompts.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
}

@test "confirm_user_consent_neutral > y" {
    run bats_pipe printf "y" \| confirm_user_consent_neutral "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/n"
    refute_output --partial "Invalid response: '"
    assert_success
}

@test "confirm_user_consent_neutral > n" {
    run bats_pipe printf "n" \| confirm_user_consent_neutral "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/n"
    assert_output --partial "User did not consent - exiting..."
    refute_output --partial "Invalid response: '"
    assert_failure
}

@test "confirm_user_consent_neutral > enter" {
    run bats_pipe printf "\ny" \| confirm_user_consent_neutral "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/n"
    refute_output --partial "User did not consent - exiting..."
    assert_output --partial "Invalid response: '"
    assert_success
}

@test "confirm_user_consent_neutral > invalid" {
    run bats_pipe printf "a\ny" \| confirm_user_consent_neutral "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/n"
    refute_output --partial "User did not consent - exiting..."
    assert_output --partial "Invalid response: '"
    assert_success
}

@test "confirm_user_consent_safe > y" {
    run bats_pipe printf "y" \| confirm_user_consent_safe "Test message"

    assert_output --partial "Test message"
    assert_output --partial "Y/n"
    refute_output --partial "Invalid response: '"
    assert_success
}

@test "confirm_user_consent_safe > n" {
    run bats_pipe printf "n" \| confirm_user_consent_safe "Test message"

    assert_output --partial "Test message"
    assert_output --partial "Y/n"
    assert_output --partial "User did not consent - exiting..."
    refute_output --partial "Invalid response: '"
    assert_failure
}

@test "confirm_user_consent_safe > enter" {
    run bats_pipe printf "\n" \| confirm_user_consent_safe "Test message"

    assert_output --partial "Test message"
    assert_output --partial "Y/n"
    refute_output --partial "Invalid response: '"
    assert_success
}

@test "confirm_user_consent_safe > invalid" {
    run bats_pipe printf "a\ny" \| confirm_user_consent_safe "Test message"

    assert_output --partial "Test message"
    assert_output --partial "Y/n"
    refute_output --partial "User did not consent - exiting..."
    assert_output --partial "Invalid response: '"
    assert_success
}

@test "confirm_user_consent_dangerous > y" {
    run bats_pipe printf "y" \| confirm_user_consent_dangerous "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/N"
    refute_output --partial "Invalid response: '"
    assert_success
}

@test "confirm_user_consent_dangerous > n" {
    run bats_pipe printf "n" \| confirm_user_consent_dangerous "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/N"
    assert_output --partial "User did not consent - exiting..."
    refute_output --partial "Invalid response: '"
    assert_failure
}

@test "confirm_user_consent_dangerous > enter" {
    run bats_pipe printf "\n" \| confirm_user_consent_dangerous "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/N"
    assert_output --partial "User did not consent - exiting..."
    refute_output --partial "Invalid response: '"
    assert_failure
}

@test "confirm_user_consent_dangerous > invalid" {
    run bats_pipe printf "a\ny" \| confirm_user_consent_dangerous "Test message"

    assert_output --partial "Test message"
    assert_output --partial "y/N"
    refute_output --partial "User did not consent - exiting..."
    assert_output --partial "Invalid response: '"
    assert_success
}
