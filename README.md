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

Pull all submodules:

```shell
git submodule update --init --recursive
```

Install these dependencies:

- [**ShellCheck**](https://www.shellcheck.net/):
  - On macOS: `brew install shellcheck`

## Testing

Run this command to run the tests:

```shell
./external/bats-core/bin/bats lib
```

This will contain some tests that run slowly, so for fast iteration you may want to run:

```shell
./external/bats-core/bin/bats lib --filter-tags '!slow'
```

## Linting

Run the following command to lint the code:

```shell
shellcheck lib/*.bash
```
