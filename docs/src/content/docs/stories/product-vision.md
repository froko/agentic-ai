---
title: Product vision
sidebar:
  order: 1
---

## Brewfleet — service console for a coffee machine vendor

We sell and lease professional coffee machines to offices, clinics and
restaurants in Switzerland. Our service technicians keep the machines running:
they install them at the customer's site, read the cup counters, descale the
machines in time and repair them when they break.

Today this is tracked in spreadsheets. Machines are descaled too late, which
damages them and annoys customers, and nobody has an overview of the whole
fleet. **Brewfleet** replaces the spreadsheets with one web application.

## Users

| Role                | Goal                                                              |
| ------------------- | ----------------------------------------------------------------- |
| Service technician  | records installations, meter readings, service visits and repairs |
| Service dispatcher  | sees which machines need attention and plans the technicians' day |
| Customer care agent | registers customers and malfunction reports from customers        |

All three roles use the same application and see the same data; there are no
permissions to distinguish them yet.

## Goals

1. No machine runs past its descaling interval unnoticed.
2. Every machine's history (installation, readings, services, malfunctions) is
   available in one place.
3. Recording a reading or a service visit takes less than a minute, also on a
   tablet at the customer's site.

## Quality goals

| Priority | Quality         | What it means for Brewfleet                                                         |
| -------- | --------------- | ----------------------------------------------------------------------------------- |
| 1        | Correctness     | maintenance status and counters are always right; invalid input is rejected clearly |
| 2        | Usability       | works on desktop and tablet (from 768 px width), forms explain what is wrong        |
| 3        | Maintainability | a new developer can add a feature by following the documented architecture          |

## Boundaries

- No login or user management in the first release; the application runs in the
  company network.
- One company, one language: the user interface is in English.
- The product line (machine models) is fixed reference data maintained by the
  development team, not by users.
- No integration with other systems (ERP, invoicing) yet.

## Glossary seeds

| Term             | Meaning                                                                       |
| ---------------- | ----------------------------------------------------------------------------- |
| Machine model    | a product in our product line, e.g. "Barista Pro 900"                         |
| Machine          | one physical coffee machine, identified by its serial number                  |
| Meter reading    | the machine's total cup counter at a point in time                            |
| Descale interval | number of cups a model may brew between two service visits                    |
| Service visit    | descaling and maintenance by a technician; resets the cups since last service |
| Malfunction      | a problem reported for a machine, tracked until it is resolved                |
