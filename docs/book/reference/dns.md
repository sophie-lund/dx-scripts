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

# DNS

To use the DNS library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/dns.bash"
```

See [`dns.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/dns.bash) for the full implementations of these functions.

## `flush_dns_cache`

=== "Description"

    Flushes the system DNS cache. It will use `sudo` if it needs root privileges.

    This function supports macOS and Linux systems that use `systemd`.

=== "Usage"

    **Usage:** `flush_dns_cache`

     This function does not take any arguments.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if the command fails.
