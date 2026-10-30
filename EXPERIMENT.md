# Experiment: an agent team builds Brewfleet

Can a small team of AI agents — architect, coder, tester, reviewer — build a
full-stack application from user stories in this workspace, with the
architecture documented as it grows?

The application is **Brewfleet**, a service console for a coffee machine vendor.

## What is prepared

| What                    | Where                                                                      |
| ----------------------- | -------------------------------------------------------------------------- |
| Product vision          | `docs/src/content/docs/stories/product-vision.md`                          |
| User stories            | `docs/src/content/docs/stories/US-001-….md` to `US-007-….md` (all `ready`) |
| Agents                  | `.claude/agents/` — `architect`, `coder`, `tester`, `reviewer`             |
| Skills (agent know-how) | `.claude/skills/` — one per role, plus `user-stories` and `deliver-story`  |
| Architecture docs       | `docs/src/content/docs/arc42/` — still the empty arc42 template            |
| Workspace conventions   | `AGENTS.md`, including "Known pitfalls" of the stack                       |

The flow of a story is described in `.claude/skills/deliver-story/SKILL.md`:

```
ready ──architect──▶ planned ──coder──▶ implemented ──tester──▶ verified ──reviewer──▶ done
                        ▲                                │                     │
                        └─────────── findings ───────────┴─────────────────────┘
```

Each agent writes its result into its section of the story file and advances the
`status`. Agents never commit; the main session commits when a story is `done`.

## 1. Prepare (once)

1. Check the toolchain — everything must pass on a clean `main`:

   ```bash
   git switch main && git status        # clean working tree
   pnpm install
   pnpm all                             # lint, typecheck, build, test
   ```

2. Arch Linux only: make sure `aspnet-targeting-pack` is installed
   (`pacman -Q aspnet-targeting-pack`), otherwise ASP.NET Core projects fail
   with `NETSDK1226`.
3. Make sure `apps/` and `libs/` contain no ignored files such as local
   databases or stray `node_modules`:

   ```bash
   git clean -ndX apps libs   # preview
   git clean -fdX apps libs   # remove
   ```

4. Create the experiment branch. Story branches are created from it and merged
   back into it, so `main` stays untouched and the experiment can be repeated:

   ```bash
   git switch -c experiment/agent-team-1
   ```

## 2. Start a fresh session

1. Start a **new** Claude Code session in the repository root (agents and skills
   are loaded at session start, and a fresh context starts the team without
   prior knowledge).
2. Check that the team is there: `/agents` lists `architect`, `coder`, `tester`
   and `reviewer`; typing `/` shows the `deliver-story` skill.
3. Choose a permission mode that lets the agents edit files and run `pnpm`,
   `dotnet` and `git` commands without asking every time — otherwise you will
   approve hundreds of prompts.

## 3. Deliver the stories

Run the stories **in order**; each builds on the previous ones:

```
/deliver-story US-001
```

The main session creates `story/US-001-…`, runs architect → coder → tester →
reviewer, loops back on findings, commits when the story is `done` and merges
the story branch back into `experiment/agent-team-1`.

**Your role during a run**

- Answer questions the agents cannot decide (unclear acceptance criteria) —
  answer as the product owner, do not design the solution.
- Do things that need `sudo`, e.g. when the tester reports
  `error while loading shared libraries`: `scripts/install-playwright-deps.sh`.
- Do not fix code yourself; if you intervene, note it in the log (section 5).

**After each story**

1. Look at the result: `pnpm dev` (or whatever the architect documented) and
   `pnpm nx dev docs` for the architecture docs.
2. Fill in the observation log.
3. Run `/clear` before the next story — everything the team needs is in the
   files and in git, and a fresh context keeps the main session focused.
4. Continue with `/deliver-story US-002`, and so on.

## 4. If something goes wrong

| Situation                                      | What to do                                                                                     |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Session crashed or was interrupted             | `/deliver-story US-00x` again — it resumes from the story's current `status`                   |
| A story goes back to `planned` more than twice | the main session stops and asks you; decide as product owner or simplify the story             |
| Work is hopelessly broken                      | `git switch experiment/agent-team-1`, delete the story branch, reset the story file's `status` |
| `pnpm restore` reports `0 tasks`               | the `restore` option of `@nx/dotnet` in `nx.json` was lost (see `AGENTS.md`)                   |
| Ports already in use                           | an old dev server is still running; stop it                                                    |

## 5. Observation log

Record per story; it is the basis for evaluating the experiment. Keep the log on
the experiment branch (edit this file there).

| Story  | Duration | Rounds back (tester / reviewer) | Your interventions | ADRs added | Tests (unit / integration / e2e) | Notes |
| ------ | -------- | ------------------------------- | ------------------ | ---------- | -------------------------------- | ----- |
| US-001 |          |                                 |                    |            |                                  |       |
| US-002 |          |                                 |                    |            |                                  |       |
| US-003 |          |                                 |                    |            |                                  |       |
| US-004 |          |                                 |                    |            |                                  |       |
| US-005 |          |                                 |                    |            |                                  |       |
| US-006 |          |                                 |                    |            |                                  |       |
| US-007 |          |                                 |                    |            |                                  |       |

Questions to answer at the end:

- Does every acceptance criterion have a test, and do the tests prove it?
- Does the arc42 documentation describe the system as it was built? Would a new
  developer find their way with it?
- Which decisions did the architect make, and would you have made them?
- Where did agents get stuck, and was it a skill, the workspace or the story?
- What should change in the skills, agents or stories before the next run?

## 6. Improve and repeat

Improve the skills or stories on `main`, then start a new branch
`experiment/agent-team-2` from `main` and run again from step 2. Compare the
runs with each other:

```bash
git diff --stat experiment/agent-team-1 experiment/agent-team-2
```

Look at the same pages side by side, the test suites and the docs site.
