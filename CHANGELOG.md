# Changelog

All notable changes to Quantum are documented here.

## [2.2.0] - 06/01/2026

### Added

- `qtm changelog` - displays the latest 5 changelogs from `CHANGELOG.md`

### Fixed

- `qtm update` now discards local changes before pulling instead of stashing, avoiding merge conflicts

## [2.1.1] - 06/01/2026

### Added

- Updated ASCII art banner in install script
- ASCII art header displayed on `qtm update`

## [2.1.0] - 06/01/2026

### Added

- `qtm update` - pulls latest changes from GitHub into the theme directory
- `qtm version` / `qtm -v` - reads and displays the version from `.quantumver`
- `.quantumver` file for tracking the current theme version

## [2.0.0] - 06/01/2026

### Added

- Configurable prompt via `~/.quantumrc`
- `qtm` CLI for managing config (`set`, `get`, `list`, `reload`, `reset`)
- Segment system - control what shows and in what order via `SEGMENTS=()`
- New segments: `venv`, `user`, `host`, `time`, `exit_code`
- Git ahead/behind indicators
- Multiple directory display styles: `name`, `short`, `full`
- `install.sh` one-liner installer
- Repo default `.quantumrc` shipped alongside the theme

### Changed

- Theme now uses raw ANSI codes instead of zsh prompt escape sequences for reliable color rendering
- Prompt is built via `precmd` hook instead of a subshell expansion
- All config keys unprefixed (e.g. `COLOR_DIR` instead of `QUANTUM_COLOR_DIR`)

## [1.0.0] - 08/15/2025

### Added

- Initial release
- Directory name segment
- Git branch and detached HEAD display
- Custom `LS_COLORS`
