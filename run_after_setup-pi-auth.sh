#!/usr/bin/env bash
# Writes ~/.pi/agent/auth.json from Bitwarden secure note "pi-auth-json".
# Runs after externals (so ~/.pi/ exists from git clone).
#
# bw uses BW_SESSION from the environment when it is valid. On machines where the
# session is not honored (short vault timeout), bw falls back to prompting for the
# master password - so when run from a terminal we let it prompt and you TYPE your
# password (do not press Enter on an empty prompt). With no terminal (cron, CI) we
# disable prompting so it fails fast instead of hanging forever.
set -euo pipefail

item_name="pi-auth-json"
target="$HOME/.pi/agent/auth.json"

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

mkdir -p "$(dirname "$target")"

if ! command -v bw >/dev/null 2>&1; then
  fail "chezmoi: setup-pi-auth: Bitwarden CLI 'bw' is not installed.
  Fix - install bw, then retry:
    npm install -g @bitwarden/cli
    chezmoi apply -R
  Or skip this secret script for now:
    chezmoi apply -R --exclude scripts"
fi

# No terminal to prompt at -> never hang waiting for a password; fail fast instead.
if [[ ! -t 0 ]]; then
  export BW_NOINTERACTION=true
fi

tmp_err="$(mktemp)"
trap 'rm -f "$tmp_err"' EXIT

# Fetch the item. bw reads BW_SESSION from the env when valid; otherwise it prompts
# for the master password (type it). The 2nd 'tee' keeps the prompt visible while we
# still capture stderr for classification.
if ! item_json="$(bw get item "$item_name" 2> >(tee "$tmp_err" >&2))"; then
  err="$(tr -d '\r' < "$tmp_err")"

  if grep -qi "Not logged in" <<<"$err" || grep -qi "You are not logged in" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden CLI is not logged in.
  Fix - log in, then retry (you will be asked for your master password):
    bw login
    chezmoi apply -R"
  fi

  if grep -qi "No item found" <<<"$err" || grep -qi "not found" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden item '$item_name' was not found.
  Fix - sync the vault, confirm the item exists, then retry:
    bw sync
    bw get item $item_name
    chezmoi apply -R"
  fi

  if grep -qi "More than one result" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: More than one vault item is named '$item_name'.
  Fix - rename or delete the duplicate in your vault, sync, then retry:
    bw sync
    bw list items --search $item_name
    chezmoi apply -R"
  fi

  if grep -qi "Master password" <<<"$err" || grep -qi "Vault is locked" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: vault was locked and no master password was given.
  Fix - run apply from a terminal and TYPE your master password at the prompt:
    chezmoi apply -R"
  fi

  fail "chezmoi: setup-pi-auth: Failed to read Bitwarden item '$item_name'. Underlying error:
    ${err:-<no stderr captured>}
  Debug, then retry:
    bw status
    bw get item $item_name
    chezmoi apply -R"
fi

if ! content="$(printf '%s' "$item_json" | python3 -c 'import json, sys; sys.stdout.write((json.load(sys.stdin).get("notes") or ""))' 2>"$tmp_err")"; then
  fail "chezmoi: setup-pi-auth: Bitwarden returned invalid JSON for '$item_name'.
  Fix - re-sync and inspect the raw item, then retry:
    bw sync
    bw get item $item_name
    chezmoi apply -R"
fi

if [[ -f "$target" ]] && cmp -s <(printf '%s' "$content") "$target"; then
  exit 0
fi

printf '%s' "$content" > "$target"
chmod 600 "$target"
