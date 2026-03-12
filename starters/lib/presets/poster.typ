#import "../core/config.typ": poster-config
#import "../core/locale.typ": apply-japanese-text
#import "../components/math.typ": apply-math-font, apply-inline-japanese-math-spacing
#import "../adapters/peace-of-posters.typ": *
#import "../core/tokens.typ": colors

#let poster-theme(body, config: none) = {
  let resolved = poster-config(overrides: config)
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
  body
}

#let setup-poster(config: none) = [#show: poster-theme.with(config: config)]
#let poster-title(config: none, logo: auto) = {
  let resolved = poster-config(overrides: config)
  let logo-content = if logo == auto {
    []
  } else {
    logo
  }
  pop.title-box(
    resolved.at("title"),
    authors: resolved.at("authors"),
    logo: logo-content,
  )
}

#let poster-bottom-box(config: none) = {
  let resolved = poster-config(overrides: config)
  pop.bottom-box()[
    #h(1fr)#text(32pt)[#resolved.at("venue")]
  ]
}
