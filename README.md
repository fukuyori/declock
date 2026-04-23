# DeClock

DeClock is a SwiftUI analog clock app for Apple platforms.

A useless clock with 10 hours in a day, 100 minutes in an hour, and 100 seconds in a minute.

The macOS app uses a transparent, resizable clock window and includes a Settings toggle for launching DeClock at login.

## Screenshot

![DeClock screenshot](image/screenshot.png)

## Requirements

- Xcode 26.4.1 or later
- macOS 26.4 SDK or later

## Build

```sh
xcodebuild -project declock.xcodeproj -scheme declock -configuration Release -destination 'generic/platform=macOS' build
```

## Releases

Installation packages are attached to GitHub Releases.

## Create a macOS Package

```sh
xcodebuild -project declock.xcodeproj -scheme declock -configuration Release -destination 'generic/platform=macOS' -derivedDataPath /tmp/declock-derived build
mkdir -p /tmp/declock-pkg-root-0.6.1/Applications
ditto --norsrc /tmp/declock-derived/Build/Products/Release/declock.app /tmp/declock-pkg-root-0.6.1/Applications/declock.app
COPYFILE_DISABLE=1 pkgbuild --root /tmp/declock-pkg-root-0.6.1 --identifier org.spumoni.declock --version 0.6.1 artifacts/declock-0.6.1.pkg
```
