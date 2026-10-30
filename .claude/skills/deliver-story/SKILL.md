---
name: deliver-story
description: Deliver a user story end-to-end with the agent team (architect → coder → tester → reviewer) and commit it. Use when the user asks to implement, build or deliver a story such as "US-003".
argument-hint: <story id, e.g. US-003>
---

# Deliver a story with the agent team

You are the team lead in the main session. You coordinate; the agents do the
work. Stories, statuses and the Definition of Done are described in the
`user-stories` skill.

## Team

| Agent       | Moves the story        | Skills                              |
| ----------- | ---------------------- | ----------------------------------- |
| `architect` | ready → planned        | `plan-story`, `arc42-documentation` |
| `coder`     | planned → implemented  | `implement-story`                   |
| `tester`    | implemented → verified | `verify-story`                      |
| `reviewer`  | verified → done        | `review-story`                      |

## Workflow

1. **Pick the story.** Find the file in `docs/src/content/docs/stories/`
   (`$ARGUMENTS` names it). It must have status `ready` (or a later status if
   you resume). Make sure the working tree is clean, note the current branch
   (the _base branch_, e.g. `main` or an experiment branch), then create a
   branch `story/US-<number>-<short-title>` from it. Stories build on each
   other, so never branch from a different branch than the current one.
2. **Run the agents one after another**, each with a short prompt that names the
   story file and its task, e.g. "Plan the story
   docs/src/content/docs/stories/US-003-….md". Agents run sequentially: they
   share one working tree.
3. **After each agent, check the result yourself:** read the story file (new
   section filled in, status advanced) and look at `git status`. If an agent
   stopped with an open question, ask the user and pass the answer on.
4. **Follow the status:**
   - `planned` after tester or reviewer → findings exist. Send design findings
     to the `architect` and code findings to the `coder`, then continue the
     normal flow from there.
   - Stop and ask the user if a story goes back more than twice, or if an agent
     needs something only the user can do (e.g. `sudo` installs).
5. **Commit when the story is `done`.** Run `pnpm format` and confirm
   `git status` contains only changes that belong to the story. Commit in
   logical steps with Conventional Commits (e.g. `docs(arc42): …`,
   `feat(api): …`, `feat(web): …`, `test(e2e): …`), each referencing the story
   ID. Then switch back to the base branch and merge the story branch with
   `git merge --ff-only`, so the next story starts from it. Do not push unless
   the user asks.
6. **Report** to the user: what was built, test results, ADRs added, open
   follow-ups from the agents' sections.

## Rules

- Do not do the agents' work yourself; if a result is not good enough, send the
  agent back with concrete feedback.
- One story at a time per working tree.
