# P1 Common Templates Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** root に `lib/` と `starters/` を並べた自然な構成へ戻しつつ、`starters/*.typ` を `typst compile --root .` で確実に利用できる状態を作る

**Architecture:** 共有本体は root の `lib/` に置き、`starters/` は compile 対象の最小入口だけに戻す。Typst の root 制約は `typst compile --root . starters/<name>.typ` を正式手順にすることで扱い、starter からは `../lib/...` を import する。

**Tech Stack:** Typst 0.14, Universe packages (`js`, `touying`, `peace-of-posters`, `pinit`, `physica`, `cetz`, `theorion`, `showybox`, `fletcher`)

---

## Chunk 1: Restore root-level library layout

### Task 1: Move the shared library out of `starters/`

**Files:**
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
- Modify: `starters/document-jp.typ`
- Modify: `starters/slide.typ`
- Modify: `starters/poster.typ`
- Modify: `README.md`
- Modify: `docs/architecture.md`
- Modify: `docs/dependencies.md`
- Delete: `starters/lib/**`

- [ ] **Step 1: Write the failing regression check**

Run: `typst compile --root . starters/slide.typ /tmp/p1-slide.pdf`
Expected: FAIL after moving `lib/` out of `starters/` until imports are rewired

- [ ] **Step 2: Run the failing regression check**

Run: `typst compile --root . starters/slide.typ /tmp/p1-slide.pdf`
Expected: non-zero exit caused by missing `lib` import path

- [ ] **Step 3: Move the library and fix import paths**

Move `starters/lib` back to root `lib`, update starter imports to `../lib/...`, and document the `--root .` workflow.

- [ ] **Step 4: Run compile checks for all starters**

Run: `typst compile --root . starters/document-jp.typ /tmp/p1-document.pdf`
Run: `typst compile --root . starters/slide.typ /tmp/p1-slide.pdf`
Run: `typst compile --root . starters/poster.typ /tmp/p1-poster.pdf`
Expected: all succeed with the root-level `lib/`

- [ ] **Step 5: Commit**

```bash
git add docs lib starters
git commit -m "refactor: restore root-level typst library"
```
