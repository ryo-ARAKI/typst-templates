# Dependencies

## Core Packages

- `@preview/js:0.1.3`
  Used for Japanese document layout and title helpers in `document`.
- `@preview/touying:0.6.2`
  Used for slide theming and slide utilities in `slide`.
- `@preview/peace-of-posters:0.5.6`
  Used for poster layout primitives in `poster`.

## Shared Packages

- `@preview/pinit:0.2.2`
  Equation annotation pins and arrows.
- `@preview/physica:0.9.8`
  Physics-oriented math shortcuts used in examples.
- `@preview/cetz:0.4.2`
  Drawing utilities used by slide and poster examples.
- `@preview/showybox:2.0.4`
  Highlight box for poster callouts.

## Support Packages

- `@preview/theorion:0.4.1`
  Legacy theorem-style boxes in poster examples.
- `@preview/fletcher:0.5.8`
  Diagram primitives for poster figures.
- `@preview/unify:0.7.1`
  Unit-aware helpers for documents.
- `@preview/roremu:0.1.0`
  Dummy Japanese text for documents.
- `@preview/enja-bib:0.1.0`
  Japanese bibliography helpers for documents.

## Update Guidance

- Check `starters/lib/adapters` first when a package update breaks compilation.
- Keep `starters/lib/core` free from package-specific APIs where possible.
- If a package becomes unstable, replace its adapter before touching starters.
