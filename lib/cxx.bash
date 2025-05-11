#!/bin/bash

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

# Standard prelude - put this at the top of all scripts
# --------------------------------------------------------------------------------------------------

# Check if this script has already been sourced
if [[ -n "${SCRIPT_DIRECTORY_CXX:-}" ]]; then
    return 0
fi

# Get the directory of the current script
SCRIPT_DIRECTORY_CXX="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY_CXX

# Set flags
set -o errexit # abort on nonzero exit status
set -o nounset # abort on unbound variable
set -o pipefail # don't hide errors within pipes

# Ensure that the script is sourced, not being run in its own shell
if [[ "$0" = "${BASH_SOURCE[0]}" ]]; then
    printf "error: script must be sourced\n"
    exit 1
fi

# Source dependencies
# --------------------------------------------------------------------------------------------------

. "${SCRIPT_DIRECTORY_CXX}/utilities.bash"
. "${SCRIPT_DIRECTORY_CXX}/logging.bash"

# Private functions
# --------------------------------------------------------------------------------------------------

# These should all be prefixed with '_'

function _install_conan_dependencies_debug {
    local source_directory="${1}"
    local build_directory="${2}"

    log_info "Installing Conan dependencies with build type Debug"

    if ! conan install "${source_directory}" \
        "--output-folder=${build_directory}" \
        --build=missing \
        --settings=build_type=Debug; then
        return 1
    fi
}

function _install_conan_dependencies_release {
    local source_directory="${1}"
    local build_directory="${2}"

    log_info "Installing Conan dependencies with build type Release"

    if ! conan install "${source_directory}" \
        "--output-folder=${build_directory}" \
        --build=missing \
        --settings=build_type=Release; then
        return 1
    fi
}

function _configure_cmake_debug {
    local macro_prefix="${1}"
    local source_directory="${2}"
    local build_directory="${3}"

    log_info "Configuring CMake build with build type Debug"

    if ! cmake \
        -B "${build_directory}" \
        -S "${source_directory}" \
        -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        "-D${macro_prefix}_BUILD_TESTS=1" \
        "-D${macro_prefix}_BUILD_DEMOS=1" \
        "-D${macro_prefix}_ENABLE_COVERAGE=0" \
        -DFUZZTEST_FUZZING_MODE=off \
        -G Ninja; then
        return 1
    fi
}

function _configure_cmake_debug_coverage {
    local macro_prefix="${1}"
    local source_directory="${2}"
    local build_directory="${3}"

    log_info "Configuring CMake build with build type Debug and coverage enabled"

    if ! cmake \
        -B "${build_directory}" \
        -S "${source_directory}" \
        -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        "-D${macro_prefix}_BUILD_TESTS=1" \
        "-D${macro_prefix}_BUILD_DEMOS=1" \
        "-D${macro_prefix}_ENABLE_COVERAGE=0" \
        -DFUZZTEST_FUZZING_MODE=off \
        -G Ninja; then
        return 1
    fi
}

function _configure_cmake_debug_fuzz {
    local macro_prefix="${1}"
    local source_directory="${2}"
    local build_directory="${3}"

    log_info "Configuring CMake build with build type Debug and fuzzing mode enabled"

    if ! cmake \
        -B "${build_directory}" \
        -S "${source_directory}" \
        -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        "-D${macro_prefix}_BUILD_TESTS=1" \
        "-D${macro_prefix}_BUILD_DEMOS=1" \
        "-D${macro_prefix}_ENABLE_COVERAGE=0" \
        -DFUZZTEST_FUZZING_MODE=on \
        -G Ninja; then
        return 1
    fi
}

function _configure_cmake_release {
    local macro_prefix="${1}"
    local source_directory="${2}"
    local build_directory="${3}"

    log_info "Configuring CMake build with build type Release"
    
    if ! cmake \
        -B "${build_directory}" \
        -S "${source_directory}" \
        -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        "-D${macro_prefix}_BUILD_TESTS=0" \
        "-D${macro_prefix}_BUILD_DEMOS=0" \
        "-D${macro_prefix}_ENABLE_COVERAGE=0" \
        -DFUZZTEST_FUZZING_MODE=off \
        -G Ninja; then
        return 1
    fi
}

function _build_cmake_project {
    local build_directory="${1}"

    log_info "Building project"

    if ! cmake --build "${build_directory}"; then
        return 1
    fi
}

function _require_previous_build_mode {
    local build_directory="${1}"

    if [[ ! -d "${build_directory}" ]]; then
        log_error "When the project has not been built before, you need to specify the build mode"
        printf "\n"
        printf "Build mode can be any of:\n"
        printf "  debug\n"
        printf "  debug:coverage\n"
        printf "  debug:fuzz\n"
        printf "  release\n"
        printf "\n"
        exit 1
    fi

    if [[ ! -f "${build_directory}/.dx-scripts-build-mode" ]]; then
        die "Build directory '${build_directory}' is missing the file '.dx-scripts-build-mode' which this script uses to store the previous build mode"
    fi

    local value
    value="$(cat "${build_directory}/.dx-scripts-build-mode")"

    if [[ -z "${value}" ]]; then
        die "Unable to detect the previous build mode from the file '.dx-scripts-build-mode' in the build directory '${build_directory}'"
    fi

    printf "%s" "${value}"
}

function _run_all_tests_with_prefix {
    local build_directory="${1}"
    local prefix="${2}"

    local file_basename

    log_info "ASDF '${build_directory}'"

    for file in $(find "${build_directory}" -iname "${prefix}" -type f -perm +111 || true); do
        file_basename="$(basename "${file}" || true)"
        
        log_info "Running test: ${file_basename}"
        
        if ! (cd "${build_directory}" && ASAN_OPTIONS=detect_container_overflow=0 "${file}"); then
            die "Test failed: ${file_basename}"
        fi
    done
}

function _generate_coverage_report() {
    local build_directory="${1}"

    if ! lcov \
        --capture \
        --directory "${build_directory}" \
        --output-file "${build_directory}/coverage.info" \
        --erase-functions \
        __cxx_global_var_init \
        --ignore-errors unsupported \
        --rc derive_function_end_line=0; then
        die_error "Failed to gather coverage info"
    fi

	if ! lcov \
        --remove "${build_directory}/coverage.info" \
        '/usr/*' \
        '/opt/*' \
        '*.conan2*' \
        '*/tests/*' \
        '*.test.cpp' \
        '*/_deps/*' \
        --output-file "${build_directory}/coverage.info" \
        --rc derive_function_end_line=0 \
        --ignore-errors unused; then
        die_error "Failed to filter coverage info"
    fi

	if ! genhtml "${build_directory}/coverage.info" \
        --output-directory "${build_directory}/coverage-report" \
        --ignore-errors inconsistent,corrupt,category; then
        die_error "Failed to generate HTML coverage report"
    fi

    log_info "Coverage report available at: file://${build_directory}/coverage-report/index.html"
}

# Public functions
# --------------------------------------------------------------------------------------------------

function build_cxx {
    local macro_prefix="${1}"
    local source_directory="${2}"
    local build_directory="${3}"
    local default_build_mode="${4}"
    local build_mode="${5:-}"

    if [[ -n "${default_build_mode}" ]] && [[ -z "${build_mode}" ]]; then
        build_mode="${default_build_mode}"
    fi

    if [[ -z "${build_mode}" ]]; then
        build_mode="$(_require_previous_build_mode "${build_directory}")"
    fi

    mkdir -p "${build_directory}"
    printf "%s" "${build_mode}" > "${build_directory}/.dx-scripts-build-mode"

    case "${build_mode}" in
        "debug")
            _install_conan_dependencies_debug "${source_directory}" "${build_directory}"
            _configure_cmake_debug "${macro_prefix}" "${source_directory}" "${build_directory}"
            ;;
        "debug:coverage")
            _install_conan_dependencies_debug "${source_directory}" "${build_directory}"
            _configure_cmake_debug_coverage "${macro_prefix}" "${source_directory}" "${build_directory}"
            ;;
        "debug:fuzz")
            _install_conan_dependencies_debug "${source_directory}" "${build_directory}"
            _configure_cmake_debug_fuzz "${macro_prefix}" "${source_directory}" "${build_directory}"
            ;;
        "release")
            _install_conan_dependencies_release "${source_directory}" "${build_directory}"
            _configure_cmake_release "${macro_prefix}" "${source_directory}" "${build_directory}"
            ;;
        *)
            log_error "Invalid build mode '${build_mode}'"
            printf "\n"
            printf "Available are:\n"
            printf "  debug\n"
            printf "  debug:coverage\n"
            printf "  debug:fuzz\n"
            printf "  release\n"
            return 1
            ;;
    esac

    _build_cmake_project "${build_directory}"
}

function test_cxx {
    local macro_prefix="${1}"
    local source_directory="${2}"
    local build_directory="${3}"
    local test_mode="${4}"

    case "${test_mode}" in
        "all")
            build_cxx "${macro_prefix}" "${source_directory}" "${build_directory}" debug
            _run_all_tests_with_prefix "${build_directory}" "test-external"
            _run_all_tests_with_prefix "${build_directory}" "test-unit-*"
            _run_all_tests_with_prefix "${build_directory}" "test-functional-*"
            ;;
        "coverage")
            rm -rf "${build_directory}" || true
            build_cxx "${macro_prefix}" "${source_directory}" "${build_directory}" debug:coverage
            _run_all_tests_with_prefix "${build_directory}" "test-unit-*"
            _run_all_tests_with_prefix "${build_directory}" "test-functional-*"
            _generate_coverage_report "${build_directory}"
            ;;
        "coverage:unit")
            rm -rf "${build_directory}" || true
            build_cxx "${macro_prefix}" "${source_directory}" "${build_directory}" debug:coverage
            _run_all_tests_with_prefix "${build_directory}" "test-unit-*"
            _generate_coverage_report "${build_directory}"
            ;;
        "fuzz")
            build_cxx "${macro_prefix}" "${source_directory}" "${build_directory}" debug:fuzz

            if [[ -z "${test_binary}" ]]; then
                _run_all_tests_with_prefix "${build_directory}" "test-fuzz-*"
            else
                if [[ ! -f "${build_directory}/${test_binary}" ]]; then
                    die "Fuzz test binary '${test_binary}' not found in build directory '${build_directory}'"
                fi

                if [[ -z "${test_filter}" ]]; then
                    die "Fuzz test requires a filter to be specified"
                fi

                ASAN_OPTIONS=detect_container_overflow=0 "${build_directory}/${test_binary}" "--fuzz=${test_filter}" "${@:6}"
            fi
            ;;
        "bench")
            if [[ -z "${test_binary}" ]]; then
                die "Benchmark test requires binary to be specified"
            fi

            build_cxx "${macro_prefix}" "${source_directory}" "${build_directory}"

            if [[ ! -f "${build_directory}/${test_binary}" ]]; then
                die "Benchmark test binary '${test_binary}' not found in build directory '${build_directory}'"
            fi

            ASAN_OPTIONS=detect_container_overflow=0 "${build_directory}/${test_binary}" "${@:5}"
            ;;
        *)
            build_cxx "${macro_prefix}" "${source_directory}" "${build_directory}"

            if [[ ! -f "${build_directory}/${test_binary}" ]]; then
                die "Test binary '${test_binary}' not found in build directory '${build_directory}'"
            fi

            ASAN_OPTIONS=detect_container_overflow=0 "${build_directory}/${test_binary}" "${@:5}"
            ;;
    esac
}
