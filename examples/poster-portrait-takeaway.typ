#import "../lib/presets/poster.typ": *

#let colormath(math, color) = text(fill: color, $#math$)

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*Portrait A0 Takeaway Feature Catalog*],
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

#let solarized_magenta_palette = poster-portrait-takeaway-palette("solarized-magenta")
#let wine-palette = poster-portrait-takeaway-palette("wine")
#let brewer_dark2_magenta_palette = poster-portrait-takeaway-palette("brewer-dark2-magenta")

#let fixed-canvas(body) = align(center)[#cetz.canvas({
  import cetz.draw: *
  rect((-23, -13), (23, 13), fill: white.transparentize(100%), stroke: none)
  body
})]

#let trend-figure(label, palette, color) = fixed-canvas({
  import cetz.draw: *
  grid(
    (-23, -17),
    (23, 17),
    stroke: gray.lighten(38%),
  )
  rect((-22, -11.5), (22, 11.5), radius: 6pt, fill: color.transparentize(94%), stroke: none)
  line((-18, -7.6), (18, -7.6), stroke: (paint: palette.at("ink"), thickness: 0.32), mark: (end: "stealth"))
  line((-18, -7.6), (-18, 7.4), stroke: (paint: palette.at("ink"), thickness: 0.32), mark: (end: "stealth"))
  line((-14, -7.9), (-14, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((-6, -7.9), (-6, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((2, -7.9), (2, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((10, -7.9), (10, -7.3), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((-18.3, -4.8), (-17.7, -4.8), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((-18.3, -1.6), (-17.7, -1.6), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((-18.3, 1.6), (-17.7, 1.6), stroke: (paint: palette.at("ink"), thickness: 0.18))
  line((-18.3, 4.8), (-17.7, 4.8), stroke: (paint: palette.at("ink"), thickness: 0.18))
  rect((-13.8, -3.7), (14.2, 4.2), radius: 4pt, fill: color.transparentize(86%), stroke: none)
  line(
    (-14, -2.8),
    (-9, -1.0),
    (-4, 0.7),
    (1, 1.9),
    (7, 3.0),
    (14, 3.6),
    stroke: (paint: color, thickness: 0.72),
    mark: (end: "stealth"),
  )
  line(
    (-14, -1.3),
    (-9, -0.2),
    (-4, 0.9),
    (1, 1.5),
    (7, 2.0),
    (14, 2.4),
    stroke: (paint: palette.at("accent"), thickness: 0.5),
  )
  circle((-14, -2.8), radius: 0.55, fill: palette.at("accent"), stroke: none)
  circle((14, 3.6), radius: 0.62, fill: color, stroke: (paint: white, thickness: 0.12))
  rect((-21.6, 8.4), (-7.2, 11.2), radius: 5pt, fill: white.transparentize(10%), stroke: (paint: color, thickness: 0.16))
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
  content((-19, 12), text(size: 36pt, fill: color)[#label])
  content((-14, -8.9), text(size: 24pt, fill: palette.at("ink"))[t1])
  content((-6, -8.9), text(size: 24pt, fill: palette.at("ink"))[t2])
  content((2, -8.9), text(size: 24pt, fill: palette.at("ink"))[t3])
  content((10, -8.9), text(size: 24pt, fill: palette.at("ink"))[t4])
  rect((-16, -11.4), (-12.5, -9.6), fill: color.transparentize(25%), stroke: none)
  rect((-10.5, -11.4), (-7, -10.2), fill: color.transparentize(45%), stroke: none)
  rect((-5, -11.4), (-1.5, -9.2), fill: color.transparentize(20%), stroke: none)
  rect((0.5, -11.4), (4, -10.0), fill: color.transparentize(55%), stroke: none)
  rect((6, -11.4), (9.5, -8.9), fill: color.transparentize(18%), stroke: none)
  content((14.0, -10.2), text(size: 28pt, fill: color)[compact evidence])
})

#let comparison-figure(palette) = fixed-canvas({
  import cetz.draw: *
  grid(
    (-23, -13),
    (23, 13),
    stroke: gray.lighten(40%),
  )
  rect((-22, -11.4), (22, 11.4), radius: 6pt, fill: palette.at("structure").transparentize(94%), stroke: none)
  line((-18, -7.0), (18, -7.0), stroke: (paint: palette.at("ink"), thickness: 0.32), mark: (end: "stealth"))
  line((-18, -7.0), (-18, 7.2), stroke: (paint: palette.at("ink"), thickness: 0.32), mark: (end: "stealth"))
  rect((3.5, -6.4), (16.8, 6.8), radius: 5pt, fill: palette.at("accent").transparentize(86%), stroke: none)
  line((-14, -3.0), (-9, -2.0), (-4, -0.3), (1, 1.3), (7, 2.6), (14, 3.4), stroke: (
    paint: palette.at("structure"),
    thickness: 0.62,
  ))
  line((-14, 2.3), (-9, 1.8), (-4, 1.3), (1, 0.7), (7, 0.1), (14, -0.7), stroke: (paint: palette.at("accent"), thickness: 0.62))
  circle((14, 3.4), radius: 0.5, fill: palette.at("structure"), stroke: none)
  circle((14, -0.7), radius: 0.5, fill: palette.at("accent"), stroke: none)
  line((1, 1.3), (1, 0.7), stroke: (paint: palette.at("ink"), thickness: 0.28), mark: (end: "stealth"))
  line((7, 2.6), (7, 0.1), stroke: (paint: palette.at("ink"), thickness: 0.28), mark: (end: "stealth"))
  rect((-21.5, 7.8), (-9.2, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("structure"),
    thickness: 0.16,
  ))
  rect((-7.8, 7.8), (4.6, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("accent"),
    thickness: 0.16,
  ))
  rect((6.0, 7.8), (21.5, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("example"),
    thickness: 0.16,
  ))
  content((-16, 9.5), text(size: 32pt, fill: palette.at("structure"))[condition A])
  content((-2.0, 9.5), text(size: 32pt, fill: palette.at("accent"))[condition B])
  content((14, 9.5), text(size: 32pt, fill: palette.at("example"))[difference window])
  content((8.8, 3.8), text(size: 30pt, fill: palette.at("ink"))[added contrast])
  rect((-18, -11.2), (-13.5, -9.0), fill: palette.at("structure").transparentize(25%), stroke: none)
  rect((-11.5, -11.2), (-7, -10.0), fill: palette.at("accent").transparentize(25%), stroke: none)
  rect((-5, -11.2), (-0.5, -8.4), fill: palette.at("structure").transparentize(35%), stroke: none)
  rect((1.5, -11.2), (6, -9.6), fill: palette.at("accent").transparentize(35%), stroke: none)
  content((12.6, -10.0), text(size: 30pt, fill: palette.at("structure"))[paired summary])
  content((0, -12.5), text(size: 32pt, fill: palette.at("structure"))[Support comparison])
})

#let method-figure(palette) = fixed-canvas({
  import cetz.draw: *
  rect((-21.5, -6.2), (-9.5, 6.2), radius: 8pt, fill: palette.at("structure").lighten(78%), stroke: (
    paint: palette.at("structure"),
    thickness: 0.2,
  ))
  rect((-6, -6.2), (6, 6.2), radius: 8pt, fill: palette.at("accent").lighten(72%), stroke: (
    paint: palette.at("accent"),
    thickness: 0.2,
  ))
  rect((9.5, -6.2), (21.5, 6.2), radius: 8pt, fill: palette.at("example").lighten(76%), stroke: (
    paint: palette.at("example"),
    thickness: 0.2,
  ))
  line((-9.5, 0), (-6, 0), stroke: (paint: palette.at("structure"), thickness: 0.65), mark: (end: "stealth"))
  line((6, 0), (9.5, 0), stroke: (paint: palette.at("structure"), thickness: 0.65), mark: (end: "stealth"))
  content((-15.5, 1.6), text(size: 50pt, fill: palette.at("structure"), weight: "bold")[Input])
  content((-15.5, -1.6), text(size: 34pt, fill: palette.at("ink"))[data + assumptions])
  content((0, 1.6), text(size: 50pt, fill: palette.at("accent"), weight: "bold")[Model])
  content((0, -1.6), text(size: 34pt, fill: palette.at("ink"))[workflow])
  content((15.5, 1.6), text(size: 50pt, fill: palette.at("example"), weight: "bold")[Output])
  content((15.5, -1.6), text(size: 34pt, fill: palette.at("ink"))[evidence])
  rect((-21.5, 8.0), (-13.8, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("structure"),
    thickness: 0.14,
  ))
  rect((-12.5, 8.0), (-4.8, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("accent"),
    thickness: 0.14,
  ))
  rect((-3.5, 8.0), (4.2, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("accent"),
    thickness: 0.14,
  ))
  rect((5.5, 8.0), (13.2, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("example"),
    thickness: 0.14,
  ))
  rect((14.5, 8.0), (21.5, 11.2), radius: 5pt, fill: white.transparentize(8%), stroke: (
    paint: palette.at("example"),
    thickness: 0.14,
  ))
  content((-18, 9.8), text(size: 28pt, fill: palette.at("ink"))[schema])
  content((-9, 9.8), text(size: 28pt, fill: palette.at("ink"))[fit])
  content((0.0, 9.8), text(size: 28pt, fill: palette.at("ink"))[validate])
  content((8.5, 9.8), text(size: 28pt, fill: palette.at("ink"))[rank])
  content((17.5, 9.8), text(size: 28pt, fill: palette.at("ink"))[report])
  rect((-19.5, -11.0), (-15.8, -8.4), fill: palette.at("structure").transparentize(35%), stroke: none)
  rect((-13.8, -11.0), (-10.1, -9.2), fill: palette.at("accent").transparentize(35%), stroke: none)
  rect((-8.1, -11.0), (-4.4, -7.8), fill: palette.at("example").transparentize(35%), stroke: none)
  content((6.5, -9.6), text(size: 30pt, fill: palette.at("structure"))[quality checks])
})

#let equation-figure(palette) = fixed-canvas({
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
  theme: solarized_magenta_palette,
  headline-height: 10%,
  conclusion-height: 13cm,
  figure-heights: (1fr, 1.25fr),
  headline-takeaway: [Main result first; support explains why it is credible.],
  headline-detail: [Use the upper figure for central evidence and the lower figure for a compact check, equation, or comparison.],
  upper: (
    title: [Main figure],
    figure: trend-figure([Main result], solarized_magenta_palette, solarized_magenta_palette.at("structure")),
    caption: [
      #question[Which result should viewers read first?]
      #summary[
        Put the central evidence in the large slot. Cite compactly when needed:
        @Tanogami2024_information.
      ]
      Inline math can stay visible: #colormath($H(Y bar X)$, solarized_magenta_palette.at("structure")).
    ],
    caption-title: [Read first],
    figure-side: left,
  ),
  lower: (
    title: [Support figure or equation],
    figure: equation-figure(solarized_magenta_palette),
    caption: [
      *Support slot*: Use this area for a robustness check, governing equation, or a short comparison.
      #v(0.35em)
      $
        partial_t q = #textbox($S(q)$, gray)
      $
    ],
    caption-title: [Support notes],
    figure-side: right,
  ),
  conclusion-takeaway: [Support evidence makes the main claim easier to trust.],
  conclusion-detail: [End by naming what the support figure rules out and what discussion should happen next.],
)

#pagebreak()

#poster-portrait-takeaway(
  theme: wine-palette,
  headline-takeaway: [Show the method before interpreting the main result.],
  headline-detail: [Put the schematic first so viewers know which assumptions shape the figure below.],
  upper: (
    title: [Method schematic],
    figure: method-figure(wine-palette),
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
    caption-title: [Method notes],
    figure-side: right,
  ),
  lower: (
    title: [Main figure],
    figure: trend-figure([Main figure], wine-palette, wine-palette.at("example")),
    caption: [
      *Meaning*: Interpret the result using the vocabulary established above.
      #v(0.35em)
      #showybox(
        frame: (
          border-color: white,
          body-color: wine-palette.at("panel-fill"),
        ),
      )[
        *Side note*: A narrow guide column works well for caveats or reading order.
      ]
    ],
    caption-title: [Interpretation],
    figure-side: left,
  ),
  conclusion-takeaway: [The method reveals the mechanism behind the result.],
  conclusion-detail: [Close with the causal or diagnostic link that the schematic made visible.],
)

#pagebreak()

#poster-portrait-takeaway(
  theme: brewer_dark2_magenta_palette,
  headline-takeaway: [Two findings should converge on one conclusion.],
  headline-detail: [Use matching scale and vocabulary across both figure slots so the comparison reads as one argument.],
  upper: (
    title: [Main figure 1],
    figure: scale(85%, reflow: true)[
      #trend-figure([Main figure 1], brewer_dark2_magenta_palette, brewer_dark2_magenta_palette.at("accent"))
    ],
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
    caption-title: [Pairing notes],
    figure-side: left,
    widths: (1fr, 1fr),
  ),
  lower: (
    title: [Main figure 2],
    figure: scale(85%, reflow: true)[
      #comparison-figure(brewer_dark2_magenta_palette)
    ],
    caption: [
      #question-no-num[
        What changes when the second condition is added?
      ]
      #v(0.35em)
      #showybox(
        frame: (
          border-color: white,
          body-color: brewer_dark2_magenta_palette.at("accent").lighten(76%),
        ),
      )[
        *Idea*: Use color only to separate roles, not to encode every detail.
      ]
    ],
    caption-title: [Comparison notes],
    figure-side: right,
    widths: (1fr, 1fr),
  ),
  conclusion-takeaway: [Both findings point to the same next step.],
  conclusion-detail: [Make the final band synthesize the pair instead of repeating either panel alone.],
)
