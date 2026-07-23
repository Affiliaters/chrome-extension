#!/usr/bin/env bash
#
# update.sh — self-updater for the Affiliaters Deal Converter extension (macOS/Linux).
#
# Lives INSIDE the extension folder, so it needs no configured path: it updates
# whatever folder it sits in. Run by the scheduled job that install.command
# registers (or manually: bash update.sh). No git required — downloads the repo
# ZIP with curl and syncs the contents over this folder.
#
# Flow: read local manifest version -> fetch version.json from GitHub -> if a
# newer version exists, download ZIP -> extract -> copy over this folder.
# The running Chrome picks the new files up via the extension's own
# runtime.reload() check (or on the next browser restart).
set -u

VERSION_URL="https://raw.githubusercontent.com/Affiliaters/chrome-extension/main/version.json"
FALLBACK_ZIP_URL="https://github.com/Affiliaters/chrome-extension/archive/refs/heads/main.zip"

# ── Self-overwrite guard ─────────────────────────────────────────────────────
# This script replaces ITSELF during the sync. Bash reads scripts incrementally,
# so overwriting a running script can corrupt execution. First invocation copies
# itself to a temp file and re-executes from there, passing the real folder.
if [ -z "${AFF_UPDATER_RELAUNCHED:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TMP_SELF="$(mktemp "${TMPDIR:-/tmp}/aff-updater.XXXXXX")"
    cp "${BASH_SOURCE[0]}" "$TMP_SELF"
    AFF_UPDATER_RELAUNCHED=1 exec bash "$TMP_SELF" "$SCRIPT_DIR"
fi

EXT_DIR="${1:?extension directory argument missing}"
LOG="$EXT_DIR/last-update.log"
TMP_SELF_PATH="$0"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

WORK_DIR=""
cleanup() {
    [ -n "$WORK_DIR" ] && rm -rf "$WORK_DIR"
    rm -f "$TMP_SELF_PATH"
}
trap cleanup EXIT

# Fresh log each run so it never grows unbounded.
: > "$LOG"
log "updater started (folder: $EXT_DIR, os: $(uname -s))"

if [ ! -f "$EXT_DIR/manifest.json" ]; then
    log "ERROR: no manifest.json next to updater — aborting (folder moved or corrupted?)"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    log "ERROR: curl not found — cannot download updates"
    exit 1
fi

# ── Version comparison (pure bash — BSD sort on macOS lacks -V on old versions)
json_field() { sed -n 's/.*"'"$2"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" | head -1; }

# Returns 0 (true) if $1 < $2 as dotted versions.
version_lt() {
    local IFS=. a b i
    read -ra a <<< "$1"; read -ra b <<< "$2"
    for ((i = 0; i < ${#a[@]} || i < ${#b[@]}; i++)); do
        local x="${a[i]:-0}" y="${b[i]:-0}"
        ((10#$x < 10#$y)) && return 0
        ((10#$x > 10#$y)) && return 1
    done
    return 1
}

LOCAL_VER="$(json_field "$EXT_DIR/manifest.json" version)"
log "installed version: ${LOCAL_VER:-unknown}"

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/aff-update.XXXXXX")"

if ! curl -fsSL --max-time 30 "$VERSION_URL" -o "$WORK_DIR/version.json"; then
    log "version check failed (offline?) — will retry on next scheduled run"
    exit 0
fi

REMOTE_VER="$(json_field "$WORK_DIR/version.json" latest_version)"
ZIP_URL="$(json_field "$WORK_DIR/version.json" download_url)"
[ -n "$ZIP_URL" ] || ZIP_URL="$FALLBACK_ZIP_URL"
log "latest version: ${REMOTE_VER:-unknown}"

if [ -z "$REMOTE_VER" ] || [ -z "$LOCAL_VER" ] || ! version_lt "$LOCAL_VER" "$REMOTE_VER"; then
    log "already up to date — nothing to do"
    exit 0
fi

log "updating $LOCAL_VER -> $REMOTE_VER"
if ! curl -fsSL --max-time 300 "$ZIP_URL" -o "$WORK_DIR/ext.zip"; then
    log "ERROR: download failed — will retry on next scheduled run"
    exit 1
fi

# ── Extract (unzip -> bsdtar -> python3, whichever exists) ───────────────────
mkdir "$WORK_DIR/unzipped"
if command -v unzip >/dev/null 2>&1; then
    unzip -qo "$WORK_DIR/ext.zip" -d "$WORK_DIR/unzipped"
elif command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "$WORK_DIR/ext.zip" -C "$WORK_DIR/unzipped"
elif command -v python3 >/dev/null 2>&1; then
    python3 -m zipfile -e "$WORK_DIR/ext.zip" "$WORK_DIR/unzipped"
else
    log "ERROR: no unzip/bsdtar/python3 available to extract the update"
    exit 1
fi

# GitHub zips wrap everything in a "<repo>-<branch>/" folder — locate the root
# by finding manifest.json rather than assuming the folder name.
SRC_MANIFEST="$(find "$WORK_DIR/unzipped" -maxdepth 3 -name manifest.json | head -1)"
if [ -z "$SRC_MANIFEST" ]; then
    log "ERROR: downloaded ZIP has no manifest.json — aborting"
    exit 1
fi
SRC_DIR="$(dirname "$SRC_MANIFEST")"

# Sync IN PLACE (never delete/recreate the folder — Chrome holds this path).
if ! cp -R "$SRC_DIR"/. "$EXT_DIR"/; then
    log "ERROR: copy failed — extension folder may be partially updated"
    exit 1
fi
chmod +x "$EXT_DIR/update.sh" "$EXT_DIR/install.command" 2>/dev/null

NEW_VER="$(json_field "$EXT_DIR/manifest.json" version)"
log "updated to $NEW_VER — Chrome will switch over automatically (or on next browser restart)"
exit 0
