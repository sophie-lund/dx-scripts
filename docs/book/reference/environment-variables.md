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

# Environment variables

These environment variables can all be set to modify the behavior of these scripts.

| Variable                               | Description                                                                                                                                  | Default         |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `DX_SCRIPTS_AWS_CONFIG_PATH`           | The path to the AWS config file.                                                                                                             | `~/.aws/config` |
| `DX_SCRIPTS_DISABLE_BOOTSTRAP_UPGRADE` | By default, bootstrapping will upgrade system dependencies. This adds a lot of time to CI runs so this flag exists to optionally disable it. | `false`         |
| `DX_SCRIPTS_ALWAYS_CONSENT`            | This disables all prompts and assumes that the user has consented to all actions.                                                            | `false`         |
| `DX_SCRIPTS_PROJECT_DIRECTORY`         | The root directory of the project.                                                                                                           |                 |
