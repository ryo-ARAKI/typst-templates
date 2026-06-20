#import "../lib/presets/poster.typ": *

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*Portrait Takeaway Poster*],
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

#let palette = poster-portrait-takeaway-palette("default")

#let fixed-canvas(body) = align(center)[#cetz.canvas({
  import cetz.draw: *
  rect((-23, -13), (23, 13), fill: white.transparentize(100%), stroke: none)
  body
})]

#let starter-trend-figure = fixed-canvas({
  import cetz.draw: *
  grid(
    (-23, -17),
    (23, 17),
    stroke: gray.lighten(38%),
  )
  rect((-22, -11.5), (22, 11.5), radius: 6pt, fill: palette.at("structure").transparentize(94%), stroke: none)
  line((-18, -7.6), (18, -7.6), stroke: (paint: palette.at("ink"), thickness: 0.32), mark: (end: "stealth"))
  line((-18, -7.6), (-18, 7.4), stroke: (paint: palette.at("ink"), thickness: 0.32), mark: (end: "stealth"))
  line((-14, -7.9), (-14, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((-6, -7.9), (-6, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((2, -7.9), (2, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((10, -7.9), (10, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  rect((-13.8, -3.7), (14.2, 4.2), radius: 4pt, fill: palette.at("structure").transparentize(86%), stroke: none)
  line(
    (-14, -2.8),
    (-9, -1.0),
    (-4, 0.7),
    (1, 1.9),
    (7, 3.0),
    (14, 3.6),
    stroke: (paint: palette.at("structure"), thickness: 0.72),
    mark: (end: "stealth"),
  )
  circle((-14, -2.8), radius: 0.55, fill: palette.at("accent"), stroke: none)
  circle((14, 3.6), radius: 0.62, fill: palette.at("structure"), stroke: (paint: white, thickness: 0.12))
  rect((-21.6, 8.4), (-7.2, 11.2), radius: 5pt, fill: white.transparentize(10%), stroke: (
    paint: palette.at("structure"),
    thickness: 0.16,
  ))
  rect((-5.8, 8.4), (7.8, 11.2), radius: 5pt, fill: white.transparentize(10%), stroke: (
    paint: palette.at("accent"),
    thickness: 0.16,
  ))
  rect((9.2, 8.4), (21.6, 11.2), radius: 5pt, fill: white.transparentize(10%), stroke: (
    paint: palette.at("example"),
    thickness: 0.16,
  ))
  content((-15., 10.0), text(size: 34pt, fill: palette.at("structure"))[signal])
  content((1.0, 10.0), text(size: 34pt, fill: palette.at("accent"))[baseline])
  content((15.0, 10.0), text(size: 34pt, fill: palette.at("example"))[check])
  content((-14, -8.9), text(size: 24pt, fill: palette.at("ink"))[t1])
  content((-6, -8.9), text(size: 24pt, fill: palette.at("ink"))[t2])
  content((2, -8.9), text(size: 24pt, fill: palette.at("ink"))[t3])
  content((10, -8.9), text(size: 24pt, fill: palette.at("ink"))[t4])
  rect((-16, -11.4), (-12.5, -9.6), fill: palette.at("structure").transparentize(25%), stroke: none)
  rect((-10.5, -11.4), (-7, -10.2), fill: palette.at("structure").transparentize(45%), stroke: none)
  rect((-5, -11.4), (-1.5, -9.2), fill: palette.at("structure").transparentize(20%), stroke: none)
  rect((0.5, -11.4), (4, -10.0), fill: palette.at("structure").transparentize(55%), stroke: none)
  rect((6, -11.4), (9.5, -8.9), fill: palette.at("structure").transparentize(18%), stroke: none)
  content((14.0, -10.2), text(size: 28pt, fill: palette.at("structure"))[compact evidence])
})

#let starter-equation-figure = fixed-canvas({
  import cetz.draw: *
  rect((-18, -4.2), (18, 4.2), radius: 8pt, fill: palette.at("structure").lighten(75%), stroke: (
    paint: palette.at("structure"),
    thickness: 0.22,
  ))
  content((0, -0.4), text(size: 58pt, fill: palette.at("structure"))[$partial_t q + u dot grad q = S(q)$])
  rect((-21.5, 7.4), (-11.5, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("structure"),
    thickness: 0.14,
  ))
  rect((-10.5, 7.4), (-0.5, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("accent"),
    thickness: 0.14,
  ))
  rect((0.5, 7.4), (10.5, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("example"),
    thickness: 0.14,
  ))
  rect((11.5, 7.4), (21.5, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("structure"),
    thickness: 0.14,
  ))
  content((-16.5, 9.4), text(size: 34pt, fill: palette.at("structure"))[change])
  content((-5.5, 9.4), text(size: 34pt, fill: palette.at("accent"))[transport])
  content((5.5, 9.4), text(size: 34pt, fill: palette.at("example"))[source])
  content((16.5, 9.4), text(size: 34pt, fill: palette.at("structure"))[closure])
  line((-16.5, 7.4), (-10.5, 4.2), stroke: (paint: palette.at("structure"), thickness: 0.24), mark: (end: "stealth"))
  line((-5.5, 7.4), (-2.6, 4.2), stroke: (paint: palette.at("accent"), thickness: 0.24), mark: (end: "stealth"))
  line((5.5, 7.4), (6.5, 4.2), stroke: (paint: palette.at("example"), thickness: 0.24), mark: (end: "stealth"))
  rect((-21.5, -11.2), (-12, -7.0), radius: 5pt, fill: palette.at("structure").lighten(82%), stroke: none)
  rect((-10.5, -11.2), (-1, -7.0), radius: 5pt, fill: palette.at("accent").lighten(78%), stroke: none)
  rect((0.5, -11.2), (10, -7.0), radius: 5pt, fill: palette.at("example").lighten(80%), stroke: none)
  rect((11.5, -11.2), (21.5, -7.0), radius: 5pt, fill: palette.at("structure").lighten(82%), stroke: none)
  content((-16.8, -9.0), text(size: 30pt, fill: palette.at("ink"))[$q(t)$])
  content((-5.8, -9.0), text(size: 30pt, fill: palette.at("ink"))[$u dot grad q$])
  content((5.2, -9.0), text(size: 30pt, fill: palette.at("ink"))[$S(q)$])
  content((16.5, -9.0), text(size: 30pt, fill: palette.at("ink"))[units])
})

#show: poster-portrait-takeaway-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)

#poster-portrait-takeaway(
  headline-takeaway: [State the poster's main result in one sentence.],
  headline-detail: [Use this second line for the context or condition that makes the takeaway actionable.],
  upper: (
    title: [Main figure],
    figure: starter-trend-figure,
    caption: [
      *Read first*: The largest visual element should carry the central evidence.
    ],
    caption-title: [Guide],
    figure-side: left,
  ),
  lower: (
    title: [Support figure or equation],
    figure: starter-equation-figure,
    caption: [
      *Support*: Use the second large slot for a robustness check, comparison, or equation.
    ],
    caption-title: [Guide],
    figure-side: right,
  ),
  conclusion-takeaway: [Name the claim viewers should remember.],
  conclusion-detail: [Connect the support figure to the main result and point to the next discussion.],
)
