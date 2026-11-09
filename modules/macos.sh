#!/usr/bin/env bash
# macOS defaults. Prints every command before running it. DRY=1 prints only.
set -euo pipefail

d() {
  echo "+ defaults $*"
  [ "${DRY:-0}" -eq 1 ] || defaults "$@"
}

# Dock
d write com.apple.dock show-recents -bool false

# Finder
d write NSGlobalDomain AppleShowAllExtensions -bool true
d write com.apple.finder ShowPathbar -bool true
d write com.apple.finder ShowStatusBar -bool true
d write com.apple.finder FXPreferredViewStyle -string Nlsv
d write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Keyboard (takes effect after logging out)
d write NSGlobalDomain KeyRepeat -int 2
d write NSGlobalDomain InitialKeyRepeat -int 15
d write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Trackpad: tap to click
d write com.apple.AppleMultitouchTrackpad Clicking -bool true
d write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
d -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Screenshots go to ~/Screenshots
echo "+ mkdir -p \$HOME/Screenshots"
[ "${DRY:-0}" -eq 1 ] || mkdir -p "$HOME/Screenshots"
d write com.apple.screencapture location -string "$HOME/Screenshots"

# Apply
for app in Dock Finder SystemUIServer; do
  echo "+ killall $app"
  [ "${DRY:-0}" -eq 1 ] || killall "$app" 2>/dev/null || true
done
