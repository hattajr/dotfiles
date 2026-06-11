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
  fail "chezmoi: setup-pi-auth: Bitwarden CLI 'bw' is not installed. Install it, then retry 'chezmoi apply'. Or skip secret scripts with: chezmoi apply --exclude scripts"
fi

if [[ -z "${BW_SESSION:-}" ]]; then
  fail "chezmoi: setup-pi-auth: BW_SESSION is not set. Unlock Bitwarden first with: export BW_SESSION=\"\$(bw unlock --raw)\""
fi

# A non-empty BW_SESSION can still be stale; verify the vault is actually unlocked.
vault_status="$(bw status --session "$BW_SESSION" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",""))' 2>/dev/null || true)"
if [[ "$vault_status" != "unlocked" ]]; then
  fail "chezmoi: setup-pi-auth: Bitwarden session is '${vault_status:-invalid}', not 'unlocked'. Refresh it with: export BW_SESSION=\"\$(bw unlock --raw)\" && bw sync"
fi

tmp_err="$(mktemp)"
trap 'rm -f "$tmp_err"' EXIT

if ! item_json="$(bw get item "$item_name" --session "$BW_SESSION" 2>"$tmp_err")"; then
  err="$(tr -d '\r' < "$tmp_err")"

  if grep -qi "Incorrect password" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden rejected the password while unlocking the vault. Re-run: export BW_SESSION=\"\$(bw unlock --raw)\""
  fi

  if grep -qi "Not logged in" <<<"$err" || grep -qi "You are not logged in" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden CLI is not logged in. Run 'bw login', then 'export BW_SESSION=\"\$(bw unlock --raw)\"', and retry."
  fi

  if grep -qi "No item found" <<<"$err" || grep -qi "not found" <<<"$err"; then
    fail "chezmoi: setup-pi-auth: Bitwarden item '$item_name' was not found. Check the secure note name and run 'bw sync'."
  fi

  fail "chezmoi: setup-pi-auth: Failed to read Bitwarden item '$item_name'. Run 'bw status' and 'bw get item $item_name --session \"\$BW_SESSION\"' to debug."
fi

if ! content="$(printf '%s' "$item_json" | python3 -c 'import json, sys; sys.stdout.write((json.load(sys.stdin).get("notes") or ""))' 2>"$tmp_err")"; then
  fail "chezmoi: setup-pi-auth: Bitwarden returned invalid JSON for '$item_name'."
fi

if [[ -f "$target" ]] && cmp -s <(printf '%s' "$content") "$target"; then
  exit 0
fi

printf '%s' "$content" > "$target"
chmod 600 "$target"
