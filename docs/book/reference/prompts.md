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

# Prompts

To use the prompts library, add this to [`# Source dependencies`](./recommended-script-structure.md) part of your script:

```bash hl_lines="7-8"
# Source dependencies
# --------------------------------------------------------------------------------------------------

# Check if the scripts have already been sourced using their
# 'SCRIPT_DIRECTORY_*' variables

[[ -z "${SCRIPT_DIRECTORY_PROMPTS:-}" ]] && \
    . "${SCRIPT_DIRECTORY}/lib/prompts.bash"
```

See [`prompts.bash`](https://github.com/sophie-lund/dx-scripts/blob/main/lib/prompts.bash) for the full implementations of these functions.

## `confirm_user_consent_neutral`

=== "Description"

    Asks the user to confirm their consent.

    This requires them to type in either `y` or `n` (case insensitive) to confirm their consent. Pressing enter alone will not work.

    ```bash
    $ confirm_user_consent_neutral "Are you sure you want to proceed?"
    Are you sure you want to proceed? [y/n]
    ```

    If the user does not consent, it will simply exit the script with exit code 1 so that you do not have to handle the result with an if statement.

    You can set `DX_SCRIPTS_ALWAYS_CONSENT` to `"true"` to always consent to the prompt. This is useful for testing or if you want to skip the prompt in certain situations.

=== "Usage"

    **Usage:** `confirm_user_consent_neutral <message>`

    **Options:**

     * `<message>`: The message to print to the user - this is usually a question.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if:

    * The message is empty.
    * The user did not consent.

## `confirm_user_consent_safe`

=== "Description"

    Asks the user to confirm their consent.

    This requires them to type in either `y`, `n`, or just press enter to confirm their consent (case insensitive).

    `y` is the default option.

    ```bash
    $ confirm_user_consent_safe "Are you sure you want to proceed?"
    Are you sure you want to proceed? [Y/n]
    ```

    If the user does not consent, it will simply exit the script with exit code 1 so that you do not have to handle the result with an if statement.

    You can set `DX_SCRIPTS_ALWAYS_CONSENT` to `"true"` to always consent to the prompt. This is useful for testing or if you want to skip the prompt in certain situations.

=== "Usage"

    **Usage:** `confirm_user_consent_safe <message>`

    **Options:**

     * `<message>`: The message to print to the user - this is usually a question.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if:

    * The message is empty.
    * The user did not consent.

## `confirm_user_consent_dangerous`

=== "Description"

    Asks the user to confirm their consent.

    This requires them to type in either `y`, `n`, or just press enter to revoke their consent (case insensitive).

    `n` is the default option.

    ```bash
    $ confirm_user_consent_dangerous "Are you sure you want to proceed?"
    Are you sure you want to proceed? [y/N]
    ```

    If the user does not consent, it will simply exit the script with exit code 1 so that you do not have to handle the result with an if statement.

    You can set `DX_SCRIPTS_ALWAYS_CONSENT` to `"true"` to always consent to the prompt. This is useful for testing or if you want to skip the prompt in certain situations.

=== "Usage"

    **Usage:** `confirm_user_consent_dangerous <message>`

    **Options:**

     * `<message>`: The message to print to the user - this is usually a question.

=== "Return codes"

    It will always return 0.

=== "Errors"

    It will exit the script with exit code 1 if:

    * The message is empty.
    * The user did not consent.
