#import "@preview/cjk-spacer:0.2.0": cjk-spacer
#import "../core/config.typ": poster-config
#import "../core/metadata.typ": render-poster-authors-inline
#import "../core/journal-abbrev.typ": abbreviate-journal
#import "../core/locale.typ": apply-japanese-text
#import "../components/aligned-list.typ": aligned-enum, aligned-items
#import "../components/math.typ": apply-inline-japanese-math-spacing, apply-math-font
#import "../adapters/peace-of-posters.typ": *
#import "../core/tokens.typ": colors

#let poster-runtime-config = state("poster-runtime-config", poster-config())
#let poster-column-title-spacing = 5%
#let poster-portrait-spacing = 1.0cm
#let poster-portrait-ink = rgb("#172033")
#let poster-portrait-default-logo-width = 24%
#let poster-portrait-default-theme = "default"
#let poster-portrait-base-palette = (
  structure: colors.at("structure"),
  accent: colors.at("accent"),
  example: colors.at("example"),
  heading: colors.at("navy"),
  ink: poster-portrait-ink,
  panel-fill: colors.at("structure").lighten(78%),
  headline-fill: colors.at("structure"),
  conclusion-fill: colors.at("navy"),
)
#let poster-portrait-named-palettes = (
  "default": poster-portrait-base-palette,
  "solarized-magenta": (
    structure: rgb("#d33682"),
    accent: rgb("#b58900"),
    example: rgb("#6c71c4"),
    heading: rgb("#5a1739"),
    ink: rgb("#172033"),
    panel-fill: rgb("#f4dce8"),
    headline-fill: rgb("#d33682"),
    conclusion-fill: rgb("#5a1739"),
  ),
  wine: (
    structure: rgb("#8f2d56"),
    accent: rgb("#d4a017"),
    example: rgb("#6f4e7c"),
    heading: rgb("#4a1d2f"),
    ink: rgb("#24141c"),
    panel-fill: rgb("#f7d9e6"),
    headline-fill: rgb("#8f2d56"),
    conclusion-fill: rgb("#4a1d2f"),
  ),
  "brewer-dark2-magenta": (
    structure: rgb("#6f64b5"),
    accent: rgb("#e7298a"),
    example: rgb("#d95f02"),
    heading: rgb("#30295f"),
    ink: rgb("#202124"),
    panel-fill: rgb("#e5e2f2"),
    headline-fill: rgb("#6f64b5"),
    conclusion-fill: rgb("#30295f"),
  ),
)

#let poster-cite-error(message) = panic("poster-cite: " + message)

#let poster-portrait-takeaway-theme-error(message) = panic("poster-portrait-takeaway: " + message)

#let poster-portrait-title-style-defaults = (
  height: 5.8%,
  title-size: 92pt,
  author-size: 50pt,
  author-email-size: 40pt,
  author-offset: -2.4cm,
  logo-gutter: 1cm,
)
#let poster-portrait-footer-style-defaults = (
  height: 1.4%,
  text-size: 32pt,
  gutter: 1cm,
)

#let poster-portrait-takeaway-palette(theme: auto, overrides: (:)) = {
  if type(overrides) != dictionary {
    poster-portrait-takeaway-theme-error("overrides must be a dictionary")
  }
  let named-palette = if theme == auto {
    poster-portrait-named-palettes.at(poster-portrait-default-theme)
  } else if type(theme) == str {
    if poster-portrait-named-palettes.keys().contains(theme) {
      poster-portrait-named-palettes.at(theme)
    } else {
      poster-portrait-takeaway-theme-error("unknown theme `" + theme + "`")
    }
  } else {
    poster-portrait-takeaway-theme-error("theme must be auto or a string")
  }
  poster-portrait-base-palette + named-palette + overrides
}

#let poster-portrait-resolve-palette(theme, palette) = {
  if palette != auto and theme != auto {
    poster-portrait-takeaway-theme-error("specify either theme or palette, not both")
  }
  if palette == auto {
    poster-portrait-takeaway-palette(theme: theme)
  } else if type(palette) == dictionary {
    poster-portrait-takeaway-palette(overrides: palette)
  } else {
    poster-portrait-takeaway-theme-error("palette must be auto or a dictionary")
  }
}

#let poster-portrait-resolve-style(style, defaults, name) = {
  if type(style) != dictionary {
    poster-portrait-takeaway-theme-error(name + " must be a dictionary")
  }
  let unknown = style.keys().filter(key => not defaults.keys().contains(key))
  if unknown.len() > 0 {
    poster-portrait-takeaway-theme-error("unknown " + name + " key `" + unknown.at(0) + "`")
  }
  defaults + style
}

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

#let poster-column-theme(body, config: none) = {
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
  poster-runtime-config.update(_ => resolved + (metadata: metadata))
  body
}

#let poster-portrait-takeaway-theme(body, config: none) = {
  let resolved = poster-config(overrides: config)
  let metadata = resolved.at("metadata")
  show: cjk-spacer
  set page("a0", margin: 1.2cm)
  set text(size: 40pt, font: resolved.at("text-font"), fill: poster-portrait-ink)
  set block(spacing: poster-portrait-spacing)
  apply-math-font(font: resolved.at("math-font"))
  apply-japanese-text(cjk-font: resolved.at("cjk-font"))
  apply-inline-japanese-math-spacing()
  poster-runtime-config.update(_ => resolved + (metadata: metadata))
  body
}

#let setup-poster(config: none) = {
  let resolved = poster-config(overrides: config)
  let bibliography-path = resolved.at("metadata").at("bibliography", default: none)
  if bibliography-path != none {
    hide(bibliography(bibliography-path, title: none))
  }
}
#let resolve-poster-column-title-box-args(resolved, logo-relative-width: auto) = {
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
      spacing: poster-column-title-spacing,
      text-relative-width: 100% - poster-column-title-spacing - resolved-logo-relative-width,
    )
  }
}

#let poster-column-title(config: none, logo: auto, logo-relative-width: auto) = {
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
      ..resolve-poster-column-title-box-args(resolved, logo-relative-width: logo-relative-width),
    )
  }
}

#let poster-column-bottom-box(config: none) = {
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
  panic("poster-portrait-takeaway: figure-side must be `left` or `right`")
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

#let poster-portrait-compact-title(resolved, palette, logo: auto, logo-relative-width: auto, style: poster-portrait-title-style-defaults) = {
  let metadata = resolved.at("metadata")
  let logo-content = if logo == auto {
    metadata.at("logo", default: [])
  } else {
    logo
  }
  let has-logo = logo-content != [] and logo-content != none
  let logo-width = poster-portrait-resolve-logo-width(metadata, logo-relative-width)
  let logo-gutter = style.at("logo-gutter")
  let text-width = 100% - logo-gutter - logo-width
  grid(
    columns: if has-logo { (text-width, logo-width) } else { (1fr,) },
    gutter: logo-gutter,
    align: horizon,
    [
      #text(size: style.at("title-size"), fill: palette.at("heading"), weight: "bold")[#metadata.at("title")]
      #v(style.at("author-offset"))
      #text(fill: palette.at("ink"), weight: "regular")[
        #render-poster-authors-inline(
          metadata.at("authors"),
          author-size: style.at("author-size"),
          email-size: style.at("author-email-size"),
        )
      ]
    ],
    ..if has-logo {
      (align(right + horizon)[#logo-content],)
    } else {
      ()
    },
  )
}

#let poster-portrait-required-content(value, name) = {
  if value == auto or value == none or value == [] {
    poster-portrait-takeaway-theme-error(name + " is required")
  }
  value
}

#let poster-portrait-required-section(section, name) = {
  if type(section) != dictionary {
    poster-portrait-takeaway-theme-error(name + " must be a dictionary")
  }
  if section.keys().contains("widths") {
    poster-portrait-takeaway-theme-error(name + ".widths is no longer supported; use figure-width and caption-width")
  }
  section
}

#let poster-portrait-required-section-content(section, key, section-name) = {
  poster-portrait-required-content(section.at(key, default: auto), section-name + "." + key)
}

#let poster-portrait-band(
  takeaway,
  detail,
  fill: colors.at("structure"),
  takeaway-size: 58pt,
  detail-size: 40pt,
) = {
  block(
    width: 100%,
    height: 100%,
    fill: fill,
    inset: (x: 0.8cm, y: 0.55cm),
    radius: 0pt,
  )[
    #box(width: 100%, height: 100%)[
      #align(left + horizon)[
        #grid(
          columns: (1fr,),
          rows: (auto, auto),
          row-gutter: 1cm,
          text(size: takeaway-size, fill: white, weight: "bold")[#takeaway],
          text(size: detail-size, fill: white.transparentize(20%))[#detail],
        )
      ]
    ]
  ]
}

#let poster-portrait-box-heading(title, palette, size: 44pt, fill-key: "structure") = {
  text(size: size, fill: palette.at(fill-key), weight: "bold")[#title]
}

#let poster-portrait-box-content(title, heading, body, row-gutter: 0cm) = {
  if title != none {
    grid(
      columns: (1fr,),
      rows: (auto, 1fr),
      row-gutter: row-gutter,
      heading(title),
      body,
    )
  } else {
    body
  }
}

#let poster-portrait-panel(body, palette, title: none, fill: auto) = {
  let resolved-fill = if fill == auto { palette.at("panel-fill") } else { fill }
  block(
    width: 100%,
    height: 100%,
    fill: resolved-fill,
    stroke: 2pt + palette.at("structure"),
    inset: (x: 0.55cm, y: 0.45cm),
    radius: 4pt,
  )[
    #poster-portrait-box-content(
      title,
      title => poster-portrait-box-heading(title, palette, size: 42pt, fill-key: "heading"),
      box(width: 100%, height: 100%)[
        #text(size: 40pt, fill: palette.at("ink"))[#body]
      ],
      row-gutter: 1cm,
    )
  ]
}

#let poster-portrait-figure-box(body, palette, title: none) = {
  block(
    width: 100%,
    height: 100%,
    fill: white,
    stroke: 3pt + palette.at("structure"),
    inset: (x: 0.45cm, y: 0.45cm),
    radius: 4pt,
  )[
    #poster-portrait-box-content(
      title,
      title => poster-portrait-box-heading(title, palette, size: 44pt, fill-key: "structure"),
      box(width: 100%, height: 100%)[
        #align(center + horizon)[#body]
      ],
    )
  ]
}

#let poster-portrait-figure-row(section, palette, default-side: left, name: "section") = {
  let resolved-section = poster-portrait-required-section(section, name)
  let side = resolved-section.at("figure-side", default: default-side)
  if side != left and side != right {
    poster-portrait-figure-side-error(side)
  }
  let title = resolved-section.at("title", default: none)
  let caption-title = resolved-section.at("caption-title", default: [Guide])
  let figure = poster-portrait-required-section-content(resolved-section, "figure", name)
  let caption = poster-portrait-required-section-content(resolved-section, "caption", name)
  let figure-width = resolved-section.at("figure-width", default: 1.18fr)
  let caption-width = resolved-section.at("caption-width", default: 0.82fr)
  let figure-cell = poster-portrait-figure-box(figure, palette, title: title)
  let caption-cell = poster-portrait-panel(caption, palette, title: caption-title)
  let columns = if side == left {
    (figure-width, caption-width)
  } else {
    (caption-width, figure-width)
  }
  let cells = if side == left {
    (figure-cell, caption-cell)
  } else {
    (caption-cell, figure-cell)
  }
  box(width: 100%, height: 100%)[
    #grid(
      columns: columns,
      gutter: poster-portrait-spacing,
      ..cells,
    )
  ]
}

#let poster-portrait-footer(resolved, palette, footer: auto, acknowledgements: auto, style: poster-portrait-footer-style-defaults) = {
  let metadata = resolved.at("metadata")
  let footer-content = if footer == auto {
    metadata.at("venue")
  } else {
    footer
  }
  let acknowledgements-content = if acknowledgements == auto {
    metadata.at("acknowledgements", default: [])
  } else {
    acknowledgements
  }
  let has-footer = footer-content != none and footer-content != []
  let has-acknowledgements = acknowledgements-content != none and acknowledgements-content != []
  if not has-footer and not has-acknowledgements {
    []
  } else {
    align(bottom)[
      #grid(
        columns: (1fr, 1fr),
        gutter: style.at("gutter"),
        align(left + bottom)[
          #if has-acknowledgements {
            text(size: style.at("text-size"), fill: palette.at("heading"))[#acknowledgements-content]
          }
        ],
        align(right + bottom)[
          #if has-footer {
            text(size: style.at("text-size"), fill: palette.at("heading"))[#footer-content]
          }
        ],
      )
    ]
  }
}

#let poster-portrait-resolve-figure-heights(figure-heights) = {
  if type(figure-heights) != array or figure-heights.len() != 2 {
    poster-portrait-takeaway-theme-error("figure-heights must be a two-item array like (1fr, 1fr)")
  }
  figure-heights
}

#let poster-portrait-takeaway(
  headline-takeaway: auto,
  headline-detail: auto,
  headline-height: 12%,
  upper: (:),
  lower: (:),
  figure-heights: (1fr, 1fr),
  conclusion-takeaway: auto,
  conclusion-detail: auto,
  conclusion-height: 15.6%,
  footer: auto,
  acknowledgements: auto,
  logo: auto,
  logo-relative-width: auto,
  config: none,
  theme: auto,
  palette: auto,
  title-style: (:),
  footer-style: (:),
) = {
  context {
    let resolved = if config == none {
      poster-runtime-config.get()
    } else {
      poster-config(overrides: config)
    }
    let resolved-palette = poster-portrait-resolve-palette(theme, palette)
    let resolved-title-style = poster-portrait-resolve-style(title-style, poster-portrait-title-style-defaults, "title-style")
    let resolved-footer-style = poster-portrait-resolve-style(footer-style, poster-portrait-footer-style-defaults, "footer-style")
    let resolved-headline-takeaway = poster-portrait-required-content(headline-takeaway, "headline-takeaway")
    let resolved-headline-detail = poster-portrait-required-content(headline-detail, "headline-detail")
    let resolved-conclusion-takeaway = poster-portrait-required-content(conclusion-takeaway, "conclusion-takeaway")
    let resolved-conclusion-detail = poster-portrait-required-content(conclusion-detail, "conclusion-detail")
    let resolved-figure-heights = poster-portrait-resolve-figure-heights(figure-heights)
    block(width: 100%, height: 100%)[
      #grid(
        columns: (1fr,),
        rows: (
          resolved-title-style.at("height"),
          headline-height,
          resolved-figure-heights.at(0),
          resolved-figure-heights.at(1),
          conclusion-height,
          resolved-footer-style.at("height"),
        ),
        gutter: 0.65cm,
        poster-portrait-compact-title(
          resolved,
          resolved-palette,
          logo: logo,
          logo-relative-width: logo-relative-width,
          style: resolved-title-style,
        ),
        poster-portrait-band(
          resolved-headline-takeaway,
          resolved-headline-detail,
          fill: resolved-palette.at("headline-fill"),
          takeaway-size: 56pt,
        ),
        poster-portrait-figure-row(upper, resolved-palette, default-side: left, name: "upper"),
        poster-portrait-figure-row(lower, resolved-palette, default-side: right, name: "lower"),
        poster-portrait-band(
          resolved-conclusion-takeaway,
          resolved-conclusion-detail,
          fill: resolved-palette.at("conclusion-fill"),
          takeaway-size: 50pt,
        ),
        poster-portrait-footer(resolved, resolved-palette, footer: footer, acknowledgements: acknowledgements, style: resolved-footer-style),
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
