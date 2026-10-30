---
title: About user stories
sidebar:
  order: 0
---

The [product vision](product-vision/) describes what we build and for whom; it
applies to every story.

Every user story is one Markdown file in this folder, named
`US-<number>-<short-title>.md`. Copy the template from
`.claude/skills/user-stories/template.md` to start a new story, fill in the
story, context and acceptance criteria, and set `status: ready`.

The agent team then works on the story and fills in the remaining sections:

| Status        | Next step                                                   |
| ------------- | ----------------------------------------------------------- |
| `ready`       | the **architect** writes the implementation plan and ADRs   |
| `planned`     | the **coder** implements it with unit and integration tests |
| `implemented` | the **tester** verifies every acceptance criterion (e2e)    |
| `verified`    | the **reviewer** checks it against the Definition of Done   |
| `done`        | the story is finished and committed                         |

Write acceptance criteria as numbered, observable `Given / When / Then`
statements (`AC1`, `AC2`, …); each of them becomes at least one automated test.
The full rules, including the Definition of Done, are in
`.claude/skills/user-stories/SKILL.md`.
