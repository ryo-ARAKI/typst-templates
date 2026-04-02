#import "../lib/presets/poster.typ": *

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*ポスター機能カタログ*],
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
  venue: [Template Showcase$at$Local Workspace, 2026-03-12],
  logo: poster-logo-strip(
    widths: (1fr, 1.4fr, 0.8fr),
    [
      #rect(
        width: 100%,
        height: 2.3cm,
        inset: 0.4cm,
        fill: rgb("#dce7f7"),
        stroke: none,
      )[
        #align(center + horizon)[*Logo A*]
      ]
    ],
    [
      #rect(
        width: 100%,
        height: 2.3cm,
        inset: 0.4cm,
        fill: rgb("#f8efd5"),
        stroke: none,
      )[
        #align(center + horizon)[*Logo B*]
      ]
    ],
    [
      #rect(
        width: 100%,
        height: 2.3cm,
        inset: 0.4cm,
        fill: rgb("#e1f3e0"),
        stroke: none,
      )[
        #align(center + horizon)[*Logo C*]
      ]
    ],
  ),
  bibliography: none,
)

#show: poster-theme.with(config: metadata)
#poster-title()

#columns(
  2,
  [
    #pop.column-box(heading: [*共通の囲み枠*])[
      #question[どの部品を形式横断で再利用できますか？]
      #summary[
        question / summary box と数式注釈は文書種別をまたいで再利用できます。
      ]
      #v(0.8em)
      #showybox(frame: showybox-focus)[
        *Focus*: 再利用可能なコールアウトを各セクション内に配置できます。
      ]
    ]
    #colbreak()
    #pop.column-box(heading: [*図表と数式*])[
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
            height: 32pt,
            dy: 5pt,
            pos: "top",
            arrow-length: 25pt,
          )[
            移流項
          ]
          $
            partial_t q + #pin("po:eq1")u dot grad q #pin("po:eq2")
            = S(q)
          $
        ],
      )
    ]
  ],
)

#v(1fr)
#poster-bottom-box()
