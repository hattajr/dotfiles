#!/usr/bin/env bash
# Writes ~/.pi/agent/auth.json from Bitwarden secure note "pi-auth-json".
# Runs after externals (so ~/.pi/ exists from git clone).
# Requires: bw CLI installed and unlocked (BW_SESSION exported).
set -euo pipefail

# Never let bw drop into an interactive master-password prompt; fail fast instead of hanging.
export BW_NOINTERACTION=true

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

if [[ -z "${BW_SESSION:-}" ]]; then
  fail "chezmoi: setup-pi-auth: BW_SESSION is not set.
  Fix - unlock Bitwarden, export the session, then retry:
    export BW_SESSION=\"\$(bw unlock --raw)\"
    bw sync
    chezmoi apply -R"
fi

tmp_err="$(mktemp)"
trap 'rm -f "$tmp_err"' EXIT

# Attempt the fetch directly. With BW_NOINTERACTION a stale/locked session fails
# fast instead of prompting, and we classify the error below. We do NOT pre-gate
# on 'bw status' because it does not reliably reflect the --session token.
if ! item_json="$(bw get item "$item_name" --session "$BW_SESSION" 2>"$tmp_err")"; then
  err="$(tr -d '\r' < "$tmp_err")"

  if grep -qi "Vault is locked" <<<"$err" || grep -qi "mac failed" <<<"$err" || grep -qi "Session key is invalid" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden vault is locked or the session expired.
  Fix - get a fresh session, then retry:
    export BW_SESSION=\"\$(bw unlock --raw)\"
    bw sync
    chezmoi apply -R"
  fi

  if grep -qi "Incorrect password" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden rejected the master password.
  Fix - unlock again with the correct password, then retry:
    export BW_SESSION=\"\$(bw unlock --raw)\"
    chezmoi apply -R"
  fi

  if grep -qi "Not logged in" <<<"$err" || grep -qi "You are not logged in" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden CLI is not logged in.
  Fix - log in, unlock, then retry:
    bw login
    export BW_SESSION=\"\$(bw unlock --raw)\"
    bw sync
    chezmoi apply -R"
  fi

  if grep -qi "No item found" <<<"$err" || grep -qi "not found" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden item '$item_name' was not found.
  Fix - sync the vault and confirm the item exists, then retry:
    bw sync --session \"\$BW_SESSION\"
    bw get item $item_name --session \"\$BW_SESSION\"
    chezmoi apply -R"
  fi

  fail "chezmoi: setup-pi-auth: Failed to read Bitwarden item '$item_name'. Underlying error:
    ${err:-<no stderr captured>}
  Debug, then retry:
    bw status --session \"\$BW_SESSION\"
    bw get item $item_name --session \"\$BW_SESSION\"
    chezmoi apply -R"
fi

if ! content="$(printf '%s' "$item_json" | python3 -c 'import json, sys; sys.stdout.write((json.load(sys.stdin).get("notes") or ""))' 2>"$tmp_err")"; then
  fail "chezmoi: setup-pi-auth: Bitwarden returned invalid JSON for '$item_name'.
  Fix - re-sync and inspect the raw item, then retry:
    bw sync --session \"\$BW_SESSION\"
    bw get item $item_name --session \"\$BW_SESSION\"
    chezmoi apply -R"
fi

if [[ -f "$target" ]] && cmp -s <(printf '%s' "$content") "$target"; then
  exit 0
fi

printf '%s' "$content" > "$target"
chmod 600 "$target"
