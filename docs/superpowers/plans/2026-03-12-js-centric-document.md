# JS-Centric Document Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** document preset を `js` package 中心の薄い構成に戻し、この repo 固有の補助機能だけを追加する

**Architecture:** `lib/adapters/js.typ` は `js.with(...)` と bibliography/title helper の薄い adapter に戻す。`lib/presets/document.typ` は `js` の上に数式・囲み枠・注釈などの補助機能だけを足し、starter/example では個別のフォント workaround を持たない。

**Tech Stack:** Typst 0.14, `@preview/js:0.1.3`, local `lib/components/*`

---

## Chunk 1: Simplify document preset around `js`

### Task 1: Remove document-specific font overrides and keep added features

**Files:**
- Modify: `lib/adapters/js.typ`
- Modify: `lib/core/locale.typ`
- Modify: `lib/presets/document.typ`
- Modify: `examples/document-jp.typ`
- Modify: `starters/document-jp.typ`

- [ ] **Step 1: Write the failing regression check**

Run: `typst compile --root . examples/document-jp.typ /tmp/js-document.pdf`
Expected: current implementation contains custom document font workaround not aligned with the new design

- [ ] **Step 2: Run test to verify it fails**

Run: `typst compile --root . examples/document-jp.typ /tmp/js-document.pdf`
Expected: compile succeeds but implementation still carries custom font logic outside `js`

- [ ] **Step 3: Write minimal implementation**

Remove custom document font wrappers from `lib/`, keep only `js` plus document-specific math/bibliography helpers, and update examples/starters to rely on the preset without local font overrides.

- [ ] **Step 4: Run test to verify it passes**

Run: `typst compile --root . starters/document-jp.typ /tmp/starter-js-document.pdf`
Run: `typst compile --root . examples/document-jp.typ /tmp/example-js-document.pdf`
Expected: both compile successfully and use the plain `js`-based document layout plus repository features

- [ ] **Step 5: Commit**

```bash
git add lib starters/document-jp.typ examples/document-jp.typ
git commit -m "refactor: make document preset js-centric"
```
