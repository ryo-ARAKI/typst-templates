#import "@preview/cjk-spacer:0.2.0": cjk-spacer
#import "../core/config.typ": poster-config
#import "../core/journal-abbrev.typ": abbreviate-journal
#import "../core/locale.typ": apply-japanese-text
#import "../components/aligned-list.typ": aligned-items, aligned-enum
#import "../components/math.typ": apply-math-font, apply-inline-japanese-math-spacing
#import "../adapters/peace-of-posters.typ": *
#import "../core/tokens.typ": colors

#let poster-runtime-config = state("poster-runtime-config", poster-config())
#let poster-title-spacing = 5%
#let poster-portrait-spacing = 1.0cm
#let poster-portrait-ink = rgb("#172033")
#let poster-portrait-default-logo-width = 24%

#let poster-cite-error(message) = panic("poster-cite: " + message)

#let poster-bibliography-path(resolved) = {
  let path = resolved.at("metadata").at("bibliography", default: none)
  if path == none {
    poster-cite-error("metadata.bibliography is not set")
  }
  path
}

#let poster-capture-first(text, pattern) = {
  let matched = text.match(pattern)
  if matched == none { none } else { matched.captures.at(0) }
}

#let poster-strip-field-value(text) = {
  let trimmed = text.trim()
  let without-comma = if trimmed.ends-with(",") {
    trimmed.slice(0, trimmed.len() - 1).trim()
  } else {
    trimmed
  }
  if without-comma.starts-with("{") and without-comma.ends-with("}") {
    without-comma.slice(1, without-comma.len() - 1).trim()
  } else if without-comma.starts-with("\"") and without-comma.ends-with("\"") {
    without-comma.slice(1, without-comma.len() - 1).trim()
  } else {
    without-comma
  }
}

#let poster-entry-key(block) = {
  let key = poster-capture-first(block, regex("(?m)^\\s*@[A-Za-z]+\\s*\\{\\s*([^,]+),"))
  if key == none { none } else { key.trim() }
}

#let poster-entry-blocks(text) = {
  let matches = text.matches(regex("(?ms)^\\s*@[A-Za-z]+\\s*\\{.*?^\\s*\\}\\s*$"))
  matches.map(match => match.text)
}

#let poster-field(block, name) = {
  let value = poster-capture-first(block, regex("(?im)^\\s*" + name + "\\s*=\\s*(.+?)\\s*,?\\s*$"))
  if value == none { none } else { poster-strip-field-value(value) }
}

#let poster-entry-kind(block) = {
  let kind = poster-capture-first(block, regex("(?im)^\\s*@([A-Za-z]+)\\s*\\{"))
  if kind == none { none } else { kind.trim() }
}

#let poster-normalize-title(title) = {
  title.replace("{", "").replace("}", "").trim()
}

#let poster-display-journal(name) = {
  let trimmed = name.trim()
  let arxiv-preprint-id = poster-capture-first(
    trimmed,
    regex("(?i)^arxiv\\s+preprint\\s+arxiv:([^\\s]+)\\s*$"),
  )
  if arxiv-preprint-id != none {
    "arXiv:" + arxiv-preprint-id
  } else {
    let arxiv-id = poster-capture-first(trimmed, regex("(?i)^arxiv:([^\\s]+)\\s*$"))
    if arxiv-id != none {
      "arXiv:" + arxiv-id
    } else {
      abbreviate-journal(trimmed)
    }
  }
}

#let poster-italicized-citation-text(body, text-font) = {
  text(font: ("Noto Sans", text-font), style: "italic")[#body]
}

#let poster-author-surname(author) = {
  let normalized = author.trim()
  if normalized.contains(",") {
    normalized.split(",").at(0).trim()
  } else {
    let parts = normalized.split(" ").filter(part => part != "")
    parts.at(parts.len() - 1)
  }
}

#let poster-author-label(authors) = {
  let surnames = authors.map(poster-author-surname)
  if surnames.len() == 1 {
    surnames.at(0)
  } else if surnames.len() == 2 {
    surnames.join(" and ")
  } else {
    surnames.at(0) + " et al."
  }
}

#let poster-citation-entry(key, path) = {
  let bibliography = read(path)
  let blocks = poster-entry-blocks(bibliography)
  let target = blocks.find(block => poster-entry-key(block) == key)
  if target == none {
    poster-cite-error("entry not found for key `" + key + "` in `" + path + "`")
  }
  (
    kind: poster-entry-kind(target),
    author: poster-field(target, "author"),
    title: poster-field(target, "title"),
    journal: poster-field(target, "journal"),
    volume: poster-field(target, "volume"),
    year: poster-field(target, "year"),
  )
}

#let poster-has-citation-entry(key, path) = {
  let bibliography = read(path)
  let blocks = poster-entry-blocks(bibliography)
  blocks.find(block => poster-entry-key(block) == key) != none
}

#let poster-logo-strip(..logos, gap: 0.4em, widths: none) = {
  let items = logos.pos()
  let columns = if widths != none and type(widths) == array and widths.len() == items.len() {
    widths
  } else {
    items.map(_ => 1fr)
  }
  if items.len() == 0 {
    []
  } else if items.len() == 1 {
    box(width: 100%)[
      #set image(width: 100%)
      #align(center + horizon, items.at(0))
    ]
  } else {
    grid(
      columns: columns,
      gutter: gap,
      ..items.map(item => grid.cell(align: center + horizon)[
        #box(width: 100%)[
          #set image(width: 100%)
          #align(center + horizon, item)
        ]
      ]),
    )
  }
}

#let poster-theme(body, config: none) = {
  let resolved = poster-config(overrides: config)
  let metadata = resolved.at("metadata")
  show: cjk-spacer
  set page("a0", margin: 1cm)
  pop.set-poster-layout(pop.layout-a0)
  pop.set-theme(pop.psi-ch)
  pop.update-theme(
    heading-text-args: (fill: colors.at("navy")),
    body-box-args: (
      inset: (x: 0.4em, y: 0.5em),
      stroke: none,
    ),
    heading-box-args: (
      inset: (x: 0.2em, y: 0.4em),
      stroke: none,
    ),
  )
  set text(size: pop.layout-a0.at("body-size"), font: resolved.at("text-font"))
  set columns(gutter: resolved.at("box-spacing"))
  set block(spacing: resolved.at("box-spacing"))
  pop.update-poster-layout(
    spacing: resolved.at("box-spacing"),
    subtitle-size: 14pt,
  )
  apply-math-font(font: resolved.at("math-font"))
  apply-japanese-text(cjk-font: resolved.at("cjk-font"))
  apply-inline-japanese-math-spacing()
  poster-runtime-config.update(_ => resolved + (metadata: metadata,))
  body
}

#let poster-portrait-theme(body, config: none) = {
  let resolved = poster-config(overrides: config)
  let metadata = resolved.at("metadata")
  show: cjk-spacer
  set page("a0", margin: 1.2cm)
  set text(size: 34pt, font: resolved.at("text-font"), fill: poster-portrait-ink)
  set block(spacing: poster-portrait-spacing)
  apply-math-font(font: resolved.at("math-font"))
  apply-japanese-text(cjk-font: resolved.at("cjk-font"))
  apply-inline-japanese-math-spacing()
  poster-runtime-config.update(_ => resolved + (metadata: metadata,))
  body
}

#let setup-poster(config: none) = {
  let resolved = poster-config(overrides: config)
  let bibliography-path = resolved.at("metadata").at("bibliography", default: none)
  if bibliography-path != none {
    hide(bibliography(bibliography-path, title: none))
  }
}
#let resolve-poster-title-box-args(resolved, logo-relative-width: auto) = {
  let metadata = resolved.at("metadata")
  let resolved-logo-relative-width = if logo-relative-width == auto {
    metadata.at("logo-relative-width", default: none)
  } else {
    logo-relative-width
  }
  if resolved-logo-relative-width == none {
    (:)
  } else {
    (
      spacing: poster-title-spacing,
      text-relative-width: 100% - poster-title-spacing - resolved-logo-relative-width,
    )
  }
}

#let poster-title(config: none, logo: auto, logo-relative-width: auto) = {
  context {
    let resolved = if config == none {
      poster-runtime-config.get()
    } else {
      poster-config(overrides: config)
    }
    let logo-content = if logo == auto {
      resolved.at("metadata").at("logo")
    } else {
      logo
    }
    pop.title-box(
      resolved.at("metadata").at("title"),
      authors: resolved.at("metadata").at("poster-authors-inline"),
      logo: logo-content,
      ..resolve-poster-title-box-args(resolved, logo-relative-width: logo-relative-width),
    )
  }
}

#let poster-bottom-box(config: none) = {
  context {
    let resolved = if config == none {
      poster-runtime-config.get()
    } else {
      poster-config(overrides: config)
    }
    pop.bottom-box()[
      #h(1fr)#text(32pt)[#resolved.at("metadata").at("venue")]
    ]
  }
}

#let poster-portrait-figure-side-error(side) = {
  panic("poster-portrait-funnel: figure-side must be `left` or `right`")
}

#let poster-portrait-get-section(section, key, default: none) = {
  if type(section) == dictionary {
    section.at(key, default: default)
  } else {
    default
  }
}

#let poster-portrait-render-author(entry) = {
  let base-size = 46pt
  let email-size = 36pt
  let parts = ()
  let name = entry.at("name", default: [])
  let affiliation = entry.at("affiliation", default: [])
  let email = entry.at("email", default: [])
  if name != [] { parts.push(name) }
  if affiliation != [] { parts.push(affiliation) }
  let base = if parts.len() == 0 {
    []
  } else {
    text(size: base-size)[#parts.join($at$)]
  }
  if email == [] {
    base
  } else if base == [] {
    text(size: email-size)[#email]
  } else {
    [#base #text(size: email-size)[#email]]
  }
}

#let poster-portrait-render-authors(authors) = {
  let rendered = authors.map(poster-portrait-render-author).filter(part => part != [])
  if rendered.len() == 0 {
    []
  } else {
    rendered.join(" / ")
  }
}

#let poster-portrait-resolve-logo-width(metadata, logo-relative-width) = {
  let resolved-logo-relative-width = if logo-relative-width == auto {
    metadata.at("logo-relative-width", default: none)
  } else {
    logo-relative-width
  }
  if resolved-logo-relative-width == none {
    poster-portrait-default-logo-width
  } else {
    resolved-logo-relative-width
  }
}

#let poster-portrait-compact-title(resolved, logo: auto, logo-relative-width: auto) = {
  let metadata = resolved.at("metadata")
  let logo-content = if logo == auto {
    metadata.at("logo", default: [])
  } else {
    logo
  }
  let has-logo = logo-content != [] and logo-content != none
  let logo-width = poster-portrait-resolve-logo-width(metadata, logo-relative-width)
  let text-width = 100% - 1.0cm - logo-width
  grid(
    columns: if has-logo { (text-width, logo-width) } else { (1fr,) },
    gutter: 1cm,
    align: horizon,
    [
      #text(size: 78pt, fill: colors.at("navy"), weight: "bold")[#metadata.at("title")]
      #v(0.05cm)
      #text(fill: poster-portrait-ink)[#poster-portrait-render-authors(metadata.at("authors"))]
    ],
    ..if has-logo {
      (align(right + horizon)[#logo-content],)
    } else {
      ()
    },
  )
}

#let poster-portrait-band(body, fill: colors.at("structure"), size: 54pt) = {
  block(
    width: 100%,
    height: 100%,
    fill: fill,
    inset: (x: 0.8cm, y: 0.55cm),
    radius: 0pt,
  )[
    #text(size: size, fill: white, weight: "bold")[#body]
  ]
}

#let poster-portrait-panel(body, title: none, fill: colors.at("structure").lighten(78%)) = {
  block(
    width: 100%,
    height: 100%,
    fill: fill,
    stroke: 2pt + colors.at("structure"),
    inset: (x: 0.55cm, y: 0.45cm),
    radius: 4pt,
  )[
    #if title != none {
      text(size: 34pt, fill: colors.at("navy"), weight: "bold")[#title]
      v(0.22cm)
    }
    #text(size: 30pt, fill: poster-portrait-ink)[#body]
  ]
}

#let poster-portrait-figure-box(body, title: none) = {
  block(
    width: 100%,
    height: 100%,
    fill: white,
    stroke: 3pt + colors.at("structure"),
    inset: (x: 0.45cm, y: 0.45cm),
    radius: 4pt,
  )[
    #if title != none {
      text(size: 34pt, fill: colors.at("structure"), weight: "bold")[#title]
      v(0.25cm)
    }
    #box(width: 100%, height: 100%)[
      #align(center + horizon)[#body]
    ]
  ]
}

#let poster-portrait-figure-row(section, default-side: left) = {
  let side = poster-portrait-get-section(section, "figure-side", default: default-side)
  if side != left and side != right {
    poster-portrait-figure-side-error(side)
  }
  let title = poster-portrait-get-section(section, "title", default: none)
  let figure = poster-portrait-get-section(section, "figure", default: [])
  let caption = poster-portrait-get-section(section, "caption", default: [])
  let figure-cell = poster-portrait-figure-box(figure, title: title)
  let caption-cell = poster-portrait-panel(caption, title: [Guide])
  let cells = if side == left {
    (figure-cell, caption-cell)
  } else {
    (caption-cell, figure-cell)
  }
  box(width: 100%, height: 100%)[
    #grid(
      columns: if side == left { (1.18fr, 0.82fr) } else { (0.82fr, 1.18fr) },
      gutter: poster-portrait-spacing,
      ..cells,
    )
  ]
}

#let poster-portrait-footer(resolved, footer: auto) = {
  let metadata = resolved.at("metadata")
  let footer-content = if footer == auto {
    metadata.at("venue")
  } else {
    footer
  }
  if footer-content == none or footer-content == [] {
    []
  } else {
    align(bottom + right)[
      #text(size: 28pt, fill: colors.at("navy"))[#footer-content]
    ]
  }
}

#let poster-portrait-funnel(
  headline: [],
  upper: (:),
  lower: (:),
  conclusion: [],
  footer: auto,
  logo: auto,
  logo-relative-width: auto,
  config: none,
) = {
  context {
    let resolved = if config == none {
      poster-runtime-config.get()
    } else {
      poster-config(overrides: config)
    }
    block(width: 100%, height: 100%)[
      #grid(
        columns: (1fr,),
        rows: (10%, 12%, 29%, 29%, 14%, 3%),
        gutter: 0.65cm,
        poster-portrait-compact-title(
          resolved,
          logo: logo,
          logo-relative-width: logo-relative-width,
        ),
        poster-portrait-band(headline, fill: colors.at("structure"), size: 52pt),
        poster-portrait-figure-row(upper, default-side: left),
        poster-portrait-figure-row(lower, default-side: right),
        poster-portrait-band(conclusion, fill: colors.at("navy"), size: 44pt),
        poster-portrait-footer(resolved, footer: footer),
      )
    ]
  }
}

#let poster-cite(key, config: none) = {
  context {
    let resolved = if config == none {
      poster-runtime-config.get()
    } else {
      poster-config(overrides: config)
    }
    let path = poster-bibliography-path(resolved)
    let entry = poster-citation-entry(key, path)
    let kind = if entry.kind == none { none } else { entry.kind.trim() }
    let author = if entry.author == none { none } else { entry.author.trim() }
    let title = if entry.title == none { none } else { poster-normalize-title(entry.title) }
    let journal-name = if entry.journal == none { none } else { entry.journal.trim() }
    let volume = if entry.volume == none { none } else { entry.volume.trim() }
    let year = if entry.year == none { none } else { entry.year.trim() }
    let authors = if author == none or author == "" {
      ()
    } else {
      author.split(" and ").map(part => part.trim()).filter(part => part != "")
    }
    if authors.len() == 0 {
      poster-cite-error("entry `" + key + "` is missing one of: author, year")
    }
    let is-article = kind != none and kind.match(regex("(?i)^article$")) != none
    let is-book = kind != none and kind.match(regex("(?i)^book$")) != none
    if is-article {
      if author == none or author == "" or journal-name == none or journal-name == "" or year == none or year == "" {
        poster-cite-error("entry `" + key + "` is missing one of: author, journal, year")
      }
      let journal = poster-display-journal(journal-name)
      if volume == none or volume == "" {
        [#poster-author-label(authors), #poster-italicized-citation-text(journal, resolved.at("text-font")) (#year)]
      } else {
        [#poster-author-label(authors), #poster-italicized-citation-text(journal, resolved.at("text-font")), #strong[#volume] (#year)]
      }
    } else {
      if author == none or author == "" or title == none or title == "" or year == none or year == "" {
        poster-cite-error("entry `" + key + "` is missing one of: author, title, year")
      }
      if is-book {
        [#poster-author-label(authors), #poster-italicized-citation-text(title, resolved.at("text-font")) (#year)]
      } else {
        [#poster-author-label(authors), #title (#year)]
      }
    }
  }
}

#let poster-citation-ref(it, config: none) = {
  let resolved = poster-config(overrides: config)
  let bibliography-path = resolved.at("metadata").at("bibliography", default: none)
  if bibliography-path == none {
    it
  } else {
    let key = str(it.target)
    if poster-has-citation-entry(key, bibliography-path) {
      poster-cite(key, config: resolved)
    } else {
      it
    }
  }
}
