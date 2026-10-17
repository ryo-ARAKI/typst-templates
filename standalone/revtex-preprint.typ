// Standalone research manuscripts for Typst >= 0.15.0, inspired by RevTeX.
// Copy this file beside a manuscript; see README.md for usage examples.

// Shared appendix state connects the document and appendix show rules.
#let appendix-mode = state("revtex-preprint-appendix", false)
// Keep the native title element available beside the public `title` parameter.
#let native-title = title

/// Style a one-column research manuscript. Apply with `#show: revtex-preprint.with(...)`.
///
/// Front matter: title, PDF title, author/affiliation dictionaries, abstract,
/// keywords and date. Affiliation IDs connect authors to their institutions.
///
/// Layout: `mode: "read"` uses compact leading; `"review"` widens leading and
/// enables line numbers. Explicit `leading` and `line-numbers` take precedence.
/// Font, language, paper and margin parameters set the document typography.
/// With `font: auto`, Japanese uses New Computer Modern with Noto Serif CJK JP
/// for Japanese glyphs; other languages use New Computer Modern.
/// An explicit `font` overrides this language default.
///
/// Numbering: `section-numbering` is a heading pattern; `equation-numbering`
/// selects a continuous `"global"` sequence or a per-section `"section"` sequence.
/// The trailing `body` is supplied by the show rule.
#let revtex-preprint(
  title: [],
  pdf-title: auto,
  authors: (),
  affiliations: (),
  abstract: none,
  keywords: (),
  date: none,

  mode: "read",
  line-numbers: auto,
  leading: auto,
  font: auto,
  math-font: "New Computer Modern Math",
  font-size: 12pt,
  lang: "en",
  paper: "a4",
  margin: 25mm,

  section-numbering: "1.1",
  equation-numbering: "global",
  body,
) = {
  // Validate public inputs before constructing metadata or styled content.
  let check(ok, message) = assert(ok, message: "revtex-preprint: " + message)

  check(type(title) in (str, content), "title must be a string or content")
  check(pdf-title == auto or type(pdf-title) == str, "pdf-title must be auto or a string")
  check(type(authors) == array, "authors must be an array")
  check(type(affiliations) == array, "affiliations must be an array")
  check(abstract == none or type(abstract) == content, "abstract must be content or none")
  check(type(keywords) == array and keywords.all(k => type(k) == str), "keywords must be an array of strings")
  check(date == none or type(date) == datetime, "date must be a datetime or none")
  if date != none {
    check(date.year() != none, "date must include year, month and day (not time only)")
  }

  check(mode in ("read", "review"), "mode must be read or review")
  check(line-numbers == auto or type(line-numbers) == bool, "line-numbers must be auto or a boolean")
  check(leading == auto or type(leading) == length, "leading must be auto or a length")
  check(type(font-size) == length, "font-size must be a length")
  check(type(lang) == str and type(paper) == str, "lang and paper must be strings")

  check(type(section-numbering) == str, "section-numbering must be a numbering pattern string")
  check(equation-numbering in ("global", "section"), "equation-numbering must be global or section")

  // Affiliation order determines the superscript numbers used in front matter.
  let ids = ()
  for affiliation in affiliations {
    check(type(affiliation) == dictionary, "each affiliation must be a dictionary")
    check(type(affiliation.at("id", default: none)) == str, "affiliation.id must be a string")
    check(type(affiliation.at("text", default: none)) == content, "affiliation.text must be content")
    check(not ids.contains(affiliation.id), "duplicate affiliation id: " + affiliation.id)
    ids.push(affiliation.id)
  }

  // Resolve author references and check the optional contact fields.
  let used = ()
  for author in authors {
    check(type(author) == dictionary, "each author must be a dictionary")
    check(type(author.at("name", default: none)) == str, "author.name must be a string")

    let refs = author.at("affiliations", default: ())
    check(type(refs) == array and refs.all(id => type(id) == str), "author.affiliations must be an array of string IDs")
    check(refs.dedup().len() == refs.len(), "duplicate affiliation reference for " + author.name)
    for id in refs {
      check(ids.contains(id), "unknown affiliation id: " + id)
      used.push(id)
    }

    check(type(author.at("corresponding", default: false)) == bool, "author.corresponding must be a boolean")
    for key in ("email", "orcid") {
      if key in author {
        check(type(author.at(key)) == str, "author." + key + " must be a string")
      }
    }

    if "email" in author {
      check(author.email.match(regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) != none, "invalid author.email")
    }
    if "orcid" in author {
      check(author.orcid.match(regex("^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$")) != none, "invalid author.orcid (use xxxx-xxxx-xxxx-xxxx)")
    }
  }

  for id in ids { check(used.contains(id), "unused affiliation id: " + id) }

  // A single affiliation shared by every author is displayed without markers.
  let shared = authors.len() > 0 and ids.len() == 1 and authors.all(
    author => author.at("affiliations", default: ()) == (ids.first(),)
  )

  // Resolve mode defaults once; explicit options override the selected mode.
  let numbered-lines = if line-numbers == auto { mode == "review" } else { line-numbers }
  let line-leading = if leading == auto { if mode == "review" { 1em } else { 0.65em } } else { leading }

  // Document metadata and base typography.
  set document(title: if pdf-title == auto { title } else { pdf-title },
    author: authors.map(author => author.name), keywords: keywords, date: date)
  let body-font = if font != auto { font } else if lang == "ja" { ("New Computer Modern", "Noto Serif CJK JP") } else { "New Computer Modern" }
  set text(font: body-font, size: font-size, lang: lang)
  show math.equation: set text(font: math-font)
  set page(paper: paper, margin: margin, columns: 1, numbering: "1", number-align: center + bottom)
  set par(justify: true, leading: line-leading, first-line-indent: 1em, spacing: 0.8em)

  // Review line numbers belong to prose; element-specific rules below omit them.
  set par.line(numbering: if numbered-lines {
    n => text(size: 8pt, fill: luma(128), str(n))
  } else { none },
    numbering-scope: "document", number-align: right, number-clearance: 8pt)

  // Native headings and equations retain their labels, counters and references.
  set heading(numbering: section-numbering)
  show heading: set par.line(numbering: none)

  // Each numbered top-level heading starts a fresh per-section equation sequence.
  show heading.where(level: 1): it => {
    if equation-numbering == "section" and it.numbering != none {
      counter(math.equation).update(0)
    }
    it
  }

  set math.equation(numbering: n => {
    if equation-numbering == "global" { return numbering("(1)", n) }
    let section = counter(heading).get().first()
    let prefix = numbering(if appendix-mode.get() { "A" } else { "1" }, section)
    [(#prefix.#n)]
  })
  show math.equation.where(block: true): set par.line(numbering: none)

  // Numbering is also measured with provisional counters. Validate in the
  // native element's show context, where errors wait for layout convergence.
  show math.equation.where(block: true): it => {
    if equation-numbering == "section" and it.numbering != none {
      check(counter(heading).get().first() > 0,
        "section equations require a numbered level-1 heading first (also after appendices)")
    }
    it
  }

  // Figures and tables float automatically, with page 1 reserved from top floats.
  set figure(numbering: "1", placement: auto)
  show figure: set par.line(numbering: none)
  show figure: it => {
    if it.placement == none { return it }

    // Change only native floating layout, retaining the original figure, its
    // counter, labels, caption and semantic tags. In-flow figures stay native.
    show place.where(float: true): floating => context {
      let marker = (revtex-preprint-float: it.location())
      // A marker also identifies our replacement and prevents recursive shows.
      if floating.body.has("children") and floating.body.children.len() > 0 {
        let first = floating.body.children.first()
        if first.func() == metadata and first.value == marker { return floating }
      }

      // The source anchor may still be on page 1 when the float is on page 2.
      // Inspect a marker inside the floated body, using physical page numbers.
      let anchors = query(metadata.where(value: marker))
      let first-page = anchors.len() == 0 or anchors.first().location().page() == 1

      let args = floating.fields()
      let alignment = args.remove("alignment")
      let body = args.remove("body")

      if first-page and (alignment == auto or alignment.y == top) {
        let horizontal = if alignment == auto or alignment.x == none {
          align.alignment.x
        } else { alignment.x }
        alignment = bottom + horizontal
      }

      place(alignment, ..args, [#metadata(marker)#body])
    }
    it
  }

  // Compact captions and open tables suit manuscript figures and data.
  show figure.caption: set text(size: 0.9em)
  show figure.caption: set par(first-line-indent: 0pt, justify: false)
  show figure.where(kind: table): set figure.caption(position: top)
  // Pseudocode captions belong above the left-aligned algorithm body.
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set align(left)
  // Open tables. Authors place semantic header and horizontal-rule boundaries.
  set table(stroke: none, inset: (x: 0.7em, y: 0.4em))
  set table.hline(stroke: 0.6pt)

  show footnote.entry: set par.line(numbering: none)
  set bibliography(style: "annual-reviews-author-date", title: [References])

  // Front matter: title, author names, affiliations, contacts and optional date.
  show native-title: set text(size: 1.5 * font-size, weight: "bold")
  show native-title: set align(center)

  // This scope keeps title/affiliation equations outside the body equation count.
  {
    set par.line(numbering: none)
    set math.equation(numbering: none)
    set par(first-line-indent: 0pt, justify: false)

    if title != [] and title != "" { native-title([#title]) }

    if authors.len() > 0 {
      align(center, par(authors.map(author => {
        let refs = author.at("affiliations", default: ())
        [#author.name#if not shared and refs.len() > 0 {
          super(refs.map(id => link(label("revtex-affiliation-" + id), str(ids.position(candidate => candidate == id) + 1))).join(","))
        }#if author.at("corresponding", default: false) { super("*") }]
      }).join(", ", last: " and ")))
    }

    for (index, affiliation) in affiliations.enumerate() {
      align(center, text(size: 0.9em, style: "italic", [#par[
        #if not shared { super(str(index + 1)) }#affiliation.text
      ]#label("revtex-affiliation-" + affiliation.id)]))
    }

    let contacts = authors.filter(a => a.at("corresponding", default: false) or "email" in a or "orcid" in a)
    if contacts.len() > 0 {
      align(center, text(size: 0.85em, contacts.map(a => par[
        #a.name#if a.at("corresponding", default: false) { [ (corresponding author)] }#if "email" in a { [: #link("mailto:" + a.email, a.email)] }#if "orcid" in a { [; #link("https://orcid.org/" + a.orcid, [ORCID #a.orcid])] }
      ]).join()))
    }

    if date != none { align(center, par(date.display("[year]-[month]-[day]"))) }
  }

  // Give Abstract its own heading style; its equations also leave body counts intact.
  if abstract != none {
    {
      show heading: set text(size: font-size, weight: "bold")
      show heading: set align(center)
      show heading: set block(above: 1.2em, below: 0.6em)
      heading(level: 1, numbering: none, outlined: false)[Abstract]
    }

    {
      set math.equation(numbering: none)
      abstract
      parbreak()
    }
  }

  if keywords.len() > 0 {
    block[
      #set par.line(numbering: none)
      #set par(first-line-indent: 0pt, justify: false)
      #text(size: 0.9em)[*Keywords:* #keywords.join(", ")]
    ]
  }

  // Emit the manuscript with the document-wide rules established above.
  body
}

/// Short alias for `revtex-preprint`, with the same parameters and defaults.
#let draft = revtex-preprint

// A common frame keeps both authoring notes distinct from manuscript prose.
#let _authoring-note(label, fill: luma(245), rule: luma(170), body) = block(
  width: 100%,
  fill: fill,
  stroke: (left: 1.5pt + rule),
  inset: 8pt,
  breakable: true,
)[
  #set par(justify: false, first-line-indent: 0pt, leading: 0.5em, spacing: 0.4em)
  #set list(spacing: 0.9em)
  #set par.line(numbering: none)
  #set text(size: 10pt, fill: luma(80), style: "normal")
  #text(size: 8pt, weight: "bold", style: "normal", label)
  #parbreak()
  #body
]

/// Outline/placement notes, matching the original manuscript's gray frame.
/// Inherit the document language unless `lang` is specified on the note.
/// Japanese defaults to a local CJK font, other languages
/// inherit the surrounding font. An explicit `font` overrides either default.
/// `visible: false` removes the note without reserving space or loading its font.
#let outline-note(visible: true, lang: auto, font: auto, body) = {
  if visible {
    context {
      let lang = if lang == auto { text.lang } else { lang }
      set text(font: if font != auto { font } else if lang == "ja" { ("New Computer Modern", "Noto Serif CJK JP") } else { text.font }, lang: lang)
      _authoring-note([OUTLINE NOTE], body)
    }
  }
}

/// Language and font defaults match `outline-note`.
/// Use `.with(visible: false)` to hide all notes of this kind.
#let todo-note(visible: true, lang: auto, font: auto, body) = {
  if visible {
    context {
      let lang = if lang == auto { text.lang } else { lang }
      set text(font: if font != auto { font } else if lang == "ja" { ("New Computer Modern", "Noto Serif CJK JP") } else { text.font }, lang: lang)
      _authoring-note([TODO], fill: rgb("fff0ee"), rule: rgb("c65b50"), body)
    }
  }
}

/// Start the appendices with `#show: appendices` after the main text, once per document.
/// Headings restart at A; the enclosing `revtex-preprint` rule controls equation
/// numbering, while figure and table sequences continue through the appendices.
#let appendices(body) = {
  context {
    assert(not appendix-mode.get(), message: "revtex-preprint: appendices may only be used once")
    appendix-mode.update(true)
    counter(heading).update(0)
  }

  set heading(numbering: "A.1", supplement: [Appendix])
  body
}
