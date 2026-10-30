---
name: plan-story
description: Turn a user story with status "ready" into an implementation plan the coder can follow, and decide the architecture it needs. Use when planning a story or when a story was sent back with findings that need a design change.
---

# Plan a story

Input: a story file with status `ready` (see the `user-stories` skill). Output:
the story's "Implementation plan" section, updated architecture documentation,
status `planned`.

## Steps

1. **Understand the story.** Read it completely, plus the product vision
   (`docs/src/content/docs/stories/product-vision.md`), related stories and the
   current arc42 documentation (`docs/src/content/docs/arc42/`). If an
   acceptance criterion is ambiguous, write the open question into the plan
   section and stop — do not invent requirements.
2. **Make the architecture decisions the story needs.** For the first story this
   includes the foundations: stack and libraries, project layout, API style,
   persistence, testing strategy. Record every significant decision as an ADR
   and update the affected arc42 sections (see the `arc42-documentation` skill).
   Prefer decisions that fit the workspace (`AGENTS.md`): Nx targets, the
   scaffolding script, central package management, generated API clients,
   oxlint/oxfmt.
3. **Define the contract first.** If the story touches the API, specify the
   endpoints (method, path, request/response shape, status codes, validation
   rules) before any implementation detail. Backend and frontend are built
   against this contract.
4. **Write the plan** into "Implementation plan":
   - affected or new projects (with paths) and how to create them (scaffolding
     script, `package.json` scripts),
   - the API contract from step 3,
   - data model and migrations,
   - UI changes (pages, routes, components) in a sentence each,
   - an ordered task list small enough to verify one by one,
   - for each acceptance criterion: which test level proves it (unit,
     integration, e2e),
   - links to the ADRs and arc42 sections you changed.
5. **Check the docs build**: `pnpm nx build docs` must pass.
6. Set the status to `planned`.

## Guidelines

- Plan for the smallest change that satisfies the acceptance criteria; leave
  "nice to have" ideas out or list them as follow-ups.
- Do not write production code. Small code snippets in the plan are fine when
  they pin down a contract.
- Reuse what exists: check the building block view and existing projects before
  proposing new ones.
- When a story comes back with findings that require a design change, update the
  plan and the ADRs instead of patching around them.
