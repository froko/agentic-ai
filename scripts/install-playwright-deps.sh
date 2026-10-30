#!/usr/bin/env bash
#
# Install the system libraries Playwright's Chromium needs, plus the Chromium
# build for every workspace project that depends on @playwright/test.
#
# `playwright install --with-deps` only supports Debian/Ubuntu. Minimal Linux
# installs (e.g. Arch or Fedora under WSL2) ship without the desktop libraries
# that Chromium links against, so e2e tests fail with errors like
# "error while loading shared libraries: libnspr4.so". This script installs the
# libraries with the distribution's package manager, then the browser.
#
# Without a Playwright project in the workspace it only installs the system
# libraries, so it is safe to run in CI unconditionally.
#
# Usage:
#   scripts/install-playwright-deps.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Workspace projects (apps/*, libs/*, …) whose package.json lists @playwright/test.
mapfile -t PLAYWRIGHT_PROJECTS < <(cd "$WORKSPACE_ROOT" && node -e "
const fs = require('node:fs')
const path = require('node:path')
for (const dir of ['apps', 'libs', 'packages', 'examples']) {
  if (!fs.existsSync(dir)) continue
  for (const name of fs.readdirSync(dir)) {
    const file = path.join(dir, name, 'package.json')
    if (!fs.existsSync(file)) continue
    const pkg = JSON.parse(fs.readFileSync(file, 'utf8'))
    if ({ ...pkg.dependencies, ...pkg.devDependencies }['@playwright/test']) console.log(path.join(dir, name))
  }
}")

install_browsers() {
  if [[ ${#PLAYWRIGHT_PROJECTS[@]} -eq 0 ]]; then
    echo "==> No workspace project depends on @playwright/test; skipping the browser download"
    return
  fi
  for project in "${PLAYWRIGHT_PROJECTS[@]}"; do
    echo "==> Installing Chromium for $project"
    (cd "$WORKSPACE_ROOT/$project" && pnpm exec playwright install "$@" chromium)
  done
}

if command -v pacman >/dev/null 2>&1; then
  echo "==> Arch Linux: installing Chromium libraries with pacman"
  sudo pacman -S --needed --noconfirm \
    nspr nss at-spi2-core libxcomposite libxdamage libxfixes libxrandr \
    mesa libxkbcommon alsa-lib
  install_browsers
elif command -v dnf >/dev/null 2>&1; then
  echo "==> Fedora/RHEL: installing Chromium libraries with dnf"
  sudo dnf install -y \
    nspr nss atk at-spi2-atk at-spi2-core libXcomposite libXdamage libXfixes \
    libXrandr mesa-libgbm libxkbcommon alsa-lib
  install_browsers
elif command -v apt-get >/dev/null 2>&1; then
  echo "==> Debian/Ubuntu: using Playwright's own dependency installer"
  install_browsers --with-deps
else
  echo "==> Unknown package manager: installing the browser only" >&2
  install_browsers
fi

# Fail early with a clear message if a library is still missing.
browser="$(find "${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}" -type f \
  \( -name chrome-headless-shell -o -name chrome \) -perm -u+x 2>/dev/null | head -n 1)"
if [[ -n "$browser" ]] && ldd "$browser" | grep -q "not found"; then
  echo "error: Chromium is still missing system libraries:" >&2
  ldd "$browser" | grep "not found" >&2
  exit 1
fi

echo "Done."
