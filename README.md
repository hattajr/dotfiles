# dotfiles

Managed by [chezmoi](https://chezmoi.io). Source of truth lives in this repo.

## Bootstrap a new machine

```bash
# 1. SSH key authorized for github.com/hattajr (no PATs)
# 2. install chezmoi + bw
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
npm i -g @bitwarden/cli                       # or brew install bitwarden-cli on macOS

# 3. unlock Bitwarden (needed so pi auth.json can be written)
bw login                                      # if new device
export BW_SESSION="$(bw unlock --raw)"

# 4. init + apply
~/.local/bin/chezmoi init --apply git@github.com:hattajr/dotfiles.git
```

## Daily commands

| Task | Command |
|---|---|
| Edit a config | `chezmoi edit ~/.zshrc` |
| Preview what `apply` would do | `chezmoi diff` |
| Apply local source -> `$HOME` | `chezmoi apply -v` |
| Pull remote + apply in one shot | `chezmoi update` |
| Add a new file to tracking | `chezmoi add ~/.foorc` |
| Open the source dir in a shell | `chezmoi cd` |

## Layout

| Path | What |
|---|---|
| `~/.local/share/chezmoi/` | source dir (this repo) |
| `dot_zshrc.tmpl` | templated `.zshrc` (linux/darwin branches) |
| `dot_config/` | everything under `~/.config/` |
| `.chezmoiexternal.toml` | external repos (e.g. `~/.pi` cloned from `hattajr/.pi`) |
| `.chezmoiignore` | per-OS file exclusions |
| `.chezmoidata.toml` | static template data (name, email) |
| `run_once_before_install-tools.sh.tmpl` | bootstrap apt/brew tools |
| `run_onchange_after_setup-pi-auth.sh.tmpl` | writes `~/.pi/agent/auth.json` from Bitwarden |

## Secrets

`~/.pi/agent/auth.json` is fetched from the Bitwarden secure note **`pi-auth-json`**. Re-runs whenever the note content changes.

If `chezmoi apply` fails with a Bitwarden error: `export BW_SESSION="$(bw unlock --raw)"` first.

To skip secret-dependent scripts on a quick apply: `chezmoi apply --exclude scripts`.
