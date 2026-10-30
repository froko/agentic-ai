---
name: verify-story
description: Verify an implemented user story against its acceptance criteria by writing Playwright end-to-end tests and running the full test suite. Use when a story has status "implemented".
---

# Verify a story

Input: a story with status `implemented` (see the `user-stories` skill). Output:
end-to-end tests for every acceptance criterion, the story's "Verification"
section, status `verified` — or status `planned` with findings.

## Steps

1. **Derive test cases from the acceptance criteria**, not from the code. Each
   `ACn` gets at least one Playwright test whose name contains the criterion,
   e.g. `test('AC2: rejects a duplicate serial number', …)`. Add negative cases
   where a criterion implies them.
2. **Write the tests** in the e2e project (see "Setting up e2e tests" if none
   exists yet). Use user-facing locators (`getByRole`, `getByLabel`,
   `getByText`); avoid CSS selectors and test ids unless there is no accessible
   alternative.
3. **Run everything**: `pnpm e2e` and `pnpm affected`. Use
   `--output-style=static` to see the test output.
4. **Explore once by hand**: run the app and try the story's edge cases that are
   hard to automate (wrong input, empty states, reloads, narrow screens).
5. **Report** in "Verification":
   - a table `Acceptance criterion | Tests | Result`,
   - every bug found, with steps to reproduce, expected and actual result.
6. Set the status to `verified` if all criteria pass. Otherwise set it back to
   `planned` and leave the findings for the coder.

## Setting up e2e tests

If the workspace has no e2e project yet, create one (e.g. `apps/<app>-e2e`) with
`@playwright/test`, the standard `package.json` scripts from `AGENTS.md` plus an
`e2e` script, and Nx `implicitDependencies` on the app projects. Make it
independent of a running dev server:

- start the backend and frontend from `playwright.config.ts` (`webServer`) on
  their own ports, with a throwaway database,
- make tests independent of each other and of existing data (unique values, e.g.
  timestamps),
- reset shared state only in the main process
  (`!process.env.TEST_WORKER_INDEX`).

If Chromium fails to start with `error while loading shared libraries`, ask the
user to run `scripts/install-playwright-deps.sh` (needs `sudo`).

## Rules

- Do not fix production code yourself; report the bug instead. Fixing test code
  and test infrastructure is your job.
- Never weaken an assertion just to make a test pass. If a criterion cannot be
  tested automatically, say so in the report and describe the manual check.
- Do not commit.
