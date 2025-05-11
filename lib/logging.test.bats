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

. "./lib/logging.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
}

@test "log_info > success" {
    run log_info "Test message"
    
    assert_output --partial "Test message"
    assert_output --partial "info"
    assert_success
}

@test "log_info > lowercase" {
    run log_info "test message"
    
    assert_output --partial "Log messages must start with a capital letter: 'test message'"
    assert_failure
}

@test "log_info > end with period" {
    run log_info "Test message."
    
    assert_output --partial "Log messages must not end with a period '.': 'Test message.'"
    assert_failure
}

@test "log_warning > success" {
    run log_warning "Test message"
    
    assert_output --partial "Test message"
    assert_output --partial "warning"
    assert_success
}

@test "log_warning > lowercase" {
    run log_warning "test message"
    
    assert_output --partial "Log messages must start with a capital letter: 'test message'"
    assert_failure
}

@test "log_warning > end with period" {
    run log_warning "Test message."
    
    assert_output --partial "Log messages must not end with a period '.': 'Test message.'"
    assert_failure
}

@test "log_error > success" {
    run log_error "Test message"
    
    assert_output --partial "Test message"
    assert_output --partial "error"
    assert_success
}

@test "log_error > lowercase" {
    run log_error "test message"
    
    assert_output --partial "Log messages must start with a capital letter: 'test message'"
    assert_failure
}

@test "log_error > end with period" {
    run log_error "Test message."
    
    assert_output --partial "Log messages must not end with a period '.': 'Test message.'"
    assert_failure
}

@test "die" {
    run die "Test message"
    
    assert_output --partial "Test message"
    assert_output --partial "error"
    assert_failure
}

@test "run_steps > none" {
    run run_steps
    
    assert_output ""
    assert_success
}

@test "run_steps > one enabled" {
    function step_1 {
        case "${1}" in
            "title")
                printf "Step 1 title"
                ;;
            "enabled")
                printf "true"
                ;;
            "run")
                printf "Executed step 1"
                ;;
            *)
                die "Invalid argument: ${1}"
                ;;
        esac
    }

    run run_steps \
        step_1 \
    ;
    
    assert_output --partial "1/1"
    assert_output --partial "Step 1 title"
    assert_output --partial "Executed step 1"
    assert_success
}

@test "run_steps > one disabled" {
    function step_1 {
        case "${1}" in
            "title")
                printf "Step 1 title"
                ;;
            "enabled")
                printf "false"
                ;;
            "run")
                printf "Executed step 1"
                ;;
            *)
                die "Invalid argument: ${1}"
                ;;
        esac
    }

    run run_steps \
        step_1 \
    ;
    
    assert_output ""
    assert_success
}

@test "run_steps > two enabled" {
    function step_1 {
        case "${1}" in
            "title")
                printf "Step 1 title"
                ;;
            "enabled")
                printf "true"
                ;;
            "run")
                printf "Executed step 1"
                ;;
            *)
                die "Invalid argument: ${1}"
                ;;
        esac
    }

    function step_2 {
        case "${1}" in
            "title")
                printf "Step 2 title"
                ;;
            "enabled")
                printf "true"
                ;;
            "run")
                printf "Executed step 2"
                ;;
            *)
                die "Invalid argument: ${1}"
                ;;
        esac
    }

    run run_steps \
        step_1 \
        step_2 \
    ;
    
    assert_output --partial "1/2"
    assert_output --partial "Step 1 title"
    assert_output --partial "Executed step 1"
    assert_output --partial "2/2"
    assert_output --partial "Step 2 title"
    assert_output --partial "Executed step 2"
    assert_success
}

@test "run_steps > two steps, first disabled" {
    function step_1 {
        case "${1}" in
            "title")
                printf "Step 1 title"
                ;;
            "enabled")
                printf "false"
                ;;
            "run")
                printf "Executed step 1"
                ;;
            *)
                die "Invalid argument: ${1}"
                ;;
        esac
    }

    function step_2 {
        case "${1}" in
            "title")
                printf "Step 2 title"
                ;;
            "enabled")
                printf "true"
                ;;
            "run")
                printf "Executed step 2"
                ;;
            *)
                die "Invalid argument: ${1}"
                ;;
        esac
    }

    run run_steps \
        step_1 \
        step_2 \
    ;
    
    assert_output --partial "1/1"
    assert_output --partial "Step 2 title"
    assert_output --partial "Executed step 2"
    assert_success
}
