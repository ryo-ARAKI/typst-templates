# Architecture

## Purpose

Reuse Japanese and Latin typography, page layouts, and common writing and drawing helpers in Typst documents, slides, and A0 posters. Projects keep their own content, images, and bibliography and can import a preset from a pinned Git submodule.

The RevTeX preprint style also supports copying into a separate project. Its style file uses Typst's built-in features. The sample manuscript supplies its own bibliography and authoring imports.

## Responsibilities and dependencies

| Path | Responsibility |
| --- | --- |
| `starters/` | Editable starting points for each layout |
| `examples/` | Independently compilable demonstrations of the preset APIs |
| `lib/presets/` | Public document, slide, and poster entry points |
| `lib/adapters/` | Imports and integration with js, Touying, and Peace of Posters |
| `lib/components/` | Reusable boxes, aligned lists, math, and CeTZ overlays |
| `lib/core/` | Preset defaults, author input normalization, typography tokens, locale helpers, and journal abbreviations |
| `standalone/` | Portable preprint style, sample manuscript, and sample bibliography |
| `script/` | Local compilation and checks for rendered output, diagnostics, and links |

Starters and examples import their preset directly. Presets use core defaults, components, and adapters. Components can use core helpers and call drawing or math packages directly. The [package list](dependencies.md) records pinned versions and how they are used.

The preset import paths and re-exports are part of the authoring workflow. For example, conference slides import the slide preset and use Touying helpers from it. Conference posters use the poster preset and its CeTZ and citation helpers. Seminar flyers also import Japanese spacing helpers directly from `lib/core/locale.typ`.

## Configuration and bibliography flow

1. The caller passes a `config:` dictionary. Preset defaults fill omitted keys, and `lib/core/metadata.typ` validates the author list and fills omitted author fields.
2. Each preset reads the resolved dictionary directly and formats authors where they are displayed. The document adapter builds the js title layout and plain PDF author names. Slides build Touying title data. Poster title functions apply their own text sizes to the author fields.
3. Poster layout functions can read the configuration set by the theme when the caller omits `config:`. An explicit configuration uses the preset defaults and the supplied keys.
4. Documents and slides pass bibliographies to Typst. On posters, `setup-poster` registers the bibliography with Typst, and the short citation renderer finds the requested literal BibTeX entry and formats it with the journal abbreviation table. `poster-citation-ref` passes ordinary references back to Typst when the bibliography has no matching key.

The [README](../README.md) specifies public configuration, compile roots, and local verification. Run `bash script/check-local.sh` for the shared presets and `bash script/check-revtex-preprint.sh` for the standalone workflow.
