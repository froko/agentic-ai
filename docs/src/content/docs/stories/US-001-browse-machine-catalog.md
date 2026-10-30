---
title: 'US-001: Browse the machine catalog'
status: ready
---

## Story

As a **service technician** I want **to see our product line with each model's
descale interval** so that **I know how often a machine of that model needs a
service visit**.

## Context

This is the first story. Besides the catalog itself it establishes the
application: a backend with persistent storage, a web frontend and the
navigation that later stories extend. See the
[product vision](../product-vision/).

The product line is reference data maintained by the development team. A fresh
installation (including a developer's local environment) must contain exactly
these models:

| Name            | Category    | Descale interval (cups) |
| --------------- | ----------- | ----------------------- |
| Barista Pro 900 | Espresso    | 1,500                   |
| BeanMaster 3000 | Bean-to-cup | 3,000                   |
| CapsuleOne      | Capsule     | 2,000                   |
| FilterFlow XL   | Filter      | 5,000                   |

The categories are fixed: Espresso, Bean-to-cup, Filter, Capsule.

## Acceptance criteria

- **AC1** — Given a fresh installation, when I open the application, then I see
  a navigation with an entry "Catalog".
- **AC2** — Given a fresh installation, when I open the catalog, then I see the
  four models from the table above with name, category and descale interval.
- **AC3** — Given the catalog is shown, then the models are sorted by name, and
  descale intervals are shown with a thousands separator (e.g. "1,500 cups").
- **AC4** — Given the backend cannot be reached, when I open the catalog, then I
  see an error message instead of an empty list.

## Out of scope

- Creating, editing or deleting models in the user interface.
- Prices, images or technical specifications of the models.

<!-- The sections below are filled in by the agent team. -->

## Implementation plan

## Implementation notes

## Verification

## Review
