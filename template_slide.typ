#import "global-slide.typ": *
#import "utils.typ": jp-spacing

// ===========================================
// Set font family
// NOTE: Noto Sans CJK JP font is required for Japanese.
// ===========================================
// Serif fonts: Amiri, Noto Music
// Sans serif fonts: Inter Display, Nimbus Sans, TeX Gyre Heros
#set text(font: "Cabin")
#show math.equation: set text(font: "Latin Modern Math")
#show regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]"): set text(font: "Noto Sans CJK JP") // For Japanese
// 和欧文間空白
#show math.equation.where(block: false): it => jp-spacing(it)

// ===========================================
// Set up slide design
// ===========================================
#let footer-columns = (45%, 45%, 10%)

#show: university-theme.with(
  header-right: "", // Remove section
  footer-columns: footer-columns, // Decompose footer into three columns
  // left footer: current section
  footer-a: self => {
    sym.section + " " + utils.display-current-heading(level: 1)
  },
  // centre footer: summary & presentation date
  footer-b: self => {
    h(1fr)
    self.info.summary
    h(1fr)
    self.info.date.display(self.datetime-format)
    h(1fr)
  },
  // right footer: slide number
  footer-c: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  // Set up title slide information
  config-info(
    title: [Presentation title\ ...continued to the second line],
    subtitle: [Subtitle],
    author: [
      *Presenter name*: Institution\
      Co-author name: Institution
    ],
    date: datetime.today(),
    institution: [], // Now written in `author` field
    logo: "", // emoji.school,
    summary: [presenter$at$subtitle],
  ),
  // Date format
  config-common(datetime-format: "[month repr:short]. [day], [year]"),
  // config-common(datetime-format: "[year]年[month]月[day]日"), // 日本語
  // Do not show 'new section' slide
  config-common(new-section-slide-fn: none),
  // Semi-transparent animation ***does not work for some cases***
  // config-methods(cover: utils.semi-transparent-cover.with(alpha: 80%)),
  // Handout slide
  config-common(handout: false),
)

// ===========================================
// Other settings
// ===========================================
// Vertical gap between text and equation
#show math.equation.where(block: true): set block(spacing: 0.7em)
// add new theorion environment
// #show: show-question
// #show: show-summary

#title-slide()

// ==================================================
= Chapter title
// ==================================================

==              // without this, subsection will not be printed. Related with `config-common(new-section-slide-fn: none)`?
== Simple slide

Slide contents.

== Slide with `#slide` block and animation
#slide[
  $
        f & = m a        \
    pause & = m dv(v, t)
  $
]

== 日本語と数式
#slide[
  運動方程式$f=m a$は質量$m$の物体に力$f$が作用したとき物体に働く加速度$a$を記述する．
]

== Annotation for equation using `pint`
#slide[
  #v(50pt)
  #pinit-highlight-equation-from(1, 2, height: 60pt, dx: -4pt, dy: 19pt, pos: "bottom", fill: red, arrow-length: 20pt)[
    Time derivative
  ]
  #pinit-highlight-equation-from(3, 4, height: 30pt, dx: 27pt, dy: 4pt, pos: "top", fill: blue, arrow-length: 30pt)[
    Advect
  ]
  #pinit-highlight-equation-from(5, 6, height: 60pt, dx: 7pt, dy: 17pt, pos: "bottom", fill: green, arrow-length: 20pt)[
    Pressure gradient
  ]
  #pinit-highlight-equation-from(7, 8, height: 30pt, dx: 13pt, dy: 4pt, pos: "top", fill: orange, arrow-length: 30pt)[
    Viscous
  ]
  #pinit-highlight-equation-from(9, 10, height: 30pt, dx: 0pt, dy: 4pt, pos: "right", fill: aqua, arrow-length: 20pt)[
    Force
  ]
  $
    // pdv(vb(u), t) + (vb(u) dprod grad) vb(u) = - 1 / rho grad p + nu laplacian vb(u) + vb(f)
    #pin(1);(partial vb(u)) / (partial t)#pin(2)
    + #pin(3);(vb(u) dprod grad) vb(u)#pin(4)
    = - #pin(5);1/rho grad p#pin(6)
    + #pin(7)nu laplacian vb(u)#pin(8)
    + #pin(9)vb(f)#pin(10)
  $
]

== Two-column slide

#slide[
  First column
][
  Second column
]

== Two-column slide with uneven columns
#slide(composer: (60%, auto))[
  First column
][
  #cetz.canvas({
    import cetz.draw: *
    // for reference
    grid(
      (-5, -7),
      (5, 7),
      stroke: gray,
    )
    circle((0, 0), radius: .1, fill: black, stroke: none)
    content((0, 0), text[tmp])
  })
]

== Partially two-column slide
#slide[
  #grid(
    columns: (60%, 40%),
    [
      === Description
      - test test test
      - test test test
      - test test test
    ],
    [
      #align(center)[
        #cetz.canvas({
          import cetz.draw: *
          // for reference
          grid(
            (-4, -4),
            (4, 4),
            stroke: gray,
          )
          circle((0, 0), radius: .1, fill: black, stroke: none)
          // figure
          // content((0, 0), image("fig/figure.png", width: 10cm))
          // Overwrite x label
          rect(fill: gray, stroke: white, (-2.0, -2.5), (2.0, -3.5))
          content((0, -3), [#text(16pt)[x label]])
          // Overwrite y label
          rect(fill: gray, stroke: white, (-2.5, -2.0), (-3.5, 2.0))
          content((-3, 0), angle: 90deg, [#text(16pt)[y label]])
        })
      ]
    ],
  )
  #v(1fr)
  #showybox(frame: showybox_focus, [Important text])
]

== Questions and summaries
#slide[
  #question[Question 1]
  #question[Question 2]
  #summary[Summary 1]
  #summary[Summary 2]
]

// Freeze last-slide-number
#show: appendix

#slide[
  #bibliography(
    title: "References",
    style: "annual-reviews-author-date",
    "biblio.bib",
  )
]

// ==================================================
= Appendix
// ==================================================

== To Do list
#slide[
  ==
  - Add template contents
  - Add animation example
]
