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

# Run tests (note that this skips slow tests, run 'test-all' to run those as well)
test *forwarded_args:
    #!/usr/bin/env bash
    set -eu
    
    ./external/bats-core/bin/bats lib --filter-tags '!slow' {{forwarded_args}}

# Run all tests including slow ones
test-all *forwarded_args:
    #!/usr/bin/env bash
    set -eu
    
    ./external/bats-core/bin/bats lib {{forwarded_args}}

# Run linting
lint *forwarded_args:
    #!/usr/bin/env bash
    set -eu
    
    shellcheck ./lib/*.bash {{forwarded_args}}

build-book:
    #!/usr/bin/env bash
    set -eu
    
    (cd "docs" && mkdocs build)

serve-book:
    #!/usr/bin/env bash
    set -eu
    
    (cd "docs" && mkdocs serve)
