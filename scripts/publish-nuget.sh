#!/usr/bin/env bash
#
# Push every NuGet package found in the central dist/ folder to a NuGet feed.
#
# Called by semantic-release (see .releaserc) after `nx run-many -t pack`. In the
# default application layout no project is packable, so no .nupkg exists and
# this script exits successfully without pushing anything.
#
# Environment:
#   NUGET_API_KEY  API key for the feed (required when packages are found)
#   NUGET_SOURCE   feed URL (default: https://api.nuget.org/v3/index.json)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$WORKSPACE_ROOT/dist"
NUGET_SOURCE="${NUGET_SOURCE:-https://api.nuget.org/v3/index.json}"

PACKAGES=()
if [[ -d "$DIST_DIR" ]]; then
  while IFS= read -r -d '' pkg; do
    PACKAGES+=("$pkg")
  done < <(find "$DIST_DIR" -path "$DIST_DIR/intermediates" -prune -o -name '*.nupkg' -print0)
fi

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  echo "No NuGet packages found in dist/ - nothing to publish."
  exit 0
fi

if [[ -z "${NUGET_API_KEY:-}" ]]; then
  echo "error: found ${#PACKAGES[@]} NuGet package(s) but NUGET_API_KEY is not set" >&2
  exit 1
fi

for pkg in "${PACKAGES[@]}"; do
  dotnet nuget push "$pkg" --api-key "$NUGET_API_KEY" --source "$NUGET_SOURCE" --skip-duplicate
done
