# Quantum Theme for ZSH

![Preview](https://github.com/calebephrem/quantum-zsh/blob/main/assets/preview.png?raw=true)

A lightweight, configurable ZSH theme with git integration, built for oh-my-zsh.

## Installation

**One-liner:**

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/calebephrem/quantum-zsh/main/install.sh)
```

**Manual:**

1. Clone the repository

```sh
   git clone https://github.com/calebephrem/quantum-zsh ~/.oh-my-zsh/custom/themes/quantum
```

2. Copy the default config

```sh
   cp ~/.oh-my-zsh/custom/themes/quantum/.quantumrc ~/.quantumrc
```

3. Add the `qtm` alias to your `.zshrc`

```sh
   echo 'alias qtm="source ~/.oh-my-zsh/custom/themes/quantum/cli.sh"' >> ~/.zshrc
```

4. Set the theme in your `.zshrc`

```sh
   ZSH_THEME="quantum/quantum"
```

5. Reload your shell

```sh
   exec zsh
```

## Configuration

Quantum is configured through `~/.quantumrc`, created automatically on install script.

**Using the CLI:**

```sh
qtm set GIT_BRANCH_SYMBOL " "
qtm set DIR_STYLE short
qtm set GIT_SHOW_DIRTY false
qtm get COLOR_ARROW
qtm list
qtm reload
qtm reset # To restore quantum theme to it's initial config
```

## Segments

Control what shows in your prompt by editing the `SEGMENTS` array in `~/.quantumrc`:

```sh
SEGMENTS=(dir git_status)
```

Available segments: `dir`, `git_status`, `venv`, `user`, `host`, `time`, `exit_code`

## Options

| Key                     | Default            | Description                          |
| ----------------------- | ------------------ | ------------------------------------ |
| `SEGMENTS`              | `(dir git_status)` | Segments to display, in order        |
| `PROMPT_SYMBOL`         | `»`                | Arrow/separator symbol               |
| `GIT_BRANCH_SYMBOL`     | ` `                | Symbol before branch name            |
| `GIT_DIRTY_SYMBOL`      | `✗`                | Shown when working tree is dirty     |
| `GIT_CLEAN_SYMBOL`      | ` `                | Shown when working tree is clean     |
| `GIT_AHEAD_SYMBOL`      | `↑`                | Shown when ahead of remote           |
| `GIT_BEHIND_SYMBOL`     | `↓`                | Shown when behind remote             |
| `COLOR_DIR`             | `cyan`             | Directory color                      |
| `COLOR_BRANCH`          | `yellow`           | Branch name color                    |
| `COLOR_DETACHED`        | `red`              | Detached HEAD color                  |
| `COLOR_ARROW`           | `green`            | Prompt symbol color                  |
| `COLOR_DIRTY`           | `red`              | Dirty indicator color                |
| `COLOR_CLEAN`           | `green`            | Clean indicator color                |
| `COLOR_VENV`            | `blue`             | Virtual environment color            |
| `COLOR_USER`            | `magenta`          | Username color                       |
| `COLOR_HOST`            | `white`            | Hostname color                       |
| `COLOR_TIME`            | `white`            | Time color                           |
| `COLOR_EXIT_OK`         | `green`            | Exit code color on success           |
| `COLOR_EXIT_FAIL`       | `red`              | Exit code color on failure           |
| `DIR_STYLE`             | `name`             | `name`, `short`, or `full`           |
| `GIT_SHOW_DIRTY`        | `true`             | Show dirty indicator                 |
| `GIT_SHOW_AHEAD_BEHIND` | `false`            | Show ahead/behind counts             |
| `SHOW_VENV`             | `true`             | Show Python virtual environment name |
| `SHOW_EXIT_CODE`        | `false`            | Show exit code of last command       |
| `NEWLINE_BEFORE_PROMPT` | `false`            | Print a newline before each prompt   |

Valid color values: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`

## Screenshot

![Screenshot](https://github.com/calebephrem/quantum-zsh/blob/main/assets/screenshot.png?raw=true)

## Notes

- Found a bug? [Open an issue](https://github.com/calebephrem/quantum-zsh/issues)
- Using VS Code? Check out the [Quantum VS Code theme](https://marketplace.visualstudio.com/items?itemName=CalebEphrem.quantum)
- Enjoying the theme? Show some love by starring the [repo](https://github.com/calebephrem/quantum-zsh). It helps more shell stylists discover Quantum Theme :3
