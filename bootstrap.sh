#!/usr/bin/env bash
# Set up a new Mac: Xcode CLT, Homebrew, the core Brewfile, then any modules you name.
set -euo pipefail
cd "$(dirname "$0")"

MIN_MACOS=15
MODULES="apps cli dev macos"
BREW=/opt/homebrew/bin/brew
DRY=0 YES=0 selected=()

usage() {
  cat <<EOF
Usage: ./bootstrap.sh [--dry-run] [-y|--yes] [module ...]

Always installs core. Modules: $MODULES
  --dry-run   print the plan and the commands, change nothing
  -y, --yes   skip the confirmation prompt
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    -y|--yes) YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) case " $MODULES " in
         *" $arg "*) selected+=("$arg") ;;
         *) echo "Unknown option or module: $arg" >&2; usage >&2; exit 2 ;;
       esac ;;
  esac
done

# ponytail: Apple Silicon only, no Intel. Add /usr/local/bin/brew handling if Intel support is wanted.
[ "$(uname -s)" = Darwin ] || { echo "This only runs on macOS." >&2; exit 1; }
[ "$(uname -m)" = arm64 ] || { echo "Apple Silicon only (Intel is not supported)." >&2; exit 1; }
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge "$MIN_MACOS" ] || { echo "macOS $MIN_MACOS or newer is required." >&2; exit 1; }

run() {
  echo "+ $*"
  [ "$DRY" -eq 1 ] || "$@"
}

echo "Plan:"
echo "  - Xcode Command Line Tools, Homebrew"
echo "  - core (Brewfile)"
for m in ${selected[@]+"${selected[@]}"}; do echo "  - $m"; done
[ -f Brewfile.local ] && echo "  - Brewfile.local"
[ "$DRY" -eq 1 ] && echo "(dry run: nothing will be changed)"
echo

if [ "$DRY" -eq 0 ] && [ "$YES" -eq 0 ]; then
  read -r -p "Continue? [y/N] " reply
  case "$reply" in y|Y|yes) ;; *) echo "Aborted."; exit 1 ;; esac
fi

if [ "$DRY" -eq 0 ]; then
  # The Homebrew installer runs non-interactively and needs cached sudo credentials.
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
  trap 'kill $! 2>/dev/null || true' EXIT
fi

if ! xcode-select -p >/dev/null 2>&1; then
  run xcode-select --install
  # ponytail: waits for the GUI installer; no timeout.
  [ "$DRY" -eq 1 ] || until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

if [ ! -x "$BREW" ]; then
  if [ "$DRY" -eq 1 ]; then
    echo "+ install Homebrew (official installer)"
  else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi
[ ! -x "$BREW" ] || eval "$("$BREW" shellenv)"

bundle() { run "$BREW" bundle --no-upgrade --file="$1"; }

bundle Brewfile
for m in ${selected[@]+"${selected[@]}"}; do
  case "$m" in
    macos) run env DRY="$DRY" bash modules/macos.sh ;;
    *) bundle "modules/$m.Brewfile" ;;
  esac
done
[ ! -f Brewfile.local ] || bundle Brewfile.local

echo
echo "Done."
if ! grep -qs 'brew shellenv' "$HOME/.zprofile"; then
  echo "To get brew on your PATH in new shells, add this line to ~/.zprofile:"
  echo "  eval \"\$($BREW shellenv)\""
fi
echo "Next: run 'gh auth login' and set your git name and email."
