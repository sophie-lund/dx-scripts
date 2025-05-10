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

. "./lib/docker.bash"
. "./lib/dependency-predicates.bash"

# bats file_tags=slow

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
    load "../external/bats-file/load.bash"

    TEST_TEMP_DIR="$(temp_make)"

    printf "services:\n" > "${TEST_TEMP_DIR}/docker-compose.yml"
    printf "  test-service:\n" >> "${TEST_TEMP_DIR}/docker-compose.yml"
    printf "    image: alpine\n" >> "${TEST_TEMP_DIR}/docker-compose.yml"
    printf "    command: tail -f /dev/null\n" >> "${TEST_TEMP_DIR}/docker-compose.yml"
    printf "\n" >> "${TEST_TEMP_DIR}/docker-compose.yml"
    printf "volumes:\n" >> "${TEST_TEMP_DIR}/docker-compose.yml"
    printf "  test-volume:\n" >> "${TEST_TEMP_DIR}/docker-compose.yml"

    local chars=abcdefghijklmnopqrstuvwxyz
    PROJECT_NAME="$(for i in {1..16}; do printf "%s" "${chars:RANDOM%${#chars}:1}"; done)"
}

function teardown {
    if is_docker_compose_project_running "docker-compose.yml"; then
        docker_compose_down "docker-compose.yml"
    fi

    temp_del "${TEST_TEMP_DIR}"
}

@test "run_docker_compose > no .env file" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        run run_docker_compose "docker-compose.yml" version

        assert_failure
    fi
}

@test "run_docker_compose > with .env file but without COMPOSE_PROJECT_NAME" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        printf 'TEST=hello, world\n' > "${TEST_TEMP_DIR}/.env"

        run run_docker_compose "docker-compose.yml" version

        assert_failure
    fi
}

@test "run_docker_compose > with .env file with COMPOSE_PROJECT_NAME" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        printf "COMPOSE_PROJECT_NAME=\"${PROJECT_NAME}\"\n" > "${TEST_TEMP_DIR}/.env"

        run run_docker_compose "docker-compose.yml" version

        assert_success
    fi
}

@test "docker_compose_up > all up" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        printf "COMPOSE_PROJECT_NAME=\"${PROJECT_NAME}\"\n" > "${TEST_TEMP_DIR}/.env"

        run is_docker_compose_project_running "docker-compose.yml"

        assert_failure

        run docker_compose_up "docker-compose.yml"

        assert_success

        run is_docker_compose_project_running "docker-compose.yml"

        assert_success

        run exec_docker_compose_shell "docker-compose.yml" "test-service" "exit 0"

        assert_success
    fi
}

@test "docker_compose_up > one up" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        printf "COMPOSE_PROJECT_NAME=\"${PROJECT_NAME}\"\n" > "${TEST_TEMP_DIR}/.env"

        run is_docker_compose_project_running "docker-compose.yml"

        assert_failure

        run docker_compose_up "docker-compose.yml" "test-service"

        assert_success

        run is_docker_compose_project_running "docker-compose.yml"

        assert_success
    fi
}

@test "docker_compose_up > restart all" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        printf "COMPOSE_PROJECT_NAME=\"${PROJECT_NAME}\"\n" > "${TEST_TEMP_DIR}/.env"

        run is_docker_compose_project_running "docker-compose.yml"

        assert_failure

        run docker_compose_up "docker-compose.yml"

        assert_success

        run is_docker_compose_project_running "docker-compose.yml"

        assert_success

        run docker_compose_restart "docker-compose.yml"

        assert_success

        run is_docker_compose_project_running "docker-compose.yml"

        assert_success
    fi
}

@test "docker_compose_up > restart one" {
    export DX_SCRIPTS_PROJECT_DIRECTORY="${TEST_TEMP_DIR}"

    if ! (is_macos && [[ -n "${GITHUB_ACTIONS:-}" ]]); then
        printf "COMPOSE_PROJECT_NAME=\"${PROJECT_NAME}\"\n" > "${TEST_TEMP_DIR}/.env"

        run is_docker_compose_project_running "docker-compose.yml"

        assert_failure

        run docker_compose_up "docker-compose.yml"

        assert_success

        run is_docker_compose_project_running "docker-compose.yml"

        assert_success

        run docker_compose_restart "docker-compose.yml" "test-service"

        assert_success

        run is_docker_compose_project_running "docker-compose.yml"

        assert_success
    fi
}
