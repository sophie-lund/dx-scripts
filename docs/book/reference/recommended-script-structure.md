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

# Recommended script structure

Putting this at the top of your scripts is recommended in order to follow BASH scripting best practices:

```bash
#!/bin/bash

# Standard prelude - put this at the top of all scripts
# --------------------------------------------------------------------------------------------------

# Get the directory of the current script
SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIRECTORY

# Set flags
set -o errexit # abort on nonzero exit status
set -o nounset # abort on unbound variable
set -o pipefail # don't hide errors within pipes

# Ensure that the script is not sourced and is run as a command
if [[ "$0" != "${BASH_SOURCE[0]}" ]]; then
    printf "error: script cannot be sourced\n"
    exit 1
fi

# Source dependencies
# --------------------------------------------------------------------------------------------------

# ...

# Main function
# --------------------------------------------------------------------------------------------------

function main {
    # ...
}

main
```

See the [other pages](./logging.md) in the reference guide for what to put in the `# Source dependencies` section. See [`bootstrap.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/bootstrap.bash) for a full example of a script that uses this structure.

## Justfiles

If you are using [Just](https://just.systems/), then it is recommended to structure your recipes like this:

```makefile
example:
    #!/usr/bin/env bash
    set -eu
    
    [[ -z "${SCRIPT_DIRECTORY_LOGGING:-}" ]] && \
        . "./scripts/dx-scripts/lib/logging.bash"

    log_info "Hello, world"
```

This assumes that you have [`dx-scripts`](https://github.com/sophie-lund/dx-scripts) cloned in your project at `scripts/dx-scripts` - which is recommended as well. See [`justfile`](https://github.com/sophie-lund/dx-scripts/blob/main/justfile) for a full example of a Justfile that uses this structure.
