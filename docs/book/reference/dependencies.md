<!--
Copyright 2025 Sophie Lund

This file is part of DX Scripts.

DX Scripts is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

DX Scripts is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along with DX Scripts. If not, see
<https://www.gnu.org/licenses/>.
-->

# Dependencies

To use the dependencies library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/dependencies.bash"
```

See [`dependencies.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/dependencies.bash) for the full implementations of these functions.

## What is a dependency?

Dependencies are functions that are called by [`ensure_dependencies_installed`](./bootstrap.md#ensure_dependencies_installed). Each function represents a dependency that is required for the project to work correctly. They provide information about how they should be checked and installed if they are not already.

They should be functions of the form:

```bash
function dependency_<name> {
    case "${1:-}" in
        "get-name")
            # Print the human-readable name of the dependency.
            printf "My dependency"
            ;;
        "dependencies")
            # Print a space-separated list of any dependencies that this
            # dependency in turn relies on.
            #
            # They should match the function names of the other dependencies.
            printf "dependency_a dependency_b"
            ;;
        "check-enabled")
            # Print either "true" or "false" if the dependency is enabled.
            #
            # You can print "false" here if the dependency is not required
            # for the current system.
            printf "true"
            ;;
        "check-installed")
            # Print "true" if the dependency is already installed, or
            # "false" otherwise.
            printf "false"
            ;;
        "get-install-command")
            # Print a command that can be used to install the dependency
            # on the current system.
            #
            # Do not print anything if such a command does not exist.
            printf "some command"
            ;;
        "get-brew-formula")
            # Print the name of the Homebrew formula that can be used to
            # install the dependency on macOS.
            #
            # Do not print anything if such a formula does not exist.
            printf "some-formula"
            ;;
        "get-apt-package")
            # Print the name of the APT package that can be used to
            # install the dependency on Debian-based systems.
            #
            # Do not print anything if such a package does not exist.
            printf "some-package"
            ;;
        "get-fallback-instructions-url")
            # Print the URL of instructions for how to install this dependency.
            #
            # Do not print anything if such a URL does not exist.
            printf "https://example.com/install"
            ;;
        "get-fallback-instructions")
            # Print any fallback instructions that should be printed if the
            # dependency cannot be installed automatically.
            #
            # Do not print anything if such instructions do not exist.
            printf "Please install this dependency manually."
            ;;
        *)
            die "Unknown command for dependency: '${1}'"
            ;;
    esac
}
```

## Dependencies that are available

See [`dependencies.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/dependencies.bash) for a full list.
