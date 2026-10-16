// Standalone APS RevTeX 4.2 preprint style for Typst >= 0.15.0.
// Copy this file next to a manuscript; no package imports or repository scripts.
// Requires New Computer Modern and New Computer Modern Math (bundled with Typst).
// Based on t2lab-it/hashimoto2026_information-flow PR #1, style.typ,
// revision ff812f27fe9a665d98e9afa3abbbe9bb38cb850a.
//
// #import "revtex-preprint.typ": revtex-preprint, appendices
// #show: revtex-preprint.with(
//   title: [A manuscript with $k$], pdf-title: "A manuscript with k",
//   authors: ((name: "Alice Example",), (name: "Bob Example",)),
//   affiliations: [Department of Physics, Example University],
// )
// = Introduction
// Body text. See @eq-main.
// $ E = m c^2 $ <eq-main>
// #show: appendices
// = Additional derivation
// $ x = 1 $ <eq-appendix>
//
// authors: array of dictionaries with a string name and optional integer
// affiliation ID (default 1). Shared affiliations have no superscript; when IDs
// differ, supply the matching superscripts yourself in affiliations content.
// date: datetime.today() by default; none omits the date and PDF creation date.
// line-numbers: true by default; counts prose and references across all pages.
// draft is an alias for compatibility with the source PR.
// appendices is a terminal show rule: put it after the main text, only once.
// Bibliography uses Typst's built-in american-physics-society CSL style.
// Scope: one column, common affiliation, three numbered heading levels.
// No abstract/author-footnote API or exact LaTeX line/page/float matching.

// TeX pt = 1/72.27 inch; Typst/PDF pt = 1/72 inch.
#let tex-pt = 72pt / 72.27
#let appendix-mode = state("revtex-preprint-appendix", false)

#let section-number(..values) = {
  let n = values.pos()
  numbering(if n.len() == 1 { "I" } else if n.len() == 2 { "A" } else { "1" }, n.last())
}

// Uppercase prose in section titles without changing mathematical variables.
#let section-title(body) = {
  show text: it => upper(it)
  show math.equation: it => it
  body
}

#let revtex-preprint(
  title: [],
  pdf-title: none,
  authors: (),
  affiliations: [],
  date: datetime.today(),
  line-numbers: true,
  body,
) = {
  assert(type(authors) == array,
    message: "revtex-preprint: authors must be an array, e.g. ((name: \"Alice\",),)")
  for author in authors {
    assert(type(author) == dictionary and type(author.at("name", default: none)) == str,
      message: "revtex-preprint: each author needs a string name")
    assert(type(author.at("affiliation", default: 1)) == int,
      message: "revtex-preprint: author.affiliation must be an integer ID")
  }
  assert(date == none or type(date) == datetime,
    message: "revtex-preprint: date must be a datetime or none")
  assert(type(line-numbers) == bool,
    message: "revtex-preprint: line-numbers must be true or false")

  set document(
    title: if pdf-title == none and type(title) == str { title } else { pdf-title },
    author: authors.map(author => author.name),
    date: date,
  )
  set text(font: "New Computer Modern", size: 12 * tex-pt, lang: "en",
    top-edge: 0.8em, bottom-edge: -0.2em)
  show math.equation: set text(font: "New Computer Modern Math")

  // RevTeX: textwidth=468pt, textheight=665.5pt, origin=(1in,1in).
  set page(
    paper: "us-letter",
    margin: (left: 72pt, right: 612pt - 72pt - 468 * tex-pt,
      top: 72pt, bottom: 792pt - 72pt - 665.5 * tex-pt),
    columns: 1, numbering: "1", number-align: center + bottom,
    // Footer baseline is 30 TeX pt below the text area.
    footer-descent: (30 - 0.8 * 12) * tex-pt,
  )
  // Text edges total 12 TeX pt; 9 TeX pt leading gives a 21 TeX pt baseline.
  // Tall inline equations can expand a line naturally.
  set par(justify: true, leading: 9 * tex-pt,
    first-line-indent: (amount: 15 * tex-pt, all: true), spacing: 9 * tex-pt)
  set par.line(
    numbering: if line-numbers { n => text(size: 6 * tex-pt, fill: luma(80), str(n)) } else { none },
    numbering-scope: "document", number-align: right, number-clearance: 8 * tex-pt,
  )

  set heading(numbering: section-number, supplement: [Sec.])
  show heading: set par.line(numbering: none)
  show heading: it => context {
    let app = appendix-mode.get()
    let numbers = counter(heading).get()
    let prefix = if it.numbering == none { [] }
      else if app and it.level == 1 { [APPENDIX #numbering("A", numbers.first())] }
      else { [#numbering(it.numbering, ..numbers).] }
    let title = if it.level == 1 and it.numbering != none { section-title(it.body) } else { it.body }
    let separator = if it.body == [] or it.numbering == none { [] }
      else if app and it.level == 1 { [: ] } else { h(0.5em) }
    block(above: 0.8cm, below: 0.5cm, sticky: true, width: 100%)[
      #set text(size: 11 * tex-pt, weight: if it.level < 3 { "bold" } else { "regular" },
        style: if it.level == 3 { "italic" } else { "normal" })
      #set par(first-line-indent: 0pt, justify: false)
      #prefix#separator#title
    ]
  }

  set math.equation(numbering: "(1)", supplement: [Eq.])
  show math.equation.where(block: true): set par.line(numbering: none)
  set figure(numbering: "1", supplement: [Fig.])
  show figure.where(kind: table): set figure(numbering: "I", supplement: [Table])
  show figure: set par.line(numbering: none)
  show figure.caption: set par(first-line-indent: 0pt, justify: false)
  show figure.caption: it => {
    let name = if it.kind == table { [TABLE] } else { [FIG.] }
    [#name #context it.counter.display(it.numbering). #it.body]
  }
  show figure.where(kind: table): set figure.caption(position: top)

  // Resolve numbers and appendix mode at the target, including forward refs.
  show ref: it => context {
    if it.form != "normal" { return it }
    let target = it.element
    if target != none and target.func() == heading and target.numbering != none {
      let n = counter(heading).at(target.location())
      let app = appendix-mode.at(target.location())
      let value = if app {
        [Appendix #numbering("A", n.first())#if n.len() > 1 { [ #numbering("1", ..n.slice(1))] }]
      } else {
        [Sec. #numbering("I", n.first())#if n.len() > 1 { [ #numbering("A", n.at(1))] }#if n.len() > 2 { [ #numbering("1", ..n.slice(2))] }]
      }
      link(target.location(), value)
    } else if target != none and target.func() == math.equation and target.numbering != none {
      let n = counter(math.equation).at(target.location()).first()
      let prefix = if appendix-mode.at(target.location()) {
        numbering("A", counter(heading).at(target.location()).first())
      } else { [] }
      link(target.location(), [Eq. (#prefix#n)])
    } else { it }
  }

  set bibliography(style: "american-physics-society", title: [References])

  let shared = authors.map(author => author.at("affiliation", default: 1)).dedup().len() <= 1
  align(center)[
    #set par(first-line-indent: 0pt, justify: false, leading: 12.6 * tex-pt)
    #set par.line(numbering: none)
    #v(6 * tex-pt)
    #if title != [] and title != "" {
      text(size: 14.4 * tex-pt, weight: "bold", title)
      v(12 * tex-pt)
    }
    #set par(leading: 10 * tex-pt)
    #if authors.len() > 0 {
      authors.map(author => [#author.name#if not shared { super(str(author.at("affiliation", default: 1))) }]).join(", ", last: " and ")
      v(3 * tex-pt)
    }
    #if affiliations != [] and affiliations != "" {
      block(width: 80%)[#text(style: "italic", affiliations)]
      v(3 * tex-pt)
    }
    #if date != none {
      text(size: 11 * tex-pt)[(Dated: #date.display("[month repr:long] [day], [year]"))]
    }
  ]
  v(12 * tex-pt)
  body
}

#let draft = revtex-preprint

// Start terminal appendices. Figures/tables continue; equations reset in each.
#let appendices(body) = {
  appendix-mode.update(true)
  counter(heading).update(0)
  set heading(numbering: (..n) => numbering(if n.pos().len() == 1 { "A" } else { "1" }, n.pos().last()))
  show heading.where(level: 1): it => {
    if it.numbering != none { counter(math.equation).update(0) }
    it
  }
  set math.equation(numbering: n => context [(#numbering("A", counter(heading).get().first())#n)])
  body
}
