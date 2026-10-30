---
name: implement-story
description: Implement a planned user story (backend, API contract, frontend) with unit and integration tests, following the story's implementation plan and the workspace conventions. Use when a story has status "planned".
---

# Implement a story

Input: a story with status `planned` (see the `user-stories` skill). Output:
working code with tests, the story's "Implementation notes" section, status
`implemented`.

## Before you start

- Read the whole story: acceptance criteria, implementation plan, and — if the
  story was sent back — the findings in "Verification" and "Review". Fix those
  findings first.
- Read the ADRs and arc42 sections the plan links to, and `AGENTS.md`
  (conventions and "Known pitfalls").
- If the plan is wrong or incomplete, do not redesign on your own: describe the
  problem in "Implementation notes" and stop so the architect can update the
  plan.

## Order of work

Follow the plan's task list. Unless the plan says otherwise:

1. **Projects.** Create .NET projects only with `scripts/new-dotnet-project.sh`;
   create JS/TS projects with the standard scripts from `AGENTS.md` ("Creating
   new JavaScript/TypeScript projects").
2. **Domain and persistence.** Business rules in the domain model with unit
   tests; schema changes only through migrations.
3. **API.** Implement the contract exactly as planned (paths, payloads, status
   codes, validation). Cover each endpoint with integration tests, including the
   error cases.
4. **Contract artifacts.** Regenerate generated code (e.g. the OpenAPI document
   and the TypeScript client) after every API change; never edit generated files
   by hand.
5. **Frontend.** Use the generated client; keep components small and test
   presentational components and helpers with unit tests.

Write tests together with the code, not afterwards. End-to-end tests are the
tester's job, but make the UI testable: real labels on form fields, buttons with
accessible names, stable texts for status and error messages.

## Finish

1. Run `pnpm format`, then `pnpm affected` (lint, typecheck, build, test).
   Everything must pass; fix failures instead of weakening tests or lint rules.
2. Start the application once (`pnpm dev` or the equivalent defined by the
   architecture) and check the happy path of each acceptance criterion by
   calling the API or loading the page.
3. Write "Implementation notes": what was built (projects, endpoints, pages),
   anything that deviates from the plan and why, and how to try it out.
4. Set the status to `implemented`.

## Rules

- Stay within the story's scope; note follow-up ideas instead of building them.
- No new dependency without an ADR or an explicit mention in the plan; add .NET
  package versions only to `Directory.Packages.props`.
- Do not commit; the main session commits when the story is `done`.
