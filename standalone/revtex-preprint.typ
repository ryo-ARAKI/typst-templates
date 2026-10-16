// Standalone research manuscripts for Typst >= 0.15.0, inspired by RevTeX.
// Copy this single file beside a manuscript. No imports or extra packages.
// See README.md for the public API; draft is an alias for revtex-preprint.
#let appendix-mode = state("revtex-preprint-appendix", false)
#let native-title = title

#let revtex-preprint(
  title: [], pdf-title: auto, authors: (), affiliations: (),
  abstract: none, keywords: (), date: none,
  mode: "read", line-numbers: auto, leading: auto,
  font: "New Computer Modern", math-font: "New Computer Modern Math",
  font-size: 12pt, lang: "en", paper: "a4", margin: 25mm,
  section-numbering: "1.1", equation-numbering: "global", body,
) = {
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

  let ids = ()
  for affiliation in affiliations {
    check(type(affiliation) == dictionary, "each affiliation must be a dictionary")
    check(type(affiliation.at("id", default: none)) == str, "affiliation.id must be a string")
    check(type(affiliation.at("text", default: none)) == content, "affiliation.text must be content")
    check(not ids.contains(affiliation.id), "duplicate affiliation id: " + affiliation.id)
    ids.push(affiliation.id)
  }
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
  let shared = authors.len() > 0 and ids.len() == 1 and authors.all(
    author => author.at("affiliations", default: ()) == (ids.first(),)
  )
  let numbered-lines = if line-numbers == auto { mode == "review" } else { line-numbers }
  let line-leading = if leading == auto { if mode == "review" { 1em } else { 0.65em } } else { leading }

  set document(title: if pdf-title == auto { title } else { pdf-title },
    author: authors.map(author => author.name), keywords: keywords, date: date)
  set text(font: font, size: font-size, lang: lang)
  show math.equation: set text(font: math-font)
  set page(paper: paper, margin: margin, columns: 1, numbering: "1", number-align: center + bottom)
  set par(justify: true, leading: line-leading, first-line-indent: 1em, spacing: 0.8em)
  set par.line(numbering: if numbered-lines {
    n => text(size: 8pt, fill: luma(128), str(n))
  } else { none },
    numbering-scope: "document", number-align: right, number-clearance: 8pt)

  set heading(numbering: section-numbering)
  show heading: set par.line(numbering: none)
  // Return the original native element: its structure, labels and refs survive.
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
  show figure.caption: set text(size: 0.9em)
  show figure.caption: set par(first-line-indent: 0pt, justify: false)
  show figure.where(kind: table): set figure.caption(position: top)
  // Open tables. Authors place semantic header and horizontal-rule boundaries.
  set table(stroke: none, inset: (x: 0.7em, y: 0.4em))
  set table.hline(stroke: 0.6pt)
  show footnote.entry: set par.line(numbering: none)
  set bibliography(style: "annual-reviews-author-date", title: [References])

  show native-title: set text(size: 1.5 * font-size, weight: "bold")
  show native-title: set align(center)
  // The local scope suppresses numbering, not just its visible formatting.
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
  body
}

#let draft = revtex-preprint

// Terminal show rule, once, after the main text. The outer numbering policy
// controls equation resets; figures and tables continue independently.
#let appendices(body) = {
  context {
    assert(not appendix-mode.get(), message: "revtex-preprint: appendices may only be used once")
    appendix-mode.update(true)
    counter(heading).update(0)
  }
  set heading(numbering: "A.1", supplement: [Appendix])
  body
}
