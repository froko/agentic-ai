---
title: 'US-003: Install a machine at a customer site'
status: ready
---

## Story

As a **service technician** I want **to register a machine I installed at a
customer's site** so that **the machine is tracked from its first cup on**.

## Context

Every machine has a serial number printed on its type plate (e.g. `BF-1001`) and
a cup counter that never resets. Machines are sometimes refurbished, so a new
installation may start with a counter above zero.

Installation fields:

| Field                 | Rules                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------ |
| Serial number         | required, 3–32 characters: letters, digits and hyphens; stored in upper case; unique       |
| Model                 | required, one of the catalog models (US-001)                                               |
| Customer              | required, an existing customer (US-002)                                                    |
| Location              | required, max. 200 characters, where on site the machine stands (e.g. "3rd floor kitchen") |
| Installation date     | required, not in the future; defaults to today                                             |
| Initial meter reading | required, whole number ≥ 0; defaults to 0                                                  |

The initial meter reading counts as the machine's first meter reading (see
US-004). A newly installed machine counts as freshly serviced: its "cups since
last service" start at 0.

## Acceptance criteria

- **AC1** — Given I open a customer (US-002), when I install a machine with
  valid data, then I am taken to the new machine's page, which shows serial
  number, model, customer, location, installation date and the initial meter
  reading.
- **AC2** — Given I enter the serial number " bf-2001 ", when I save, then the
  machine is stored as "BF-2001".
- **AC3** — Given a machine "BF-2001" is installed, when I install another
  machine with serial number "bf-2001", then nothing is saved and I see the
  message "A machine with serial number BF-2001 is already installed."
- **AC4** — Given I enter invalid data (e.g. serial number "B!", an installation
  date in the future, a negative meter reading), when I save, then nothing is
  saved and each invalid field shows what is wrong.
- **AC5** — Given a customer has machines, when I open the customer, then I see
  its machines with serial number, model and location, and can open each one.
- **AC6** — Given the navigation, then there is an entry "Machines" that lists
  all installed machines with serial number, model, customer and location,
  sorted by serial number.

## Out of scope

- Moving a machine to another customer or location.
- Decommissioning machines.
- Maintenance status (US-005) and meter readings after installation (US-004).

<!-- The sections below are filled in by the agent team. -->

## Implementation plan

## Implementation notes

## Verification

## Review
