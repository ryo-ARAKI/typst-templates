#import "@preview/peace-of-posters:0.5.6" as pop
#import "@preview/pinit:0.2.2": * // Annotation
#import "@preview/showybox:2.0.4": showybox // Colorful and customizable boxes
#import "@preview/theorion:0.4.1": * // theorem environment
#import "@preview/physica:0.9.7": * // Math constructs for science and engineering
#import "@preview/cetz:0.4.2" // Draw figures
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "annotated-equation.typ": *

#set page("a0", margin: 1cm)  // flipped: true for horizontal poster
#pop.set-poster-layout(pop.layout-a0)
#pop.set-theme(pop.psi-ch)
#pop.update-theme(
  heading-text-args: (fill: navy),
  body-box-args: (
    inset: (x: 0.4em, y: 0.5em),
    stroke: none,
  ),
  heading-box-args: (
    inset: (x: 0.2em, y: 0.4em),
    stroke: none,
  ),
)
#set text(size: pop.layout-a0.at("body-size"))
#let box-spacing = 1.2em
#set columns(gutter: box-spacing)
#set block(spacing: box-spacing)
#pop.update-poster-layout(
  spacing: box-spacing,
  // title-size: 56pt,
  // heading-size: 42pt,
  subtitle-size: 14pt,
  // authors-size: 42pt,
  // body-size: 28pt,
)

// ===========================================
// Set font family
// ===========================================
#set text(font: "Cabin")
#show math.equation: set text(font: "Latin Modern Math")
#show regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]"): set text(font: "Noto Sans CJK JP") // For Japanese
#let colormath(math, color) = text(fill: color, $#math$)
// 和欧文間空白
// https://qiita.com/zr_tex8r/items/a9d82669881d8442b574
#show math.equation.where(block: false): it => {
  let ghost = text(font: "Adobe Blank", "\u{375}") // 欧文ゴースト
  ghost
  it
  ghost
}

// ===========================================
// Set up coloured textbox
// ===========================================
#let textbox(text, color) = box(
  fill: color.lighten(50%),
  outset: (x: 4pt, y: 10pt),
  radius: 5pt,
  text,
)

// ===========================================
// Configuration of theorion (theorem environment)
// ===========================================
#import cosmos.clouds: * // simple, rainbow, clouds, fancy
#show: show-theorion
#let (question-counter, question-box, question, show-question) = make-frame(
  "question",
  "Q.",
  render: render-fn.with(fill: rgb("#FFB11B").lighten(70%)), // 山吹
)
#show: show-question
#let (summary-counter, summary-box, summary, show-summary) = make-frame(
  "summary",
  "A.",
  render: render-fn.with(fill: rgb("#E03C8A").lighten(70%)), // 躑躅
)
#show: show-summary

// ===========================================
// Other settings
// ===========================================
// tcolorbox equivalent
#let showybox_focus = (
  border-color: white,
  body-color: red.lighten(50%),
)

#pop.title-box(
  [*Title of the poster*],
  authors: [Presenter name$at$Institution #h(4.5cm) `email@address`],
  logo: grid(
    gutter: 5pt,
    cetz.canvas({
      import cetz.draw: *
      // for reference
      grid(
        (-6, -1.5),
        (6, 1.5),
        stroke: gray,
      )
      circle((0, 0), radius: .1, fill: black, stroke: none)

      // content((-2, 0), image("logo1.png", height: 4.5cm))
      // content((2, 0), image("logo2.png", height: 4.5cm))
    }),
  ),
)

#columns(
  2,
  [
    #pop.column-box(heading: [*Section title*])[

      #question[Research question]

      #v(1em)
      #pinit-highlight-equation-from(
        "NS:dudt1",
        "NS:dudt2",
        height: 80pt,
        dx: 0pt,
        dy: 30pt,
        pos: "top",
        fill: red,
        arrow-length: 30pt,
      )[Entropy change]
      $
        #pin("NS:dudt1")pdv(vb(u), t, s: \/)#pin("NS:dudt2") + (vb(u) dprod grad) vb(u)
        = - 1/rho grad p + nu laplacian vb(u) + vb(f)
      $<NS>

      #grid(
        columns: (1fr, 1fr),
        gutter: 0.2em,
        [
          #cetz.canvas({
            import cetz.draw: *
            // for reference
            grid(
              (-9, -5),
              (9, 5),
              stroke: gray,
            )
            circle((0, 0), radius: .1, fill: black, stroke: none)

            // content(
            //   (0, 0),
            //   image("fig/figure.png", width: 18cm),
            // )
          })
        ],
        [
          Dummy text
        ],
      )
      // まとめ
      #summary[
        Summary#h(1fr)#text(24pt)[Reference]
      ]
    ]
    #colbreak()

    #pop.column-box(heading: [*Section title*])[
    ]
  ],
)

#showybox(frame: (border-color: white, body-color: gray.lighten(50%)), [
  *Research Objective*:
])


#columns(
  2,
  [
    #pop.column-box(heading: [*Section title*])[

      #grid(
        columns: (1fr, 1fr),
        gutter: 0.2em,
        [
          #cetz.canvas({
            import cetz.draw: *
            // for reference
            grid(
              (-9, -5),
              (9, 5),
              stroke: gray,
            )
            circle((0, 0), radius: .1, fill: black, stroke: none)

            // content(
            //   (0, 0),
            //   image("fig/figure.png", width: 18cm),
            // )
          })
        ],
        [
          Dummy text
        ],
      )
    ]
    #colbreak()

    #pop.column-box(heading: [*Section title*])[
    ]
  ],
)

#v(1fr)
#showybox(frame: (border-color: white, body-color: red.lighten(50%)), [
  #grid(
    columns: (75%, 25%),
    gutter: 20pt,
    [
      *Summary*:\
      *Future Plan*:
    ],
    [
      #cetz.canvas({
        import cetz.draw: *
        content((-10.2, 0), text(28pt)[*References*\ Araki, _Journal_ (2025)\ Araki, in prep.])
      })
    ],
  )
])

#pop.bottom-box()[
  #h(1fr)#text(32pt)[Conference name$at$~Conference venue, October 1--10, 2025]
]
