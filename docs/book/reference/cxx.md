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

# C++

To use the C++ library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/cxx.bash"
```

See [`cxx.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/cxx.bash) for the full implementations of these functions.

## `build_cxx`

=== "Description"

    Builds a C++ project. That uses CMake and Conan 2. It requires that:

     * There is a `conanfile.txt` file in the source directory.
     * There is a `CMakeLists.txt` file in the source directory.

=== "Usage"

    **Usage:** `build_cxx <macro prefix> <source directory> <build directory> [build mode]`

    **Options:**

    * `<macro prefix>`: The prefix for macros that are used to configure the project. This function will build the C++ project with these macros defined:
          * `<macro prefix>_BUILD_TESTS` to either `1` or `0` depending on whether tests will be compiled.
          * `<macro prefix>_BUILD_DEMOS` to either `1` or `0` depending on whether the demos will be compiled.
          * `<macro prefix>_ENABLE_COVERAGE` to either `1` or `0` depending on whether coverage instrumentation is enabled.
    * `<source directory>`: The directory containing the source code.
    * `<build directory>`: The directory to build the project in. This directory will be created if it does not exist.
    * `[build mode]`: The build mode to use. This is optional and defaults to `Release`. The available modes are:
        * `debug`: A build with debug symbols and no optimizations.
        * `debug:coverage`: A build with debug symbols, no optimizations, and coverage instrumentation.
        * `debug:fuzz`: A build with debug symbols, no optimizations, and fuzzing instrumentation.
        * `release`: A build with no debug symbols and optimizations enabled.

=== "Return codes"

    It will return 0 if the build was successful and a non-zero value if it was not.

=== "Errors"

    It should not throw any errors unless there is an internal problem with this function.
