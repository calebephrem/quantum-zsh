# Contributing to Quantum Zsh Theme

Thanks for taking the time to contribute.

## Getting Started

1. Fork the repository
2. Clone your fork

   ```sh
   git clone https://github.com/your-username/quantum-zsh
   ```

3. Create a branch for your change

   ```sh
   git checkout -b my-change
   ```

## Making Changes

### Adding a segment

Segments are functions named `_qtm_seg_<name>` in `quantum.zsh-theme`. Each one prints its output via `printf` and returns early if it has nothing to show.

```zsh
function _qtm_seg_example() {
  [[ -z "$SOME_CONDITION" ]] && return
  local c="$(_qtm_ansi $COLOR_DIR)"
  local r="$(_qtm_reset)"
  printf "%s%s%s" "$c" "your output" "$r"
}
```

Then document the new segment and any config keys it uses in `.quantumrc` and `README.md`.

### Adding a config key

1. Add the key with its default value to `quantum.zsh-theme` in the defaults block
2. Add it to `.quantumrc` with a comment explaining what it does
3. Add it to the `_qtm_all_keys` list in `cli.sh` under the appropriate group in `_qtm_cmd_list`
4. Document it in the options table in `README.md`

### Modifying the CLI

The CLI lives in `cli.sh`. Each command is a function named `_qtm_cmd_<name>`. Keep logging consistent. Use `_qtm_ok`, `_qtm_err`, `_qtm_warn`, `_qtm_info`, and `_qtm_log` rather than raw `echo` or `printf`.

### Modifying the installer

`install.sh` is a plain bash script. Keep it idempotent - re-running it should be safe and prompt before overwriting anything.

## Code Style

- Indent with 2 spaces
- Use `local` for all function-scoped variables
- Keep comments short and factual
- No emojis in comments or log output

## Submitting

1. Make sure the theme loads without errors in a fresh shell
2. Test `qtm set`, `qtm list`, `qtm reset`, and `qtm reload`
3. Push your branch and open a pull request against `main`
4. Describe what you changed and why

## Reporting Bugs

Open an issue at https://github.com/calebephrem/quantum-zsh/issues and include your zsh version, oh-my-zsh version, and what you expected vs what happened.
