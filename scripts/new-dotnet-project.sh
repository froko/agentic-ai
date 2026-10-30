#!/usr/bin/env bash
#
# Create a new .NET project in this monorepo and wire it up for Nx.
#
# This is a thin wrapper around `dotnet new` that, in addition to scaffolding the
# project, drops in a `project.json` so the project gets the workspace-standard
# Nx targets (a `format` target for every project, plus a coverage-enabled
# `test` target for test projects).
#
# Usage:
#   scripts/new-dotnet-project.sh <template> -o <output-dir> -n <project-name> [extra dotnet args...]
#
# Examples:
#   scripts/new-dotnet-project.sh classlib -o libs/my-lib       -n MyLib
#   scripts/new-dotnet-project.sh webapi   -o apps/my-api       -n MyApi
#   scripts/new-dotnet-project.sh xunit    -o libs/my-lib-tests -n MyLib.Tests
#
# Whether a project is treated as a "test project" is detected from the template
# (xunit/nunit/mstest) or an output dir ending in `-tests`. Override with the
# TEST_PROJECT env var (TEST_PROJECT=1 / TEST_PROJECT=0).
#
set -euo pipefail

# --- locate workspace root (the dir containing this script's parent) ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") <template> -o <output-dir> -n <project-name> [extra dotnet args...]" >&2
  exit 1
fi

TEMPLATE="$1"
shift

# --- parse the args we care about, pass everything through to `dotnet new` ----
OUTPUT_DIR=""
PROJECT_NAME=""
DOTNET_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      OUTPUT_DIR="$2"
      DOTNET_ARGS+=("$1" "$2")
      shift 2
      ;;
    -n|--name)
      PROJECT_NAME="$2"
      DOTNET_ARGS+=("$1" "$2")
      shift 2
      ;;
    *)
      DOTNET_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$OUTPUT_DIR" ]]; then
  echo "error: an output directory (-o <dir>) is required" >&2
  exit 1
fi

# --- scaffold the .NET project ------------------------------------------------
# --no-restore: the template still pins package versions inline, so its
# automatic restore fails under CPM (NU1008) and leaves a broken restore state
# in obj/. Restore after the tidy step instead (`pnpm restore`).
echo "==> dotnet new $TEMPLATE --no-restore ${DOTNET_ARGS[*]}"
dotnet new "$TEMPLATE" --no-restore "${DOTNET_ARGS[@]}"

# --- tidy up the generated .csproj --------------------------------------------
# `dotnet new` emits properties that are already defined globally in the root
# Directory.Build.props (TargetFramework, ImplicitUsings, Nullable) and pins
# package versions inline on each PackageReference. This repo uses Central
# Package Management (Directory.Packages.props), so inline versions must instead
# live there as <PackageVersion> entries.
#
# This step rewrites the freshly generated .csproj to:
#   * drop properties that are inherited from Directory.Build.props, and
#   * move every "PackageReference ... Version=..." into Directory.Packages.props
#     (as a PackageVersion) and strip the inline Version attribute.
echo "==> tidying generated .csproj (inherit Directory.Build.props + CPM)"
PACKAGES_PROPS="$WORKSPACE_ROOT/Directory.Packages.props" \
PROJECT_OUTPUT_DIR="$WORKSPACE_ROOT/$OUTPUT_DIR" \
  node - <<'JS'
const fs = require('node:fs')
const path = require('node:path')

const projectDir = process.env.PROJECT_OUTPUT_DIR
const packagesProps = process.env.PACKAGES_PROPS

// Properties that are defined centrally in the root Directory.Build.props and
// therefore must not be repeated in individual project files.
const INHERITED_PROPERTIES = new Set(['TargetFramework', 'ImplicitUsings', 'Nullable'])

// Locate the .csproj that dotnet new just created in the output directory.
const projectFile = fs
  .readdirSync(projectDir)
  .find((f) => /\.(csproj|fsproj|vbproj)$/.test(f))
if (!projectFile) process.exit(0)
const csproj = path.join(projectDir, projectFile)

const original = fs.readFileSync(csproj, 'utf8')

// --- 1. strip inherited properties --------------------------------------------
// Remove lines like "<TargetFramework>net10.0</TargetFramework>".
let content = original
  .split(/\r?\n/)
  .filter((line) => {
    const m = line.match(/^\s*<([A-Za-z0-9_]+)>.*<\/\1>\s*$/)
    return !(m && INHERITED_PROPERTIES.has(m[1]))
  })
  .join('\n')

// Drop any PropertyGroup that is now empty (only whitespace between the tags).
// Consume the group's own trailing newline but leave the next line's
// indentation untouched.
content = content.replace(/[ \t]*<PropertyGroup>[ \t\r\n]*<\/PropertyGroup>[ \t]*\r?\n?/g, '')

// Collapse 3+ blank lines that may result from the removals down to one.
content = content.replace(/\n{3,}/g, '\n\n')

// --- 2. migrate inline PackageReference versions to CPM -----------------------
// Match: <PackageReference Include="X" Version="Y" /> (attr order independent),
// self-closing or not, and remove the Version attribute.
const pkgVersions = new Map()
content = content.replace(/<PackageReference\b[^>]*?>/g, (tag) => {
  const inc = tag.match(/Include="([^"]+)"/)
  const ver = tag.match(/Version="([^"]+)"/)
  if (inc && ver) pkgVersions.set(inc[1], ver[1])
  return tag.replace(/\s+Version="[^"]+"/, '')
})

if (!content.endsWith('\n')) content += '\n'
// The root .editorconfig wants project files as UTF-8 with BOM; not every
// template writes one (e.g. webapi).
if (!content.startsWith('﻿')) content = '﻿' + content
fs.writeFileSync(csproj, content)

// --- 3. record the package versions centrally ---------------------------------
if (pkgVersions.size > 0) {
  let props = fs.readFileSync(packagesProps, 'utf8')
  const existing = new Set([...props.matchAll(/<PackageVersion\s+Include="([^"]+)"/g)].map((m) => m[1]))
  const added = [...pkgVersions].filter(([name]) => !existing.has(name)).sort(([a], [b]) => a.localeCompare(b))

  if (added.length > 0) {
    const entries = added.map(([name, version]) => `    <PackageVersion Include="${name}" Version="${version}" />`)
    // Append to the ItemGroup that already holds PackageVersion entries, or
    // create a new ItemGroup before the closing </Project>.
    const group = props.match(/([ \t]*<ItemGroup>[\s\S]*?<PackageVersion\b[\s\S]*?)(\r?\n[ \t]*<\/ItemGroup>)/)
    if (group) {
      const lines = group[1].split('\n')
      const header = lines.shift()
      const name = (line) => (line.match(/Include="([^"]+)"/)?.[1] ?? '').toLowerCase()
      const sorted = [...lines, ...entries].sort((a, b) => (name(a) < name(b) ? -1 : name(a) > name(b) ? 1 : 0))
      props = props.replace(group[0], [header, ...sorted].join('\n') + group[2])
    } else {
      props = props.replace(/<\/Project>/, `  <ItemGroup>\n${entries.join('\n')}\n  </ItemGroup>\n</Project>`)
    }
    fs.writeFileSync(packagesProps, props)
    console.log(
      '    added PackageVersion entries to Directory.Packages.props: ' +
        added.map(([n, v]) => `${n} ${v}`).join(', '),
    )
  }
}
JS

# --- derive the Nx project name & relative depth ------------------------------
# Nx project name = the output directory's basename (matches the existing
# sample-lib / sample-lib-tests convention).
NX_PROJECT_NAME="$(basename "$OUTPUT_DIR")"

# Relative path from the project dir back to the workspace root, used for the
# `$schema` reference (e.g. libs/my-lib -> ../../, apps/group/my-api -> ../../../).
DEPTH="$(echo "$OUTPUT_DIR" | tr '/' '\n' | grep -c .)"
SCHEMA_PREFIX=""
for ((i = 0; i < DEPTH; i++)); do
  SCHEMA_PREFIX+="../"
done

# --- decide whether this is a test project ------------------------------------
is_test_project() {
  if [[ -n "${TEST_PROJECT:-}" ]]; then
    [[ "$TEST_PROJECT" == "1" || "$TEST_PROJECT" == "true" ]]
    return
  fi
  case "$TEMPLATE" in
    xunit|xunit3|nunit|mstest) return 0 ;;
  esac
  [[ "$NX_PROJECT_NAME" == *-tests || "$NX_PROJECT_NAME" == *-test ]]
}

PROJECT_JSON="$WORKSPACE_ROOT/$OUTPUT_DIR/project.json"

# --- write the project.json from the appropriate template ---------------------
if is_test_project; then
  echo "==> writing test project.json -> $OUTPUT_DIR/project.json"
  cat > "$PROJECT_JSON" <<EOF
{
  "\$schema": "${SCHEMA_PREFIX}node_modules/nx/schemas/project-schema.json",
  "name": "${NX_PROJECT_NAME}",
  "targets": {
    "format": {
      "executor": "nx:run-commands",
      "options": {
        "command": "dotnet format",
        "cwd": "{projectRoot}"
      }
    },
    "lint": {
      "executor": "nx:run-commands",
      "cache": true,
      "dependsOn": ["restore"],
      "options": {
        "command": "dotnet format --verify-no-changes --no-restore",
        "cwd": "{projectRoot}"
      }
    },
    "test": {
      "executor": "nx:run-commands",
      "cache": true,
      "dependsOn": ["build"],
      "outputs": ["{workspaceRoot}/dist/coverage/{projectName}"],
      "options": {
        "cwd": "{workspaceRoot}",
        "command": "dotnet test {projectRoot} --no-build --no-restore --settings coverage.runsettings --results-directory dist/coverage/{projectName}"
      }
    }
  }
}
EOF
else
  echo "==> writing project.json -> $OUTPUT_DIR/project.json"
  cat > "$PROJECT_JSON" <<EOF
{
  "\$schema": "${SCHEMA_PREFIX}node_modules/nx/schemas/project-schema.json",
  "name": "${NX_PROJECT_NAME}",
  "targets": {
    "format": {
      "executor": "nx:run-commands",
      "options": {
        "command": "dotnet format",
        "cwd": "{projectRoot}"
      }
    },
    "lint": {
      "executor": "nx:run-commands",
      "cache": true,
      "dependsOn": ["restore"],
      "options": {
        "command": "dotnet format --verify-no-changes --no-restore",
        "cwd": "{projectRoot}"
      }
    }
  }
}
EOF
fi

# --- normalize the generated sources ------------------------------------------
# Some templates (e.g. webapi) write .cs files without the UTF-8 BOM that the
# root .editorconfig requires, which would make the new project's `lint`
# target fail right away. Folder mode needs no restore.
echo "==> normalizing sources to the repo .editorconfig (dotnet format whitespace)"
dotnet format whitespace --folder "$WORKSPACE_ROOT/$OUTPUT_DIR"

echo ""
echo "Done. Next steps:"
echo "  pnpm restore          # restore NuGet packages"
echo "  nx show project ${NX_PROJECT_NAME}   # verify Nx targets"
