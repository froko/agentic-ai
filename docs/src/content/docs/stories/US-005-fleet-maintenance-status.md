---
title: "US-005: See the fleet's maintenance status"
status: ready
---

## Story

As a **service dispatcher** I want **to see which machines need a service visit
soon** so that **I can plan the technicians before a machine runs past its
descale interval**.

## Context

Each machine has a maintenance status, calculated from its cups since last
service (US-004) and its model's descale interval (US-001):

| Status   | Rule                                                 | Label    |
| -------- | ---------------------------------------------------- | -------- |
| OK       | cups since last service < 80% of the interval        | OK       |
| Due soon | 80% ≤ cups since last service < 100% of the interval | Due soon |
| Overdue  | cups since last service ≥ 100% of the interval       | Overdue  |

Example for a Barista Pro 900 (interval 1,500): 1,199 cups → OK, 1,200 cups →
Due soon, 1,500 cups → Overdue.

The status is used in many places (fleet overview, machine page, later stories),
so it must be calculated in one place and always be up to date — there is no
manual status.

## Acceptance criteria

- **AC1** — Given the rules above, when a machine's cups since last service
  change, then its status changes accordingly — including exactly at the 80% and
  100% boundaries.
- **AC2** — Given the navigation, then there is an entry "Fleet" that is the
  application's start page.
- **AC3** — Given the fleet page, then I see the number of machines per status
  (OK, Due soon, Overdue) and the total number of machines.
- **AC4** — Given the fleet page, then it lists all machines with serial number,
  model, customer, location, cups since last service, the share of the descale
  interval used (e.g. "1,305 / 1,500 cups · 87%") and the status.
- **AC5** — Given the list, then it is sorted by urgency: Overdue first, then
  Due soon, then OK; within a status by the share of the interval used, highest
  first.
- **AC6** — Given the list, when I choose a status filter (All, Overdue, Due
  soon, OK), then only matching machines are shown, and the chosen filter is
  kept in the URL so I can share or reload the filtered view.
- **AC7** — Given a machine's page, then it shows the status and the share of
  the interval used in the same way as the fleet list.
- **AC8** — Given the status is shown anywhere, then it is distinguishable not
  only by color (it always shows the label).

## Out of scope

- Notifications (email, push) when a machine becomes due.
- Planning or assigning technicians.

<!-- The sections below are filled in by the agent team. -->

## Implementation plan

## Implementation notes

## Verification

## Review
