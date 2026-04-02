#import "../core/config.typ": poster-config
#import "../core/locale.typ": apply-japanese-text
#import "../components/math.typ": apply-math-font, apply-inline-japanese-math-spacing
#import "../adapters/peace-of-posters.typ": *
#import "../core/tokens.typ": colors

#let poster-runtime-config = state("poster-runtime-config", poster-config())

#let poster-logo-strip(..logos, gap: 1.2em, widths: none) = {
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
      ..items.map(item => [
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

#let setup-poster(config: none) = [#show: poster-theme.with(config: config)]
#let poster-title(config: none, logo: auto) = {
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
