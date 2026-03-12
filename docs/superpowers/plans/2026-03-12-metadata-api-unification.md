# Metadata API Unification Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `document / slide / poster` の metadata API を共通化し、starter/example が同じ設定 schema を使う状態にする

**Architecture:** `lib/core/metadata.typ` に metadata 正規化関数を追加し、preset ごとの adapter は正規化済み metadata を target-specific rendering に変換する。移行期間は旧キーを受け付けるが、starter/example は新 schema に統一する。

**Tech Stack:** Typst 0.14, local `lib/core/*`, local `lib/presets/*`, Universe packages (`js`, `touying`, `peace-of-posters`)

---

## Chunk 1: Define shared metadata schema in core

### Task 1: Add normalization helpers and shared defaults

**Files:**
- Create: `lib/core/metadata.typ`
- Modify: `lib/core/config.typ`
- Modify: `lib/core/tokens.typ`

- [ ] **Step 1: Write the failing regression check**

Run: `rg -n "author:|authors:|abstract:|summary:|venue:" starters examples`
Expected: mixed key names and mixed author shapes across targets

- [ ] **Step 2: Run the failing regression check**

Run: `rg -n "author:|authors:|abstract:|summary:|venue:" starters examples`
Expected: `slide` uses `author`, `document` uses tuple-style `authors`, and `poster` uses raw content `authors`

- [ ] **Step 3: Write minimal implementation**

Add normalization helpers that:
- accept a shared metadata dictionary
- coerce old `author` into `authors`
- coerce tuple-style document authors into a structured author list
- expose helper accessors for title, subtitle, authors, abstract, summary, venue, logo, bibliography

- [ ] **Step 4: Run the verification**

Run: `typst compile --root . starters/document-jp.typ /tmp/p2-meta-document.pdf`
Expected: document starter still compiles with no visible regression

- [ ] **Step 5: Commit**

```bash
git add lib/core
git commit -m "refactor: add shared metadata normalization"
```

## Chunk 2: Rewire presets to consume normalized metadata

### Task 2: Update document, slide, and poster presets

**Files:**
- Modify: `lib/adapters/js.typ`
- Modify: `lib/presets/document.typ`
- Modify: `lib/presets/slide.typ`
- Modify: `lib/presets/poster.typ`

- [ ] **Step 1: Write the failing regression checks**

Run: `typst compile --root . starters/slide.typ /tmp/p2-slide-before.pdf`
Run: `typst compile --root . starters/poster.typ /tmp/p2-poster-before.pdf`
Expected: current presets still depend on target-specific metadata keys

- [ ] **Step 2: Run the failing regression checks**

Run the commands above and inspect preset code to confirm:
- `slide` reads `author`
- `poster` reads target-specific raw `authors`
- `document` expects `js`-specific author shape

- [ ] **Step 3: Write minimal implementation**

Update presets so they:
- call metadata normalization once
- render title/author/date/summary/venue from normalized metadata
- keep compatibility with old config keys during migration

- [ ] **Step 4: Run the verification**

Run: `typst compile --root . starters/document-jp.typ /tmp/p2-document.pdf`
Run: `typst compile --root . starters/slide.typ /tmp/p2-slide.pdf`
Run: `typst compile --root . starters/poster.typ /tmp/p2-poster.pdf`
Expected: all starters compile using normalized metadata

- [ ] **Step 5: Commit**

```bash
git add lib/adapters lib/presets
git commit -m "refactor: make presets consume shared metadata"
```

## Chunk 3: Migrate starter and example entrypoints

### Task 3: Rewrite starter/example configs to the unified schema

**Files:**
- Modify: `starters/document-jp.typ`
- Modify: `starters/slide.typ`
- Modify: `starters/poster.typ`
- Modify: `examples/document-jp.typ`
- Modify: `examples/slide.typ`
- Modify: `examples/poster.typ`

- [ ] **Step 1: Write the failing regression check**

Run: `rg -n "author:|authors:" starters examples`
Expected: starters/examples still use multiple incompatible metadata shapes

- [ ] **Step 2: Run the failing regression check**

Run: `rg -n "author:|authors:" starters examples`
Expected: inconsistent metadata literals across entrypoints

- [ ] **Step 3: Write minimal implementation**

Update all entrypoints to one schema, for example:

```typ
#let metadata = (
  title: [Title],
  subtitle: [Subtitle],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [ryo@example.com],
    ),
  ),
  date: [2026-03-12],
  summary: [short summary],
  abstract: [abstract text],
  venue: [conference info],
)
```

- [ ] **Step 4: Run the verification**

Run: `typst compile --root . examples/document-jp.typ /tmp/p2-example-document.pdf`
Run: `typst compile --root . examples/slide.typ /tmp/p2-example-slide.pdf`
Run: `typst compile --root . examples/poster.typ /tmp/p2-example-poster.pdf`
Expected: all examples compile and show the intended metadata

- [ ] **Step 5: Commit**

```bash
git add starters examples
git commit -m "refactor: unify starter and example metadata schema"
```

## Chunk 4: Document the unified API and remove ambiguity

### Task 4: Update repository docs

**Files:**
- Modify: `README.md`
- Modify: `docs/architecture.md`
- Modify: `docs/dependencies.md`

- [ ] **Step 1: Write the failing regression check**

Run: `rg -n "author|authors|summary|abstract|venue" README.md docs`
Expected: docs still describe or imply target-specific metadata naming

- [ ] **Step 2: Run the failing regression check**

Run the command above and note stale terminology or examples

- [ ] **Step 3: Write minimal implementation**

Document:
- the unified metadata schema
- which keys are optional by target
- the temporary compatibility behavior for old keys

- [ ] **Step 4: Run the verification**

Run: `typst compile --root . starters/document-jp.typ /tmp/p2-doc-final.pdf`
Run: `typst compile --root . starters/slide.typ /tmp/p2-slide-final.pdf`
Run: `typst compile --root . starters/poster.typ /tmp/p2-poster-final.pdf`
Run: `typst compile --root . examples/document-jp.typ /tmp/p2-example-doc-final.pdf`
Run: `typst compile --root . examples/slide.typ /tmp/p2-example-slide-final.pdf`
Run: `typst compile --root . examples/poster.typ /tmp/p2-example-poster-final.pdf`
Expected: all compile successfully after docs-aligned API cleanup

- [ ] **Step 5: Commit**

```bash
git add README.md docs
git commit -m "docs: describe unified metadata api"
```
