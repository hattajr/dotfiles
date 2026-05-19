# dotfiles

Managed by [chezmoi](https://chezmoi.io). Source of truth lives in this repo.

## Prerequisites (must exist before `chezmoi init`)

1. **SSH key authorized for `github.com/hattajr`** — needed to clone this repo and the `~/.pi` external. PATs are not used.
2. **Bitwarden CLI (`bw`) installed and unlocked** — `run_onchange_after_setup-pi-auth.sh.tmpl` reads a secret from Bitwarden during `chezmoi apply`. If `bw` is missing or `BW_SESSION` is empty, `apply` will hard-fail.

## Bootstrap a new machine

```bash
# 1. Make sure prerequisites above are satisfied.

# 2. Install chezmoi + bw
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
npm i -g @bitwarden/cli                       # or `brew install bitwarden-cli` on macOS

# 3. Unlock Bitwarden (needed so pi auth.json can be written)
bw login                                      # if new device
export BW_SESSION="$(bw unlock --raw)"

# 4. Init + apply
~/.local/bin/chezmoi init --apply git@github.com:hattajr/dotfiles.git
```

What `apply` does automatically (in order):

1. Runs `run_once_before_install-tools.sh` — apt/brew installs `zsh tmux git curl xclip fzf` (+ `bat eza` on macOS) and installs oh-my-zsh + `zsh-autosuggestions` + `zsh-syntax-highlighting`.
2. Renders `dot_*` files to `~/`.
3. Clones the `~/.pi` external via SSH.
4. Runs `run_onchange_after_setup-pi-auth.sh` — writes `~/.pi/agent/auth.json` from Bitwarden.

## Tools NOT auto-installed (install manually if you want them)

These are referenced in configs but bootstrap leaves them to you:

| Tool | Used by | Linux | macOS |
|---|---|---|---|
| `nvim` | git editor, default `EDITOR` | `sudo apt install neovim` (or PPA for latest) | `brew install neovim` |
| `helix` | `dot_config/helix/`, `live-grep-helix` script | snap / cargo | `brew install helix` |
| `bat`/`batcat` | `cat` alias, fzf preview | `sudo apt install bat` | (bundled in bootstrap) |
| `eza`/`exa` | `ls` alias | cargo / GitHub release | (bundled in bootstrap) |
| `zellij` | `z` alias | cargo / GitHub release | `brew install zellij` |
| `node`/`npm` | needed to install `bw` itself | `sudo apt install nodejs npm` | `brew install node` |

If a tool is missing, the matching alias/PATH line silently no-ops — your shell still loads cleanly.

## Daily commands

| Task | Command |
|---|---|
| Edit a config | `chezmoi edit ~/.zshrc` |
| Preview what `apply` would do | `chezmoi diff` |
| Apply local source -> `$HOME` | `chezmoi apply -v` |
| Pull remote + apply in one shot | `chezmoi update` |
| Add a new file to tracking | `chezmoi add ~/.foorc` |
| Open the source dir in a shell | `chezmoi cd` |
| Skip Bitwarden-dependent scripts | `chezmoi apply --exclude scripts` |

## Layout

| Path | What |
|---|---|
| `~/.local/share/chezmoi/` | source dir (this repo) |
| `dot_zshrc.tmpl` | templated `.zshrc` (linux/darwin branches) |
| `dot_vimrc` | minimal vim settings |
| `dot_gitconfig.tmpl` | git config (user data templated from `.chezmoidata.toml`) |
| `dot_config/` | everything under `~/.config/` |
| `.chezmoiexternal.toml` | external repos (e.g. `~/.pi` cloned from `hattajr/.pi`) |
| `.chezmoiignore` | per-OS file exclusions |
| `.chezmoidata.toml` | static template data (name, email) |
| `run_once_before_install-tools.sh.tmpl` | bootstrap apt/brew tools + oh-my-zsh |
| `run_onchange_after_setup-pi-auth.sh.tmpl` | writes `~/.pi/agent/auth.json` from Bitwarden |

## Secrets

`~/.pi/agent/auth.json` is fetched from the Bitwarden secure note **`pi-auth-json`**. Re-runs whenever the note content changes.

If `chezmoi apply` fails with a Bitwarden error: `export BW_SESSION="$(bw unlock --raw)"` first.

To skip secret-dependent scripts on a quick apply: `chezmoi apply --exclude scripts`.
