# mac-setup

Set up a new Mac with one command. Pick the modules you want; nothing personal and no secrets are stored here.

Requires Apple Silicon and macOS 15 or newer. Intel is not supported.

## Quick start

```sh
git clone https://github.com/tungmadz/mac-setup.git
cd mac-setup
./bootstrap.sh --dry-run apps cli dev macos   # preview, changes nothing
./bootstrap.sh apps cli dev macos             # install
```

On a brand-new Mac, the first `git clone` opens the Xcode Command Line Tools installer. Let it finish, then run the `git clone` again.

`./bootstrap.sh` with no arguments installs only `core`. It asks for your admin password once and asks you to confirm before it changes anything (`-y` skips the prompt).

## What it does

1. Installs the Xcode Command Line Tools and Homebrew (the official installer).
2. Installs `core` from `Brewfile`.
3. Installs each module you named.
4. Installs `Brewfile.local` if you have one.

It is safe to run again: `brew bundle` skips what is installed (`--no-upgrade` stops it upgrading things), and it never overwrites your dotfiles.

## Modules

| Module | Contents |
|---|---|
| `core` (always) | git, gh, node, uv, jq, ripgrep, wget |
| `apps` | Chrome, VS Code, Warp, Claude, ChatGPT, Slack, Zoom, VLC |
| `cli` | direnv, tmux, tree, watchman, yt-dlp, ffmpeg, bun, pnpm, yarn |
| `dev` | postgresql@16, redis, sqlite, awscli, Docker Desktop, DBeaver, Another Redis Desktop Manager, Google Cloud CLI |
| `macos` | Finder, Dock, keyboard, trackpad and screenshot settings. Prints each `defaults` command before running it. Keyboard changes apply after you log out. |

To change what a module installs, edit its file in `modules/`.

## Your own additions

Put extra formulae and casks in `Brewfile.local`. It is in `.gitignore`, so it is never committed, and `bootstrap.sh` installs it automatically.

## After it finishes

- Run `gh auth login`.
- Set your git identity: `git config --global user.name "Your Name"` and `git config --global user.email you@example.com`.
- If `brew` is not found in a new shell, add `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile`. The script does not edit your dotfiles.
- Grant Accessibility or Full Disk Access to apps that ask for it, and sign in to each app.

## Contributing

Never commit credentials, tokens or personal data. CI runs `shellcheck`, a dry run, a check that every formula and cask exists, and a secret scan.

## License

MIT
