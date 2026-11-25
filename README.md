# iClick

iClick draws a soft gray ring at the mouse pointer every time you click on macOS, like the click highlight in screen recordings and app demos, but all the time and in every app. It is meant for anyone who records, streams or shares their screen and wants every click to be visible without turning on a highlight in each recording tool, and for anyone who simply likes to see where a click landed.

[![License](https://img.shields.io/github/license/x96x64/iClick)](https://github.com/x96x64/iClick/blob/main/LICENSE)

## Overview

iClick is a single Swift file that runs in the background as a launchd agent. It has no Dock icon, no menu bar item and no window of its own. It starts when you log in, restarts by itself if it ever exits, and needs no Terminal window to keep running.

Each display is covered by a transparent window that lets every click pass through to the apps below it. When you press any mouse button, iClick draws a thin gray ring at the pointer that grows and fades out in about a quarter of a second. The ring is drawn above full-screen apps and on every Space, so it is always where you clicked.

The look is measured from the click highlight in a typical Screen Studio-style app demo, frame by frame at 60 frames per second: a mid-gray ring 2 points wide, with no fill or shadow, that grows from 18 to 43 points with an ease-out curve while it fades out linearly over 0.27 seconds. Mid gray stays visible on both light and dark backgrounds.

## Features

iClick does one thing and keeps out of the way while doing it. The list below describes what it does and, just as importantly, what it does not need from you or from the system in order to work.

- A click ring for the left, right and other mouse buttons, on every display, Space and full-screen app.
- Clicks always reach the app under the pointer, because the overlay windows ignore the mouse.
- No permissions to grant. Watching mouse clicks needs neither Accessibility nor Input Monitoring access.
- Starts at login and stays running as the LaunchAgent `local.iclick`, with no Dock icon or menu.
- One Swift file built with `swiftc`, and one zsh script to install, update and remove it. No third-party dependencies.

## Requirements

iClick needs macOS and the Xcode command line tools, which provide the `swiftc` compiler that the install script uses to build the agent on your own Mac. A full Xcode installation also works but is not required. If the command line tools are missing, `xcode-select --install` installs them. No package manager, runtime or other software is needed.

## Installation

Clone the repository and run the install script. It builds `iclick.swift`, copies the source, the script and the binary to `~/Library/Application Support/iClick`, writes `~/Library/LaunchAgents/local.iclick.plist`, and starts the agent at once.

```sh
git clone https://github.com/x96x64/iClick.git
cd iClick
zsh install.zsh
```

The installed copy does not depend on the clone, which can be moved or deleted afterwards. Running the script again rebuilds and restarts the agent, so the same command also updates an existing installation after you pull a newer version.

## Configuration

The ring's size, width, color and timing are constants at the top of `iclick.swift`, in points and seconds, and each one is described by a comment next to it. To change the look, edit them in `~/Library/Application Support/iClick/iclick.swift` (or in the clone) and run the install script from that folder again. The script rebuilds the binary and restarts the agent, so the new look appears with the next click.

```sh
cd ~/Library/Application\ Support/iClick
zsh install.zsh
```

## Uninstallation

The `--uninstall` option stops the agent and removes the installed folder and the LaunchAgent property list. Nothing else is left behind: iClick writes no preferences, caches or logs, and it never asked for any permission, so there is nothing to revoke in System Settings. A clone of the repository, if you kept one, can be deleted like any other folder.

```sh
zsh ~/Library/Application\ Support/iClick/install.zsh --uninstall
```

## Troubleshooting

The command `launchctl print gui/$(id -u)/local.iclick` shows whether the agent is running; a healthy agent reports `state = running`. If no ring appears, run the install script again, which rebuilds the binary and restarts the agent. If the build fails, check that `swiftc --version` works, and install or update the Xcode command line tools if it does not.

## Versioning and Changelog

The project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html), so a change in the major version is the only kind that can require you to do something differently. The current version is 1.0.0, and each release is tagged in the repository as `vX.Y.Z`.

Every notable change is recorded in [CHANGELOG.md](https://github.com/x96x64/iClick/blob/main/CHANGELOG.md), in the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format, with the newest release at the top and links that compare each release with the one before it.

## License

iClick is released under the MIT License; the full text is in the [LICENSE](https://github.com/x96x64/iClick/blob/main/LICENSE) file. The license applies to the code and the documentation in this repository, and it allows you to use, copy, modify and distribute them, including in commercial work, as long as the copyright notice and the license text are kept.

Copyright is held by the iClick contributors. Contributions are accepted under the same license.
