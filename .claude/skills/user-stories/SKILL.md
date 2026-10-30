---
name: user-stories
description: Format, location and status workflow of user stories, plus the Definition of Done. Use whenever you read, plan, implement, test or review a user story.
---

# User stories

## Where stories live

- One Markdown file per story in `docs/src/content/docs/stories/`, named
  `US-<number>-<short-title>.md` (e.g. `US-003-record-service-visit.md`).
- Stories are part of the docs site (sidebar group "User Stories"), so the
  frontmatter must contain `title`.
- New stories start from [template.md](template.md).
- `product-vision.md` in the same folder describes the product, its users,
  goals, quality goals and boundaries. It applies to every story.

## Structure

The product owner writes the top part; the team appends one section per role.

| Section                 | Written by    | Content                                      |
| ----------------------- | ------------- | -------------------------------------------- |
| Story, Context          | product owner | "As a … I want … so that …" and background   |
| Acceptance criteria     | product owner | numbered `AC1`, `AC2`, … in Given/When/Then  |
| Out of scope (optional) | product owner | what this story deliberately does not cover  |
| Implementation plan     | architect     | tasks, API contract, affected projects, ADRs |
| Implementation notes    | coder         | what was built, deviations from the plan     |
| Verification            | tester        | result per acceptance criterion, test names  |
| Review                  | reviewer      | verdict and findings                         |

Never change the product owner's sections. If a criterion is unclear or
contradictory, write the question into your own section and stop instead of
guessing.

## Status

The `status` field in the frontmatter moves forward one step at a time:

```
ready → planned → implemented → verified → done
```

| Status        | Set by    | Meaning                                                 |
| ------------- | --------- | ------------------------------------------------------- |
| `ready`       | product   | story is complete and can be planned                    |
| `planned`     | architect | implementation plan is written, architecture is updated |
| `implemented` | coder     | code and unit/integration tests are done, checks pass   |
| `verified`    | tester    | every acceptance criterion has a passing e2e test       |
| `done`        | reviewer  | review approved, Definition of Done met                 |

When the tester or reviewer finds problems, they set the status back to
`planned` and list the findings in their section; the coder picks it up from
there.

## Definition of Done

A story is `done` when all of the following hold:

1. Every acceptance criterion is covered by at least one automated test, and the
   Verification section maps each `ACn` to its tests.
2. `pnpm format` changes nothing and `pnpm affected` (lint, typecheck, build,
   test) and `pnpm e2e` pass.
3. Generated code (e.g. API clients) is regenerated and up to date.
4. The architecture documentation (arc42, ADRs) reflects the change.
5. The code follows `AGENTS.md`, including its "Known pitfalls".
6. Every section of the story file is filled in and the status is `done`.

Agents never commit or push; the main session does that once a story is `done`.
