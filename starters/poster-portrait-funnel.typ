#import "../lib/presets/poster.typ": *

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*Portrait Funnel Poster*],
  subtitle: [],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [],
    ),
  ),
  date: [],
  summary: [],
  abstract: [],
  venue: [Template Showcase$at$Local Workspace, 2026-06-20],
  acknowledgements: [Acknowledgements: JSPS KAKENHI JP00H00000],
  logo: [],
  bibliography: "/starters/biblio.bib",
)

#let palette = poster-portrait-palette("default")

#let fixed-canvas(body) = align(center)[#cetz.canvas({
  import cetz.draw: *
  rect((-10, -6), (10, 6), fill: white.transparentize(100%), stroke: none)
  body
})]

#show: poster-portrait-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)

#poster-portrait-funnel(
  headline: [A short headline states the poster's main result before the details.],
  upper: (
    title: [Main figure],
    figure: fixed-canvas({
      import cetz.draw: *
      grid((-8, -4), (8, 4), stroke: gray.lighten(30%))
      line((-7, -2), (-2, 1), (3, 2.6), (7, 3.2), stroke: (paint: palette.at("structure"), thickness: 0.35), mark: (end: "stealth"))
      circle((-7, -2), radius: 0.35, fill: palette.at("accent"), stroke: none)
      content((0, -4.7), text(fill: palette.at("structure"))[Main trend])
    }),
    caption: [
      *Read first*: The largest visual element should carry the central evidence.
    ],
    figure-side: left,
  ),
  lower: (
    title: [Support figure or equation],
    figure: fixed-canvas({
      import cetz.draw: *
      rect((-7, -2), (7, 2), radius: 4pt, fill: palette.at("structure").lighten(75%), stroke: palette.at("structure"))
      content((0, 0), text(size: 28pt, fill: palette.at("structure"))[$partial_t q + u dot grad q = S(q)$])
      content((0, -4.2), text(fill: palette.at("structure"))[Supporting relation])
    }),
    caption: [
      *Support*: Use the second large slot for a robustness check, comparison, or equation.
    ],
    figure-side: right,
  ),
  conclusion: [The support figure strengthens the main claim and points to the next discussion.],
)
