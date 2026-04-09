# Poster Ready Citation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `examples/poster.typ` and `starters/poster.typ` ready to use `@key` citations immediately by default.

**Architecture:** Keep the existing poster citation implementation unchanged and wire the two entry files to it explicitly. Each poster entry file will opt into citations by setting `metadata.bibliography`, calling `#setup-poster(config: metadata)`, and adding `#show ref: poster-citation-ref.with(config: metadata)` in source order.

**Tech Stack:** Typst preset files, README docs, `typst compile --root .`, `pdftotext`

---

## File Structure

- Modify: `examples/poster.typ`
  Turn the full poster example into a citation-ready example and add one visible `@Tanogami2024_information` use.
- Modify: `starters/poster.typ`
  Make the starter citation-ready by default with the same setup lines and bibliography path.
- Modify: `README.md`
  Note that the poster starter/example already include the citation-ready setup.

### Task 1: Make `examples/poster.typ` citation-ready

**Files:**
- Modify: `examples/poster.typ`
- Test: `examples/poster.typ`

- [ ] **Step 1: Write the failing example change**

Update `examples/poster.typ` so that:

```typ
  bibliography: "/examples/biblio.bib",
```

replaces:

```typ
  bibliography: none,
```

Add the setup lines in this order:

```typ
#show: poster-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)
#poster-title()
```

and add a short citation example in the left column:

```typ
      == 参考文献
      @Tanogami2024_information
```

- [ ] **Step 2: Run the example to verify the change works**

Run: `typst compile --root . examples/poster.typ /tmp/examples-poster-ready.pdf`

Expected: PASS

- [ ] **Step 3: Verify the rendered citation text**

Run: `pdftotext /tmp/examples-poster-ready.pdf -`

Expected: extracted text contains `Tanogami and Araki, Phys. Rev. Res., 6 (2024)`

- [ ] **Step 4: Commit the example update**

```bash
git add examples/poster.typ
git commit -m "feat: ready poster example for citations"
```

### Task 2: Make `starters/poster.typ` citation-ready

**Files:**
- Modify: `starters/poster.typ`
- Test: `starters/poster.typ`

- [ ] **Step 1: Write the starter update**

Update `starters/poster.typ` so that:

```typ
  bibliography: "/examples/biblio.bib",
```

replaces:

```typ
  bibliography: none,
```

and change the setup block to:

```typ
#show: poster-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)
#poster-title()
```

- [ ] **Step 2: Run the starter to verify it passes**

Run: `typst compile --root . starters/poster.typ /tmp/starters-poster-ready.pdf`

Expected: PASS

- [ ] **Step 3: Commit the starter update**

```bash
git add starters/poster.typ
git commit -m "feat: ready poster starter for citations"
```

### Task 3: Update README and run regression checks

**Files:**
- Modify: `README.md`
- Test: `README.md`

- [ ] **Step 1: Update the README poster guidance**

Add a short note near the poster citation explanation saying that `examples/poster.typ` and `starters/poster.typ` already include:

```typ
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)
```

so `@BibKey` works immediately.

- [ ] **Step 2: Run the final verification set**

Run: `typst compile --root . examples/poster.typ /tmp/examples-poster-ready.pdf`

Expected: PASS

Run: `typst compile --root . starters/poster.typ /tmp/starters-poster-ready.pdf`

Expected: PASS

Run: `typst compile --root . examples/document-jp.typ /tmp/document-jp-ready.pdf`

Expected: PASS

Run: `pdftotext /tmp/examples-poster-ready.pdf -`

Expected: extracted text contains `Tanogami and Araki, Phys. Rev. Res., 6 (2024)`

- [ ] **Step 3: Commit the documentation**

```bash
git add README.md
git commit -m "docs: note citation-ready poster templates"
```
