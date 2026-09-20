# keypause

A small macOS command-line tool that locks your keyboard (and your
trackpad/mouse) until you press two "activator" keys together again.
It's useful for cleaning your keyboard, keeping kids or pets from mashing keys, or
just temporarily disabling input.

## How it works

On launch, `keypause` asks you to press two keys to use as the activator
combo, and whether it should also lock the trackpad/mouse. Once running, all
keyboard (and optionally pointer) input is swallowed until you press both
activator keys together again, which unlocks input.

## Requirements

- macOS 11 (Big Sur) or later
- Accessibility permissions granted to the built binary (needed to install
  the event taps)

## Installation

```bash
brew install elijahfriedman/tap/keypause
```

## Command-line options

- `--check-permissions` — checks whether Accessibility permission is granted
  and exits: `0` if granted, `1` if not. Prints a line containing
  `Accessibility permission: granted` or `Accessibility permission: not
  granted`. Installs no event taps and reads no input, so it's safe to run
  non-interactively (e.g. in a Homebrew formula's `test do` block, since a
  fresh CI machine won't have granted the permission and this exercises the
  real binary without requiring keypresses).
- `--keys=KEY1+KEY2` — sets the activator combo from the command line instead
  of the interactive prompt, e.g. `--keys=leftcommand+leftshift`. See
  [docs/KEYS.md](docs/KEYS.md) for accepted key names.
- `--lock-mouse` — also locks the trackpad/mouse while locked, instead of the
  interactive prompt.
- `--version` — prints the version and exits `0`.
- `--help` — prints usage and exits `0`.

## Building

Open `keypause.xcodeproj` in Xcode and build, or build from the command line:

```bash
xcodebuild -project keypause.xcodeproj -scheme keypause -configuration Release
