---
title: 'US-007: Report and resolve malfunctions'
status: ready
---

## Story

As a **customer care agent** I want **to record a malfunction a customer reports
for a machine** and as a **service technician** I want **to track it until it is
resolved** so that **no reported problem gets lost**.

## Context

Customers call when a machine leaks, shows an error or makes bad coffee. A
malfunction belongs to exactly one machine and goes through these states:

```
Open → In progress → Resolved
```

| Field       | Rules                                                                    |
| ----------- | ------------------------------------------------------------------------ |
| Description | required, 10–1,000 characters                                            |
| Severity    | required: Low, Normal or Critical (machine unusable); defaults to Normal |
| Reported on | set automatically to the current date and time                           |
| Resolution  | required when resolving, max. 1,000 characters                           |

A malfunction can be moved forward only (Open → In progress → Resolved); it can
also be resolved directly from Open. Resolved malfunctions cannot be changed
anymore.

## Acceptance criteria

- **AC1** — Given a machine's page, when I report a malfunction with a
  description and severity, then it appears on the machine's page with status
  "Open", severity and the report date and time.
- **AC2** — Given an open malfunction, when I start working on it, then its
  status is "In progress"; when I resolve it with a resolution text, then its
  status is "Resolved" and the resolution and resolution date are shown.
- **AC3** — Given I try to resolve a malfunction without a resolution text, or
  to report one with a description shorter than 10 characters, then nothing is
  saved and I see what is wrong.
- **AC4** — Given a resolved malfunction, then it offers no actions anymore, and
  the backend rejects any attempt to change it.
- **AC5** — Given the navigation, then there is an entry "Malfunctions" that
  lists all malfunctions that are not resolved, with machine serial number,
  customer, severity, status and report date; Critical first, then by report
  date, oldest first.
- **AC6** — Given the fleet page (US-005), then it shows the number of
  unresolved malfunctions, and each machine with an unresolved Critical
  malfunction is marked in the list.

## Out of scope

- Assigning malfunctions to a specific technician.
- Notifying customers about the progress.
- Attachments such as photos.

<!-- The sections below are filled in by the agent team. -->

## Implementation plan

## Implementation notes

## Verification

## Review
