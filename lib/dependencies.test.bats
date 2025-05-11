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

. "./lib/dependencies.bash"

function setup {
    load "../external/bats-support/load.bash"
    load "../external/bats-assert/load.bash"
}

@test "all dependencies > smoke" {
    for dependency in \
        dependency_xcode_cli_tools \
        dependency_xcode \
        dependency_git \
        dependency_homebrew \
        dependency_nvm \
        dependency_node \
        dependency_go \
        dependency_jq \
        dependency_pulumi \
        dependency_cocoapods \
        dependency_docker \
        dependency_aws_cli \
        dependency_cmake \
        dependency_pipx \
        dependency_doxygen \
        dependency_mkdocs \
        dependency_lcov \
        dependency_just \
        dependency_shellcheck \
    ; do
        run "${dependency}" get-name
        assert_success

        run "${dependency}" list-dependencies
        assert_success

        run "${dependency}" check-enabled
        assert_output --regexp "true|false"
        assert_success

        run "${dependency}" check-installed
        assert_output --regexp "true|false"
        assert_success

        run "${dependency}" get-install-command
        assert_success

        run "${dependency}" get-brew-formula
        assert_success

        run "${dependency}" get-fallback-instructions-url
        assert_success

        run "${dependency}" get-fallback-instructions
        assert_success
    done
}
