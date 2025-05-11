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

# Adding DX Scripts to your project

## Add the Git submodule

The first step is to add it as a submodule. It's recommended to place it under `scripts/dx-scripts` like this, but not required:

```bash
mkdir -p scripts

git submodule add https://github.com/sophie-lund/dx-scripts.git scripts/dx-scripts
```

Then, add this line to your `.gitmodules` file:

```ini hl_lines="4"
[submodule "scripts/dx-scripts"]
	path = scripts/dx-scripts
	url = https://github.com/sophie-lund/dx-scripts.git
	fetchRecurseSubmodules = no-recurse-submodules
```

This will prevent Git from also fetching DX Scripts' submodules which are not needed for consumers of DX Scripts and will just clutter up your repository.

## Write a bootstrap script

Instead of giving instructions on what dependencies to install, just add a `bootstrap.bash` script and tell users to run that!

Here is an example of a simple script:

```bash
#!/bin/bash

# Source the relevant libraries in DX Scripts
. "scripts/dx-scripts/lib/bootstrap.bash"
. "scripts/dx-scripts/lib/dependencies.bash"

ensure_dependencies_installed \
    dependency_xcode_cli_tools \
    dependency_git \
    dependency_homebrew \
    dependency_just \
;
```

Here's a breakdown of what's going on:

 * We source two library files:
    * [`bootstrap.bash`](../reference//bootstrap.md): This gives us [`ensure_dependencies_installed`](../reference/bootstrap.md#ensure_dependencies_installed) which we can use to make sure certain dependencies are installed.
    * [`dependencies.bash`](../reference//dependencies.md): This gives us the actual dependencies like `dependency_xcode_cli_tools` and `dependency_git`. These are included definitions for how to automatically install those dependencies on the user's system.

 * We call [`ensure_dependencies_installed`](../reference/bootstrap.md#ensure_dependencies_installed) which does the work of actually installing those dependencies.

You can do more or less anything in this script. Take a look at DX Scripts' [`bootstrap.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/bootstrap.bash) for an example - it's a bit more complex, but not by much.
