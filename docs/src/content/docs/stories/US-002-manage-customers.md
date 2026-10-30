---
title: 'US-002: Manage customers'
status: ready
---

## Story

As a **customer care agent** I want **to register our customers with their
address and contact person** so that **technicians know where machines are
installed and whom to call**.

## Context

Customers are companies (offices, clinics, restaurants) in Switzerland. A
customer can have several machines at different locations; machines are added in
US-003. Customers are never deleted because their machines' history must stay
available.

Customer fields:

| Field          | Rules                                                 |
| -------------- | ----------------------------------------------------- |
| Name           | required, 2–100 characters, unique (case-insensitive) |
| Street         | required, max. 100 characters                         |
| Postal code    | required, exactly 4 digits (Swiss postal code)        |
| City           | required, max. 60 characters                          |
| Contact person | optional, max. 100 characters                         |
| Phone          | optional, max. 30 characters                          |
| Email          | optional, must be a valid email address               |

Leading and trailing spaces are removed from all fields before saving.

## Acceptance criteria

- **AC1** — Given I am on the customer list, when I register a customer with
  valid data, then the customer appears in the list with name, postal code and
  city.
- **AC2** — Given the customer list, then customers are sorted by name and I can
  narrow the list by typing part of the name or city into a search field.
- **AC3** — Given a customer "Alpine Analytics AG" exists, when I register
  "alpine analytics ag" again, then the customer is not saved and I see the
  message "A customer with this name already exists."
- **AC4** — Given I enter invalid data (e.g. postal code "80A1", missing city,
  invalid email), when I save, then nothing is saved and each invalid field
  shows what is wrong.
- **AC5** — Given a customer exists, when I open it, then I see all its details
  and can edit them with the same rules as when registering.
- **AC6** — Given no customer exists yet, when I open the customer list, then I
  see a hint that there are no customers yet and a way to register the first
  one.

## Out of scope

- Deleting or archiving customers.
- Several addresses or contact persons per customer.
- Importing customers from other systems.

<!-- The sections below are filled in by the agent team. -->

## Implementation plan

## Implementation notes

## Verification

## Review
