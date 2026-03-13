# Examples Catalog Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `examples/` を用途別の機能カタログとして追加し、document / slide / poster の実装済み機能を一覧できるようにする

**Architecture:** `examples/` は `starters/` と同じ 3 ファイル構成にし、各 example は `lib/presets` と既存 component を直接使って機能を明示的に並べる。例示内容は最小 starter より広く、部品カタログとしての可読性を優先する。

**Tech Stack:** Typst 0.14, local `lib/` presets/components, Universe packages already used by the library

---

## Chunk 1: Add example catalog entrypoints

### Task 1: Create document, slide, and poster catalogs

**Files:**
- Create: `examples/document-jp.typ`
- Create: `examples/slide.typ`
- Create: `examples/poster.typ`
- Modify: `README.md`

- [ ] **Step 1: Write the failing regression check**

Run: `typst compile --root . examples/document-jp.typ /tmp/example-document.pdf`
Expected: FAIL because `examples/document-jp.typ` does not exist

- [ ] **Step 2: Run test to verify it fails**

Run: `typst compile --root . examples/document-jp.typ /tmp/example-document.pdf`
Expected: non-zero exit with file-not-found

- [ ] **Step 3: Write minimal implementation**

Create the three `examples/*.typ` files and populate each with a catalog of current features using the shared presets and components.

- [ ] **Step 4: Run test to verify it passes**

Run: `typst compile --root . examples/document-jp.typ /tmp/example-document.pdf`
Run: `typst compile --root . examples/slide.typ /tmp/example-slide.pdf`
Run: `typst compile --root . examples/poster.typ /tmp/example-poster.pdf`
Expected: all three succeed

- [ ] **Step 5: Commit**

```bash
git add examples README.md
git commit -m "feat: add typst examples catalog"
```
