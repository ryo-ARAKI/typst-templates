#import "../lib/presets/poster.typ": *

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*Portrait Takeaway Poster*],
  subtitle: [],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Tokyo University of Science],
      email: [araki.ryo$at$rs.tus.ac.jp],
    ),
    // (
    //   name: [荒木~亮],
    //   affiliation: [東京理科大学],
    //   email: [araki.ryo$at$rs.tus.ac.jp],
    // ),
  ),
  date: [],
  summary: [],
  abstract: [],
  venue: [Template Showcase$at$Local Workspace, 2026-06-20],
  acknowledgements: [Acknowledgements: JSPS KAKENHI JP00H00000],
  logo: [],
  bibliography: "/starters/biblio.bib",
)

#let palette = poster-portrait-takeaway-palette(theme: "default")

#let fixed-canvas(body) = align(center)[#cetz.canvas({
  import cetz.draw: *
  rect((-23, -13), (23, 13), fill: white.transparentize(100%), stroke: none)
  body
})]

#let example1-figure = fixed-canvas({
  import cetz.draw: *
  grid(
    (-20, -10),
    (20, 10),
    stroke: gray.lighten(38%),
  )
})

#let example2-figure = fixed-canvas({
  import cetz.draw: *
  grid(
    (-20, -10),
    (20, 10),
    stroke: gray.lighten(38%),
  )
})

#let example3-figure = fixed-canvas({
  import cetz.draw: *
  grid(
    (-20, -10),
    (20, 10),
    stroke: gray.lighten(38%),
  )
})

#show: poster-portrait-takeaway-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)

#poster-portrait-takeaway(
  palette: palette,
  headline-height: 10%,
  conclusion-height: 10%,
  figure-heights: (1.0fr, 1.0fr, 1.0fr),
  headline-takeaway: [Takeaway message.],
  headline-detail: [
    + Supplement 1.
    + Supplement 2.
    + Supplement 3.
  ],
  sections: (
    (
      title: [Topic 1],
      figure: example1-figure,
      note: [
        *Guide*: Guide sentences.
      ],
      figure-side: left,
      figure-width: 1.1fr,
      note-width: 0.9fr,
    ),
    (
      title: [Topic 2],
      figure: example2-figure,
      note: [
        *Guide*: Guide sentences.
      ],
      figure-side: right,
      figure-width: 1.1fr,
      note-width: 0.9fr,
    ),
    (
      title: [Topic 3],
      figure: example3-figure,
      note: [
        *Guide*: Guide sentences.
      ],
      figure-side: left,
      figure-width: 1.1fr,
      note-width: 0.9fr,
    ),
  ),
  conclusion-takeaway: [Concluding message.],
  conclusion-detail: [
    - Supplement 1
    - Supplement 2
    - Supplement 3
  ],
)
