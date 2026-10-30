---
title: 'US-006: Record a service visit'
status: ready
---

## Story

As a **service technician** I want **to record that I descaled and serviced a
machine** so that **its descale interval starts again and the visit is
documented**.

## Context

A service visit includes descaling and a general check. Technicians usually
record the visit on site, but sometimes a day later.

Service visit fields:

| Field         | Rules                                                                            |
| ------------- | -------------------------------------------------------------------------------- |
| Technician    | required, max. 100 characters                                                    |
| Visit date    | required, not in the future, not before the installation date; defaults to today |
| Counter value | required, the meter reading at the visit; same rules as a reading in US-004      |
| Notes         | optional, max. 500 characters                                                    |

Recording a visit also records its counter value as a meter reading (US-004),
then resets the machine's cups since last service to 0.

## Acceptance criteria

- **AC1** — Given a machine with status "Due soon", when I record a service
  visit with valid data, then the machine's cups since last service are 0 and
  its status is "OK" (US-005).
- **AC2** — Given the latest reading is 2,000, when I record a visit with
  counter value 2,150, then a meter reading of 2,150 is added, the machine's
  total cups include the 150 cups, and only then the cups since last service are
  reset to 0.
- **AC3** — Given I enter invalid data (missing technician, a date in the future
  or before the installation, a counter lower than the latest reading), when I
  save, then nothing is saved and each invalid field shows what is wrong.
- **AC4** — Given a machine has service visits, when I open the machine, then I
  see its service history newest first, each with date, technician, notes and
  the number of cups brewed since the previous visit (or since installation for
  the first visit).
- **AC5** — Given a machine has never been serviced, when I open it, then the
  service history says "No service visits recorded yet."

## Out of scope

- Spare parts and working hours.
- Editing or deleting a service visit.
- Signatures or photos.

<!-- The sections below are filled in by the agent team. -->

## Implementation plan

## Implementation notes

## Verification

## Review
