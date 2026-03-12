#import "../lib/presets/poster.typ": *

#show: poster-theme.with(config: (
  // text-font: "Noto Sans CJK JP",  // 日本語用設定
  title: [*Poster Catalog*],
  authors: [Ryo Araki$at$Typst Templates],
  venue: [Template Showcase$at$Local Workspace, March 12, 2026],
))
#poster-title()

#columns(
  2,
  [
    #pop.column-box(heading: [*Shared boxes*])[
      #question[What can be reused across formats?]
      #summary[
        The same question/summary boxes and equation annotations can be reused.
      ]
      #v(0.8em)
      #showybox(frame: showybox-focus)[
        *Focus*: reusable callouts can be placed inside poster sections.
      ]
    ]
    #colbreak()
    #pop.column-box(heading: [*Figures and math*])[
      #grid(
        columns: (1fr, 1fr),
        gutter: 0.8em,
        [
          #rect(
            width: 100%,
            height: 6cm,
            fill: luma(235),
            stroke: gray,
          )
        ],
        [
          #pinit-highlight-equation-from(
            "po:eq1",
            "po:eq2",
            fill: blue,
            height: 18pt,
            dx: 0pt,
            dy: -2pt,
            pos: "top",
          )[
            Transport term
          ]
          $
            #pin("po:eq1"); partial_t q + u dot grad q #pin("po:eq2")
            = S(q)
          $
        ],
      )
    ]
  ],
)

#v(1fr)
#poster-bottom-box()
