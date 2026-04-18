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
