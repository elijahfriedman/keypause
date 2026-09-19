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

## Building

Open `keypause.xcodeproj` in Xcode and build, or build from the command line:

```bash
xcodebuild -project keypause.xcodeproj -scheme keypause -configuration Release
