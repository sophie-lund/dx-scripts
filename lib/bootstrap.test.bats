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

. "./lib/bootstrap.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
}

@test "ensure_dependencies_installed > one already installed" {
    function dependency_test {
        case "${1}" in
            "get-name")
                printf "Test"
                ;;
            "check-enabled")
                printf "true"
                ;;
            "check-installed")
                printf "true"
                ;;
            "get-install-command")
                ;;
            "get-brew-formula")
                ;;
            "get-fallback-instructions-url")
                ;;
            "get-fallback-instructions")
                ;;
            *)
                die "Unknown command for dependency: '${1}'"
                ;;
        esac
    }

    run ensure_dependencies_installed dependency_test

    assert_output --partial "Test is ready"
    assert_success
}

@test "ensure_dependencies_installed > one disabled" {
    function dependency_test {
        case "${1}" in
            "get-name")
                printf "Test"
                ;;
            "check-enabled")
                printf "false"
                ;;
            "list-dependencies")
                ;;
            "check-installed")
                printf "true"
                ;;
            "get-install-command")
                ;;
            "get-brew-formula")
                ;;
            "get-fallback-instructions-url")
                ;;
            "get-fallback-instructions")
                ;;
            *)
                die "Unknown command for dependency: '${1}'"
                ;;
        esac
    }

    run ensure_dependencies_installed dependency_test

    assert_output ""
    assert_success
}


@test "ensure_dependencies_installed > install command" {
    function dependency_test {
        case "${1}" in
            "get-name")
                printf "Test"
                ;;
            "check-enabled")
                printf "true"
                ;;
            "check-installed")
                printf "false"
                ;;
            "get-install-command")
                printf "printf 'DUMMY'"
                ;;
            "get-brew-formula")
                ;;
            "get-fallback-instructions-url")
                ;;
            "get-fallback-instructions")
                ;;
            *)
                die "Unknown command for dependency: '${1}'"
                ;;
        esac
    }

    run bats_pipe printf "y\n" \| ensure_dependencies_installed dependency_test

    assert_output --partial "Test must be installed for this project to work"
    assert_output --partial "You can install it by running this command:"
    assert_output --partial "printf 'DUMMY'"
    assert_output --partial "Would you like to run this command now?"
    assert_output --partial "[Y/n]"
    assert_output --partial " DUMMY"
    assert_success
}

@test "ensure_dependencies_installed > brew formula" {
    if is_macos; then
        function dependency_test {
            case "${1}" in
                "get-name")
                    printf "Test"
                    ;;
                "check-enabled")
                    printf "true"
                    ;;
                "check-installed")
                    printf "false"
                    ;;
                "get-install-command")
                    ;;
                "get-brew-formula")
                    # This is a quick to install formula that is suitable for testing
                    printf "ncurses"
                    ;;
                "get-fallback-instructions-url")
                    ;;
                "get-fallback-instructions")
                    ;;
                *)
                    die "Unknown command for dependency: '${1}'"
                    ;;
            esac
        }

        run ensure_dependencies_installed dependency_test

        assert_output --partial "Installing Homebrew formulae: ncurses"
        assert_success
    fi
}

@test "ensure_dependencies_installed > fallback instructions url" {
    function dependency_test {
        case "${1}" in
            "get-name")
                printf "Test"
                ;;
            "check-enabled")
                printf "true"
                ;;
            "check-installed")
                printf "false"
                ;;
            "get-install-command")
                ;;
            "get-brew-formula")
                ;;
            "get-fallback-instructions-url")
                printf "https://example.com"
                ;;
            "get-fallback-instructions")
                ;;
            *)
                die "Unknown command for dependency: '${1}'"
                ;;
        esac
    }

    run ensure_dependencies_installed dependency_test

    assert_output --partial "Test must be installed for this project to work"
    assert_output --partial "Please follow these instructions and re-run this setup:"
    assert_output --partial "https://example.com"
    assert_failure
}

@test "ensure_dependencies_installed > fallback instructions" {
    function dependency_test {
        case "${1}" in
            "get-name")
                printf "Test"
                ;;
            "check-enabled")
                printf "true"
                ;;
            "check-installed")
                printf "false"
                ;;
            "get-install-command")
                ;;
            "get-brew-formula")
                ;;
            "get-fallback-instructions-url")
                ;;
            "get-fallback-instructions")
                printf "DUMMY"
                ;;
            *)
                die "Unknown command for dependency: '${1}'"
                ;;
        esac
    }

    run ensure_dependencies_installed dependency_test

    assert_output --partial "Test must be installed for this project to work"
    assert_output --partial "DUMMY"
    assert_output --partial "Then, please re-run this setup."
    assert_failure
}
