#import "../lib/presets/slide.typ": *

#show: slide-theme.with(config: (
  // text-font: "Noto Sans CJK JP",  // 日本語用設定
  title: [Slide Catalog],
  subtitle: [Implemented features overview],
  author: [Ryo Araki$at$Typst Templates],
  summary: [catalog$at$slide],
))
#slide-title-slide()

= Catalog

==
== Standard content

#slide[
  This slide shows the base theme, section footer, and standard text layout.
]

== Questions and answers

#slide[
  #question[How should I present the main claim?]
  #answer[Lead with the result, then give the minimum background.]
  #summary-no-num[Box components are shared across slide and poster presets.]
]

== Two-column layout

#slide[
  Left column content with a short bullet list:

  - Preset theme
  - Footer metadata
  - Reusable boxes
][
  #align(center)[
    #textbox([Reusable callout], aqua)
  ]
]

== Annotated equation

#slide[
  #let annot(color) = (fill: color, height: 24pt, arrow-length: 18pt)
  #v(3em)
  #pinit-highlight-equation-from("sl:lhs1", "sl:lhs2", ..annot(red), dx: -4pt, dy: -2pt, pos: "top")[
    Source term
  ]
  #pinit-highlight-equation-from("sl:rhs1", "sl:rhs2", ..annot(green), dx: 0pt, dy: 4pt, pos: "bottom")[
    Dissipation
  ]
  $
    #pin("sl:lhs1"); partial_t u #pin("sl:lhs2")
    = - grad p + #pin("sl:rhs1"); nu laplacian u #pin("sl:rhs2")
  $
]
