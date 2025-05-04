# DX Scripts

Scripts to help automate the developer experience for different kinds of projects.

## Usage

### Environment variables

You can use these environment variables to configure the scripts' behavior:

| Variable                       | Description                                                | Default                                        |
| ------------------------------ | ---------------------------------------------------------- | ---------------------------------------------- |
| `DX_SCRIPTS_PROJECT_DIRECTORY` | The root directory of the project.                         | Detected using parent top-level Git repository |
| `DX_SCRIPTS_ENV_FILENAME`      | The filename of the `.env` file to load for configuration. | `.env`                                         |
| `DX_SCRIPTS_AWS_CONFIG_PATH`   | The path to the AWS config file.                           | `~/.aws/config`                                |

## Setup

Bootstrap the project by running this script:

```shell
./bootstrap.bash
```

Follow the instructions printed by the script to start development.
