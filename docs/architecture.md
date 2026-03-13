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

## Metadata Flow

- `lib/core/metadata.typ` normalizes target-specific config into a shared `metadata` dictionary
- `lib/core/config.typ` injects normalized `metadata` into `document-config`, `slide-config`, and `poster-config`
- `lib/presets/document.typ`, `lib/presets/slide.typ`, and `lib/presets/poster.typ` render from normalized metadata instead of target-specific keys
- `starters/*` and `examples/*` should define one `#let metadata = (...)` literal and pass it to the preset with `config: metadata`
