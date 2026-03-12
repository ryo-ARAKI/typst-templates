# Architecture

## Layers

- `lib/core`: language, font, color, spacing, and config defaults
- `lib/components`: reusable boxes and equation annotation helpers
- `lib/adapters`: direct integration points with Universe packages
- `lib/presets`: target-specific defaults for document, slide, and poster
- `starters`: minimal entrypoints for new work
- `examples`: tiny examples that point to starters

## Rules

- Keep package-specific logic inside `lib/adapters`
- Keep user-facing template defaults inside `lib/presets`
- Prefer configuration dictionaries over duplicated literals
- Keep legacy top-level templates as compatibility entrypoints
