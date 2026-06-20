#import "../lib/presets/poster.typ": *

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*Portrait A0 Two-Figure Funnel*],
  subtitle: [],
  authors: (
    (
      name: [荒木亮],
      affiliation: [Typst Templates],
      email: [],
    ),
  ),
  date: [],
  summary: [],
  abstract: [],
  venue: [Template Showcase$at$Local Workspace, 2026-06-20],
  acknowledgements: [Acknowledgements: JSPS KAKENHI JP00H00000],
  logo-relative-width: 24%,
  logo: poster-logo-strip(
    widths: (0.8fr, 1.4fr, 1.2fr),
    [
      #rect(
        width: 100%,
        height: 3.0cm,
        inset: 0.35cm,
        fill: colors.at("structure").lighten(78%),
        stroke: none,
      )[
        #align(center + horizon)[*TUS*]
      ]
    ],
    [
      #rect(
        width: 100%,
        height: 2.4cm,
        inset: 0.35cm,
        fill: colors.at("accent").lighten(72%),
        stroke: none,
      )[
        #align(center + horizon)[*Template Lab*]
      ]
    ],
    [
      #rect(
        width: 100%,
        height: 3.0cm,
        inset: 0.35cm,
        fill: colors.at("example").lighten(76%),
        stroke: none,
      )[
        #align(center + horizon)[*Research Unit*]
      ]
    ],
  ),
  bibliography: "/examples/biblio.bib",
)

#let fixed-canvas(body) = align(center)[#cetz.canvas({
  import cetz.draw: *
  rect((-10, -6), (10, 6), fill: white.transparentize(100%), stroke: none)
  body
})]

#let trend-figure(label, color) = fixed-canvas({
  import cetz.draw: *
  grid((-8, -4), (8, 4), stroke: gray.lighten(30%))
  line((-7, -2.4), (-3, -0.5), (0, 1.2), (4, 2.3), (7, 3.0), stroke: (paint: color, thickness: 0.35), mark: (end: "stealth"))
  circle((-7, -2.4), radius: 0.35, fill: colors.at("accent"), stroke: none)
  content((0, -4.7), text(fill: color)[#label])
})

#let method-figure = fixed-canvas({
  import cetz.draw: *
  rect((-8, -2.4), (-3.6, 2.4), radius: 4pt, fill: colors.at("structure").lighten(78%), stroke: colors.at("structure"))
  rect((-2.2, -2.4), (2.2, 2.4), radius: 4pt, fill: colors.at("accent").lighten(72%), stroke: colors.at("accent"))
  rect((3.6, -2.4), (8, 2.4), radius: 4pt, fill: colors.at("example").lighten(76%), stroke: colors.at("example"))
  line((-3.6, 0), (-2.2, 0), stroke: (paint: colors.at("structure"), thickness: 0.3), mark: (end: "stealth"))
  line((2.2, 0), (3.6, 0), stroke: (paint: colors.at("structure"), thickness: 0.3), mark: (end: "stealth"))
  content((-5.8, 0), [Input])
  content((0, 0), [Model])
  content((5.8, 0), [Output])
  content((0, -4.7), text(fill: colors.at("structure"))[Method schematic])
})

#let equation-figure = fixed-canvas({
  import cetz.draw: *
  rect((-7.5, -2.2), (7.5, 2.2), radius: 4pt, fill: colors.at("structure").lighten(75%), stroke: colors.at("structure"))
  content((0, 0), text(size: 28pt, fill: colors.at("structure"))[$partial_t q + u dot grad q = S(q)$])
  content((0, -4.7), text(fill: colors.at("structure"))[Support figure or equation])
})

#show: poster-portrait-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)

#poster-portrait-funnel(
  headline: [Main + Support: one result carries the story, and the second figure explains why it is credible.],
  upper: (
    title: [Main figure],
    figure: trend-figure([Main figure], colors.at("structure")),
    caption: [*Read first*: The main figure gives the central evidence at a glance.],
    figure-side: left,
  ),
  lower: (
    title: [Support figure or equation],
    figure: equation-figure,
    caption: [*Support*: The second slot can hold a robustness check, comparison, or governing equation.],
    figure-side: right,
  ),
  conclusion: [Main + Support: the support figure strengthens the main claim.],
)

#pagebreak()

#poster-portrait-funnel(
  headline: [Method + Main: show the analysis path before asking viewers to interpret the result.],
  upper: (
    title: [Method schematic],
    figure: method-figure,
    caption: [*Setup*: Show the model, variables, or workflow needed to read the result.],
    figure-side: right,
  ),
  lower: (
    title: [Main figure],
    figure: trend-figure([Main figure], colors.at("example")),
    caption: [*Meaning*: Interpret the result using the vocabulary established above.],
    figure-side: left,
  ),
  conclusion: [Method + Main: the method reveals the mechanism behind the result.],
)

#pagebreak()

#poster-portrait-funnel(
  headline: [Main 1 + Main 2: two findings work together to support one conclusion.],
  upper: (
    title: [Main figure 1],
    figure: trend-figure([Main figure 1], colors.at("accent")),
    caption: [*Takeaway 1*: The first result establishes the central contrast.],
    figure-side: left,
  ),
  lower: (
    title: [Main figure 2],
    figure: trend-figure([Main figure 2], colors.at("structure")),
    caption: [*Takeaway 2*: The second result extends or completes the first.],
    figure-side: right,
  ),
  conclusion: [Main 1 + Main 2: both findings imply one next step.],
)
