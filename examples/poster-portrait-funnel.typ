#import "../lib/presets/poster.typ": *

#let colormath(math, color) = text(fill: color, $#math$)

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*Portrait A0 Funnel Feature Catalog*],
  subtitle: [],
  authors: (
    (
      name: [荒木亮],
      affiliation: [Typst Templates],
      email: [`araki.ryo@example.com`],
    ),
    (
      name: [共同研究者A],
      affiliation: [Reusable Layout],
      email: [],
    ),
  ),
  date: [],
  summary: [],
  abstract: [],
  venue: [Template Showcase$at$Local Workspace, 2026-06-20],
  acknowledgements: [Acknowledgements: JSPS KAKENHI JP00H00000],
  logo-relative-width: 20%,
  logo: poster-logo-strip(
    widths: (1fr, 1.4fr, 0.6fr),
    [
      #rect(
        width: 100%,
        height: 3cm,
        inset: 0.4cm,
        fill: colors.at("structure").lighten(78%),
        stroke: none,
      )[
        #align(center + horizon)[*A*]
      ]
    ],
    [
      #rect(
        width: 100%,
        height: 2cm,
        inset: 0.4cm,
        fill: colors.at("accent").lighten(72%),
        stroke: none,
      )[
        #align(center + horizon)[*B*]
      ]
    ],
    [
      #rect(
        width: 100%,
        height: 3.5cm,
        inset: 0.4cm,
        fill: colors.at("example").lighten(76%),
        stroke: none,
      )[
        #align(center + horizon)[*C*]
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
  grid(
    (-8, -4),
    (8, 4),
    stroke: gray.lighten(30%),
  )
  line(
    (-7, -2.4),
    (-3, -0.5),
    (0, 1.2),
    (4, 2.3),
    (7, 3.0),
    stroke: (paint: color, thickness: 0.35),
    mark: (end: "stealth"),
  )
  circle((-7, -2.4), radius: 0.35, fill: colors.at("accent"), stroke: none)
  rect((1.5, 1.0), (7.6, 3.4), radius: 4pt, fill: color.transparentize(72%), stroke: none)
  content((0, -4.7), text(fill: color)[#label])
})

#let comparison-figure = fixed-canvas({
  import cetz.draw: *
  grid(
    (-8, -4),
    (8, 4),
    stroke: gray.lighten(35%),
  )
  line((-7, -2.5), (-3, -1.5), (0, 0.2), (4, 1.7), (7, 2.5), stroke: (paint: colors.at("structure"), thickness: 0.3))
  line((-7, 1.5), (-3, 1.0), (0, 0.8), (4, 0.4), (7, -0.2), stroke: (paint: colors.at("accent"), thickness: 0.3))
  content((-4.9, 3.2), text(fill: colors.at("structure"))[condition A])
  content((4.6, -1.4), text(fill: colors.at("accent"))[condition B])
  content((0, -4.7), text(fill: colors.at("structure"))[Support comparison])
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
  headline: [Main + Support: one result carries the story; the second figure explains why it is credible.],
  upper: (
    title: [Main figure],
    figure: trend-figure([Main result], colors.at("structure")),
    caption: [
      #question[Which result should viewers read first?]
      #summary[
        Put the central evidence in the large slot. Cite compactly when needed:
        @Tanogami2024_information.
      ]
      Inline math can stay visible: #colormath($H(Y bar X)$, colors.at("structure")).
    ],
    figure-side: left,
  ),
  lower: (
    title: [Support figure or equation],
    figure: equation-figure,
    caption: [
      *Support slot*: Use this area for a robustness check, governing equation, or a short comparison.
      #v(0.35em)
      $
        partial_t q = #textbox($S(q)$, gray)
      $
    ],
    figure-side: right,
  ),
  conclusion: [Main + Support: the support figure makes the main claim easier to trust.],
)

#pagebreak()

#poster-portrait-funnel(
  headline: [Method + Main: show the analysis path before asking viewers to interpret the result.],
  upper: (
    title: [Method schematic],
    figure: method-figure,
    caption: [
      #aligned-enum(
        (
          ([Step 1], [Define the input and assumptions.]),
          ([Step 2], [Run the model or workflow.]),
          ([Step 3], [Read the output as evidence.]),
        ),
      )
      #v(0.35em)
      #showybox(frame: showybox-focus)[
        *Focus*: Keep the method block schematic and scannable.
      ]
    ],
    figure-side: right,
  ),
  lower: (
    title: [Main figure],
    figure: trend-figure([Main figure], colors.at("example")),
    caption: [
      *Meaning*: Interpret the result using the vocabulary established above.
      #v(0.35em)
      #showybox(
        frame: (
          border-color: white,
          body-color: gray.lighten(65%),
        ),
      )[
        *Side note*: A narrow guide column works well for caveats or reading order.
      ]
    ],
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
    caption: [
      #aligned-items(
        (
          ([Role], [Establish the central contrast.]),
          ([Use], [Pair with the second result, not a separate story.]),
        ),
      )
      #v(0.35em)
      #summary-no-num[
        Short summaries fit well when both figure slots are equally important.
      ]
    ],
    figure-side: left,
  ),
  lower: (
    title: [Main figure 2],
    figure: comparison-figure,
    caption: [
      #question-no-num[
        What changes when the second condition is added?
      ]
      #v(0.35em)
      #showybox(
        frame: (
          border-color: white,
          body-color: colors.at("accent").lighten(76%),
        ),
      )[
        *Idea*: Use color only to separate roles, not to encode every detail.
      ]
    ],
    figure-side: right,
  ),
  conclusion: [Main 1 + Main 2: both findings point to the same next step.],
)
