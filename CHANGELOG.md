# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-11-25

### Added

- A background agent that draws a gray ring at the pointer on every mouse click, on every display, Space and
  full-screen app, without Accessibility or Input Monitoring access.
- The ring's look, measured from a Screen Studio-style app demo: a 2-point mid-gray ring with no fill or shadow
  that grows from 18 to 43 points with ease-out while fading out linearly over 0.27 seconds.
- `install.zsh`, which builds the agent, installs it as the LaunchAgent `local.iclick` in
  `~/Library/Application Support/iClick`, and removes it with `--uninstall`.

[Unreleased]: https://github.com/x96x64/iClick/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/x96x64/iClick/releases/tag/v1.0.0
