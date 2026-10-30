---
title: 'US-004: Record meter readings'
status: ready
---

## Story

As a **service technician** I want **to record the cup counter I read from a
machine** so that **we know how many cups it has brewed since its last
service**.

## Context

The cup counter on the machine only counts up; technicians read it whenever they
are on site. They enter the absolute counter value, not a difference — the
system calculates the cups brewed since the previous reading.

Reading fields:

| Field         | Rules                                                                                               |
| ------------- | --------------------------------------------------------------------------------------------------- |
| Counter value | required, whole number, at least the value of the machine's latest reading                          |
| Reading date  | required, not in the future, not before the date of the machine's latest reading; defaults to today |

The cups brewed since a reading are added to the machine's **total cups** and
its **cups since last service**. The installation's initial meter reading
(US-003) is the first reading of every machine.

## Acceptance criteria

- **AC1** — Given a machine whose latest reading is 1,200, when I record a
  reading of 1,450, then the machine shows a counter of 1,450 and its cups since
  last service grow by 250.
- **AC2** — Given a machine whose latest reading is 1,200, when I record a
  reading of 1,100, then nothing is saved and I see the message "The counter
  cannot be lower than the latest reading (1,200)."
- **AC3** — Given I record the same value as the latest reading, then the
  reading is saved and the cups since last service stay unchanged (the machine
  was not used).
- **AC4** — Given I enter a reading date in the future or before the latest
  reading's date, when I save, then nothing is saved and the date field shows
  what is wrong.
- **AC5** — Given a machine has several readings, when I open the machine, then
  I see its readings newest first, each with date, counter value and the cups
  brewed since the previous reading.
- **AC6** — Given I recorded a reading, then the form is cleared and ready for
  the next reading without reloading the page.

## Out of scope

- Correcting or deleting a reading.
- Reading the counter automatically from the machine.

<!-- The sections below are filled in by the agent team. -->

## Implementation plan

## Implementation notes

## Verification

## Review
