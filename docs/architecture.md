# Architecture

## Layers

- `starters/lib/core`: language, font, color, spacing, and config defaults
- `starters/lib/components`: reusable boxes and equation annotation helpers
- `starters/lib/adapters`: direct integration points with Universe packages
- `starters/lib/presets`: target-specific defaults for document, slide, and poster
- `starters`: minimal entrypoints for new work
- `examples`: tiny examples that point to starters

## Rules

- Keep package-specific logic inside `starters/lib/adapters`
- Keep user-facing template defaults inside `starters/lib/presets`
- Prefer configuration dictionaries over duplicated literals
- Keep legacy top-level templates as compatibility entrypoints
