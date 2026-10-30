---
name: review-story
description: Review the changes of a verified user story against the acceptance criteria, the architecture documentation and the workspace conventions, and decide whether it is done. Use when a story has status "verified".
---

# Review a story

Input: a story with status `verified` (see the `user-stories` skill) and the
uncommitted changes in the working tree. Output: the story's "Review" section
with a verdict, status `done` or back to `planned`.

## Gather the change

- `git status` and `git diff` (plus untracked files) show everything the story
  changed. Read the story completely, including all team sections.
- Read the ADRs and arc42 sections the plan links to and `AGENTS.md`.

## Checklist

1. **Requirements:** every acceptance criterion is implemented as written — no
   more, no less — and the Verification section maps each `ACn` to a passing
   test.
2. **Architecture:** the change follows the plan and the ADRs; new decisions are
   recorded as ADRs; the arc42 sections touched by the change (building blocks,
   runtime, glossary, …) are up to date.
3. **Correctness:** edge cases, validation and error handling; no data loss or
   security problems (input validation, injection, secrets in code or logs).
4. **Tests:** meaningful assertions, error paths covered, no skipped or weakened
   tests, no flaky waits.
5. **Conventions:** `AGENTS.md` rules and "Known pitfalls" (scaffolding script,
   central package versions, generated code regenerated and not hand-edited,
   lint/format targets for new projects).
6. **Simplicity:** no dead code, no speculative abstractions, no unrelated
   changes.
7. **Definition of Done:** run `pnpm format` (must change nothing),
   `pnpm affected` and `pnpm e2e` yourself.

## Verdict

Write into "Review":

- **Verdict:** `approved` or `changes requested`.
- **Findings:** one bullet per issue with file path, what is wrong and why it
  matters. Mark each as `must fix` or `suggestion`. Only `must fix` findings
  block the story.

Set the status to `done` when approved, otherwise back to `planned` (findings
about the design go to the architect, code findings to the coder).

## Rules

- You read and run checks; the only file you edit is the story file (your
  "Review" section and the status). Never change code, tests or docs.
- Judge against the story and the documented architecture, not personal taste.
  If the architecture itself looks wrong, say so as a finding for the architect.
