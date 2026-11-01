# AI assistant instructions

Vendor-neutral guidance for AI coding assistants working in this repository.
This file follows the [AGENTS.md](https://agents.md) convention and is read
automatically by several assistants (OpenCode, Cursor, Aider, Gemini CLI, and
others). Tools that look for their own instruction file (e.g. Claude Code's
`CLAUDE.md` or GitHub Copilot's `.github/copilot-instructions.md`) can point to
this file instead of duplicating its contents.

For full project documentation, see [`README.md`](./README.md).

## Workspace layout

This template supports two use cases. Choose folders based on what the repo is
building, and make sure the chosen folders are registered in
`pnpm-workspace.yaml`:

- **Applications** (default): `apps/` for deployable applications, `libs/` for
  internal libraries consumed within the repo. `apps/*` and `libs/*` are already
  registered.
- **Publishable NuGet libraries**: `packages/` for libraries that are packed and
  published as NuGet packages, `examples/` for sample apps that consume them.
  Register `packages/*` and `examples/*` in `pnpm-workspace.yaml` before adding
  projects there.

## User stories and the agent team

Features are delivered as user stories in `docs/src/content/docs/stories/` (one
file per story, status in the frontmatter). A team of four agents works on them;
each agent is a short role description in `.claude/agents/`, and its know-how
lives in skills in `.claude/skills/`:

| Agent       | Status change          | Skills                              |
| ----------- | ---------------------- | ----------------------------------- |
| `architect` | ready → planned        | `plan-story`, `arc42-documentation` |
| `coder`     | planned → implemented  | `implement-story`                   |
| `tester`    | implemented → verified | `verify-story`                      |
| `reviewer`  | verified → done        | `review-story`                      |

All agents share the `user-stories` skill (story format, statuses, Definition of
Done). The `deliver-story` skill describes how the main session runs a story
through the team and commits it. The architecture documentation (arc42 and ADRs)
lives in `docs/src/content/docs/arc42/` and is owned by the architect.
Assistants without native skill support can read the `SKILL.md` files directly.

## Converting to a publishable NuGet library workspace

When the user asks to convert the workspace from the default application layout
(`apps/` + `libs/`) to a publishable NuGet library layout (`packages/` +
`examples/`), perform **all** of the following steps. The folder names appear in
several places — missing any one of them leaves the workspace in an inconsistent
state.

1. **`pnpm-workspace.yaml`** — replace the `apps/*` and `libs/*` globs with
   `packages/*` and `examples/*` (keep `docs`):

   ```yaml
   packages:
     - 'packages/*'
     - 'examples/*'
     - 'docs'
   ```

2. **Move existing .NET projects.** Relocate any libraries from `libs/` into
   `packages/` and any applications from `apps/` into `examples/` (the sample
   ships in `libs/sample-lib` and `libs/sample-lib-tests`). Use `git mv` so
   history is preserved, then fix the relative `$schema` path and any
   `ProjectReference`/`reference` paths in the moved `project.json` and
   `.csproj` files. If the user prefers a clean slate, delete the samples and
   scaffold fresh projects with the wrapper script instead.

3. **Make libraries packable.** For each project under `packages/`, set the
   NuGet metadata (`PackageId`, `Authors`, `Description`, …) and set
   `<IsPackable>true</IsPackable>` in its `.csproj` (packing is opt-in: the root
   `Directory.Build.props` defaults `IsPackable` to `false`; keep test projects
   non-packable). Shared metadata can go centrally in `Directory.Build.props`.
   See [Publishing NuGet packages](#publishing-nuget-packages).

4. **Remove now-empty `apps/`/`libs/` folders** once their projects have moved.

5. **Restore and verify.** Run `pnpm restore`, then `pnpm build`, `pnpm test`,
   and `pnpm format` to confirm the workspace is consistent after the move.

After the conversion, create new projects in `packages/` (libraries/tests) and
`examples/` (sample apps), not `apps/`/`libs/`.

## Creating new .NET projects

**Always create new .NET projects with the wrapper script, not `dotnet new`
directly.**

```bash
# Application workspace
scripts/new-dotnet-project.sh classlib -o libs/my-lib -n MyLib              # internal library
scripts/new-dotnet-project.sh webapi   -o apps/my-api -n MyApi              # application
scripts/new-dotnet-project.sh xunit    -o libs/my-lib-tests -n MyLib.Tests  # test project

# Publishable NuGet library workspace
scripts/new-dotnet-project.sh classlib -o packages/my-package -n MyPackage                # publishable package
scripts/new-dotnet-project.sh xunit    -o packages/my-package-tests -n MyPackage.Tests    # test project
scripts/new-dotnet-project.sh console  -o examples/my-package-sample -n MyPackage.Sample  # sample app
```

The script runs the same `dotnet new` command and then:

1. adds a workspace-standard `project.json` so the project picks up the shared
   Nx targets automatically (a `format` and a `lint` target for every project,
   plus a coverage-enabled `test` target for test projects),
2. tidies the generated `.csproj` so it matches the repo conventions (see
   below), and
3. normalizes the generated files to the root `.editorconfig` (UTF-8 with BOM),
   which not every template follows. It skips the template's automatic restore,
   which would fail before the tidy step (`NU1008`); `build` restores later.

Using `dotnet new` on its own skips both steps and produces a project without
the expected `format`/`lint`/`test` targets and with settings that conflict with
the repo-wide defaults.

### How the generated `.csproj` is tidied

`dotnet new` emits properties that are already defined globally and pins package
versions inline, neither of which fits this repo. The script rewrites the
`.csproj` to:

- **Inherit from `Directory.Build.props`** — properties that are set centrally
  (`TargetFramework`, `ImplicitUsings`, `Nullable`) are removed from the
  `.csproj` so they are inherited rather than duplicated. An empty
  `<PropertyGroup>` left behind is dropped.
- **Use Central Package Management (CPM)** — the repo enables CPM via
  `Directory.Packages.props` (`ManagePackageVersionsCentrally` is `true`). The
  script strips the inline `Version="…"` from every `<PackageReference>` and
  records it as a `<PackageVersion>` entry in `Directory.Packages.props`. With
  CPM enabled, a `<PackageReference>` that still carries a `Version` fails to
  restore (`NU1008`).

When editing or adding .NET projects by hand, follow the same rules: never
re-declare the globally-inherited properties, and never put a `Version` on a
`<PackageReference>` — add/update the `<PackageVersion>` in
`Directory.Packages.props` instead.

- Test projects are detected from the template (`xunit`/`nunit`/`mstest`) or an
  output directory ending in `-tests`. Override with `TEST_PROJECT=1` /
  `TEST_PROJECT=0`.
- Any extra arguments are passed straight through to `dotnet new`.
- Place projects in the folder that matches the use case (see Workspace layout).
- After creating (or pulling) .NET projects, run `pnpm restore` once (`build`
  and `lint` also restore automatically).

## Creating new JavaScript/TypeScript projects

There is no generator for JS/TS projects; create the `package.json`,
`tsconfig.json` and sources by hand. A `package.json` in `apps/*` or `libs/*` is
picked up by Nx automatically and its `scripts` become Nx targets. Configure
caching, outputs, task dependencies and continuous tasks (dev servers) in the
`nx` section of the `package.json`; use `"nx": { "name": "…" }` to keep the
project name consistent with the .NET projects (kebab-case, no npm scope).

Every JS/TS project must define these scripts so it takes part in the
workspace-wide tasks (`pnpm lint`, `pnpm format`, `nx affected`):

| Script      | Command                           | Purpose                                  |
| ----------- | --------------------------------- | ---------------------------------------- |
| `lint`      | `oxlint && oxfmt --check`         | lint + fail on unformatted code          |
| `format`    | `oxfmt`                           | write formatting fixes                   |
| `typecheck` | `tsc --noEmit`                    | type errors (part of `pnpm affected`)    |
| `test`      | e.g. `vitest run`                 | unit tests, if the project has any       |
| `build`     | e.g. `tsc --noEmit && vite build` | production build, if the project has one |
| `e2e`       | e.g. `playwright test`            | end-to-end tests (e2e projects only)     |

- oxlint and oxfmt find the root `oxlint.config.ts`/`oxfmt.config.ts` from any
  project folder; projects need no config of their own.
- Put generated code into a `generated/` folder; it is excluded from oxfmt and
  oxlint.
- Build output goes to the central `dist/` folder (e.g. Vite
  `build.outDir: '../../dist/apps/<project>'`), like the .NET projects.
- Reference workspace packages with `"workspace:*"` and run `pnpm install`
  afterwards.

## Publishing NuGet packages

For the publishable-library use case, every non-test project has a `pack` target
from the `@nx/dotnet` plugin (`nx pack <project>` or `nx run-many -t pack`) that
builds a `.nupkg` into `dist/`. Packing is opt-in: `Directory.Build.props`
defaults `IsPackable` to `false`, so `pack` only produces a `.nupkg` for
projects that set `<IsPackable>true</IsPackable>`. Set package metadata
(`PackageId`, `Authors`, `Description`, …) in the `.csproj` or centrally in
`Directory.Build.props`.

On release, semantic-release packs all packable projects and pushes them with
`scripts/publish-nuget.sh` using the `NUGET_API_KEY` repository secret. If no
`.nupkg` is produced (the application layout), the publish step is skipped.

## Conventions

- This is an Nx + pnpm monorepo for .NET and JavaScript/TypeScript projects,
  plus an Astro docs site.
- Shared .NET defaults (`TargetFramework`, `Nullable`, `ImplicitUsings`, central
  `dist/` output) live in the root `Directory.Build.props` — do not duplicate
  them per project.
- Test coverage settings are centralized in `coverage.runsettings`; the `test`
  target writes a Cobertura report to `dist/coverage/<project-name>`.
- For .NET projects the `format` target runs `dotnet format` (writes fixes) and
  the `lint` target runs `dotnet format --verify-no-changes --no-restore` (fails
  if the code is not formatted). Both live in each project's `project.json`.
- Everything else (JavaScript/TypeScript, Markdown, JSON, YAML) is formatted by
  **oxfmt** (`oxfmt.config.ts`, based on `@froko/oxfmt-config`) and
  JavaScript/TypeScript is linted by **oxlint** (`oxlint.config.ts`, based on
  `@froko/oxlint-config`). Every JS/TS project runs them through its own `lint`
  and `format` targets (see
  [Creating new JavaScript/TypeScript projects](#creating-new-javascripttypescript-projects)).
  Files outside the projects (root configs, `README.md`, `AGENTS.md`, workflows)
  are covered by `pnpm format:workspace` and `pnpm lint:workspace`;
  `pnpm format` and `pnpm lint` run both. Do not add Prettier or ESLint.
- Commit messages follow
  [Conventional Commits](https://www.conventionalcommits.org/).
- Common tasks: `pnpm build`, `pnpm test`, `pnpm lint`, `pnpm format`,
  `pnpm e2e`, `pnpm restore` (each maps to an `nx run-many` target; `lint` and
  `format` also cover the workspace-level files).
- Before finishing a change, run `pnpm format` and `pnpm affected` (lint,
  typecheck, build and test of the affected projects).
