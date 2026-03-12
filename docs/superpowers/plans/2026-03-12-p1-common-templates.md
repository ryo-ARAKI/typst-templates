# P1 Common Templates Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `document / slide / poster` の完成形テンプレートを維持したまま、共通設定・共通部品・外部依存 adapter を分離し、P1 の重複削減と保守性向上を完了する

**Architecture:** `lib/core` にテーマと locale 基盤、`lib/components` に再利用部品、`lib/adapters` に外部 package 依存、`lib/presets` に用途別既定値を置く。`starters` は最小の入口だけを持ち、旧テンプレートは新構成への薄い互換レイヤにする。

**Tech Stack:** Typst 0.14, Universe packages (`js`, `touying`, `peace-of-posters`, `pinit`, `physica`, `cetz`, `theorion`, `showybox`, `fletcher`)

---

## Chunk 1: Scaffold common library layout

### Task 1: Add regression fixture commands and create target directories

**Files:**
- Create: `docs/architecture.md`
- Create: `docs/dependencies.md`
- Create: `lib/core/config.typ`
- Create: `lib/core/locale.typ`
- Create: `lib/core/tokens.typ`
- Create: `lib/components/boxes.typ`
- Create: `lib/components/math.typ`
- Create: `lib/adapters/js.typ`
- Create: `lib/adapters/touying.typ`
- Create: `lib/adapters/peace-of-posters.typ`
- Create: `lib/presets/document.typ`
- Create: `lib/presets/slide.typ`
- Create: `lib/presets/poster.typ`
- Create: `starters/document-jp.typ`
- Create: `starters/slide.typ`
- Create: `starters/poster.typ`
- Create: `examples/document/basic.typ`
- Create: `examples/slide/basic.typ`
- Create: `examples/poster/basic.typ`

- [ ] **Step 1: Write the failing regression check**

Run: `typst compile starters/document-jp.typ /tmp/p1-document.pdf`
Expected: FAIL because `starters/document-jp.typ` does not exist

- [ ] **Step 2: Run the failing regression check**

Run: `typst compile starters/document-jp.typ /tmp/p1-document.pdf`
Expected: non-zero exit with file-not-found

- [ ] **Step 3: Add minimal scaffolding and docs**

Create the directories and minimal Typst modules so the new starter files can import the new structure.

- [ ] **Step 4: Run compile checks for all starters**

Run: `typst compile starters/document-jp.typ /tmp/p1-document.pdf`
Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf`
Run: `typst compile starters/poster.typ /tmp/p1-poster.pdf`
Expected: all succeed, though styling can still be basic

- [ ] **Step 5: Commit**

```bash
git add docs lib starters examples
git commit -m "feat: scaffold common typst template library"
```

## Chunk 2: Move shared locale and math behavior

### Task 2: Centralize Japanese text and equation helpers

**Files:**
- Modify: `lib/core/locale.typ`
- Modify: `lib/components/math.typ`
- Modify: `lib/presets/document.typ`
- Modify: `lib/presets/slide.typ`
- Modify: `lib/presets/poster.typ`
- Modify: `starters/document-jp.typ`
- Modify: `starters/slide.typ`
- Modify: `starters/poster.typ`
- Modify: `utils.typ`
- Modify: `annotated-equation.typ`

- [ ] **Step 1: Write the failing regression check**

Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf`
Expected: FAIL or still depend on old direct helper definitions

- [ ] **Step 2: Run the failing regression check**

Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf`
Expected: failure caused by missing central helper wiring

- [ ] **Step 3: Implement shared locale and math modules**

Move `jp-spacing`, Japanese regex text handling, math font helpers, and `pinit-highlight-equation-from` into the new library modules. Keep `utils.typ` and `annotated-equation.typ` as compatibility re-exports.

- [ ] **Step 4: Run starter compile checks again**

Run: `typst compile starters/document-jp.typ /tmp/p1-document.pdf`
Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf`
Run: `typst compile starters/poster.typ /tmp/p1-poster.pdf`
Expected: all succeed using the shared modules

- [ ] **Step 5: Commit**

```bash
git add lib starters utils.typ annotated-equation.typ
git commit -m "refactor: share locale and math helpers"
```

## Chunk 3: Replace slide box state logic with shared components

### Task 3: Build reusable box components and remove convergence-prone state

**Files:**
- Modify: `lib/components/boxes.typ`
- Modify: `lib/adapters/touying.typ`
- Modify: `lib/presets/slide.typ`
- Modify: `lib/presets/poster.typ`
- Modify: `global-slide.typ`
- Modify: `template_slide.typ`
- Modify: `template_poster.typ`

- [ ] **Step 1: Write the failing regression check**

Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf 2>/tmp/p1-slide.log`
Expected: log currently contains `layout did not converge within 5 attempts`

- [ ] **Step 2: Run the regression check to verify the warning exists**

Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf 2>/tmp/p1-slide.log`
Run: `rg "layout did not converge" /tmp/p1-slide.log`
Expected: one match

- [ ] **Step 3: Implement shared box components**

Replace state-array numbering with stable counters or explicit numbering hooks, expose `question`, `answer`, `summary`, and no-number variants from `lib/components/boxes.typ`, and wire slide/poster presets to use them.

- [ ] **Step 4: Re-run compile and warning checks**

Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf 2>/tmp/p1-slide.log`
Run: `typst compile starters/poster.typ /tmp/p1-poster.pdf`
Run: `rg "layout did not converge" /tmp/p1-slide.log`
Expected: compile succeeds and `rg` finds no matches

- [ ] **Step 5: Commit**

```bash
git add lib global-slide.typ template_slide.typ template_poster.typ starters
git commit -m "refactor: share box components across slide and poster"
```

## Chunk 4: Introduce adapters, presets, and thin starters

### Task 4: Make completed templates consume presets instead of inline configuration

**Files:**
- Modify: `lib/adapters/js.typ`
- Modify: `lib/adapters/touying.typ`
- Modify: `lib/adapters/peace-of-posters.typ`
- Modify: `lib/presets/document.typ`
- Modify: `lib/presets/slide.typ`
- Modify: `lib/presets/poster.typ`
- Modify: `template_document_jp.typ`
- Modify: `template_slide.typ`
- Modify: `template_poster.typ`
- Modify: `README.md`

- [ ] **Step 1: Write the failing regression check**

Run: `typst compile template_document_jp.typ /tmp/p1-document-legacy.pdf`
Expected: FAIL after removing inline config until compatibility wrappers are restored

- [ ] **Step 2: Run the failing regression check**

Run: `typst compile template_document_jp.typ /tmp/p1-document-legacy.pdf`
Expected: non-zero exit caused by moved preset code

- [ ] **Step 3: Implement adapters and compatibility wrappers**

Make presets the canonical implementation, keep old template entry files as thin wrappers or starter-like examples, and document the new import points in `README.md`.

- [ ] **Step 4: Run full compile matrix**

Run: `typst compile starters/document-jp.typ /tmp/p1-document.pdf`
Run: `typst compile starters/slide.typ /tmp/p1-slide.pdf`
Run: `typst compile starters/poster.typ /tmp/p1-poster.pdf`
Run: `typst compile template_document_jp.typ /tmp/p1-document-legacy.pdf`
Run: `typst compile template_slide.typ /tmp/p1-slide-legacy.pdf`
Run: `typst compile template_poster.typ /tmp/p1-poster-legacy.pdf`
Expected: all six compiles succeed

- [ ] **Step 5: Commit**

```bash
git add README.md lib starters template_document_jp.typ template_slide.typ template_poster.typ docs
git commit -m "refactor: route templates through shared presets"
```
