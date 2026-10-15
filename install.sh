#!/bin/bash
# Installs the latest Sidekix release into /Applications.
#   curl -fsSL https://raw.githubusercontent.com/shahidrogers/sidekix-releases/main/install.sh | bash
# Downloads come from the public releases repository and are verified against
# the published SHA-256 before anything is installed. Environment overrides:
#   SIDEKIX_VERSION=0.4.4   install a specific version instead of the latest
#   SIDEKIX_DEST=~/Applications   install somewhere other than /Applications
set -euo pipefail

repo="shahidrogers/sidekix-releases"
dest="${SIDEKIX_DEST:-/Applications}"

fail() { echo "error: $*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "Sidekix only runs on macOS."
[ "$(uname -m)" = "arm64" ] || fail "This Sidekix build is for Apple Silicon Macs only."
major=$(sw_vers -productVersion | cut -d. -f1)
[ "$major" -ge 14 ] || fail "Sidekix needs macOS 14 or later."

if [ -n "${SIDEKIX_VERSION:-}" ]; then
  version="${SIDEKIX_VERSION#v}"
else
  tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1)
  [ -n "$tag" ] || fail "Could not find the latest release."
  version="${tag#v}"
fi
case "$version" in *[!0-9.]*|"") fail "Unexpected version '$version'." ;; esac

name="Sidekix-$version-macos-apple-silicon.zip"
base="https://github.com/$repo/releases/download/v$version"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "Downloading Sidekix $version…"
curl -fSL --progress-bar -o "$work/$name" "$base/$name" || fail "Download failed for $name."
curl -fsSL -o "$work/$name.sha256" "$base/$name.sha256" || fail "Could not download the checksum."

expected=$(awk '{print $1}' "$work/$name.sha256")
actual=$(shasum -a 256 "$work/$name" | awk '{print $1}')
[ -n "$expected" ] && [ "$expected" = "$actual" ] || fail "Checksum mismatch. Nothing was installed."
echo "Checksum verified."

ditto -x -k "$work/$name" "$work/unpacked"
app="$work/unpacked/Sidekix.app"
[ -d "$app" ] || fail "The archive did not contain Sidekix.app."
codesign --verify --deep --strict "$app" 2>/dev/null || fail "The app's signature is invalid. Nothing was installed."

mkdir -p "$dest"
if pgrep -x Sidekix >/dev/null 2>&1; then
  echo "Quitting the running Sidekix…"
  osascript -e 'tell application "Sidekix" to quit' >/dev/null 2>&1 || pkill -x Sidekix || true
  sleep 1
fi
rm -rf "$dest/Sidekix.app"
ditto "$app" "$dest/Sidekix.app" || fail "Could not write to $dest. Try SIDEKIX_DEST=\$HOME/Applications."
# Files fetched by curl are not quarantined, but clear the flag in case a
# browser or another tool added it.
xattr -dr com.apple.quarantine "$dest/Sidekix.app" 2>/dev/null || true

echo "Installed Sidekix $version to $dest/Sidekix.app"
open "$dest/Sidekix.app"
