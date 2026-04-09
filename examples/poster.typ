#import "../lib/presets/poster.typ": *

#let colormath(math, color) = text(fill: color, $#math$)

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [*ポスター機能カタログ*],
  subtitle: [],
  authors: (
    (
      name: [荒木亮],
      affiliation: [Typst Templates],
      email: [`araki.ryo@example.com`],
    ),
    (
      name: [共同研究者A],
      affiliation: [Reusable Layout Group],
      email: [],
    ),
  ),
  date: [],
  summary: [],
  abstract: [],
  venue: [Template Showcase$at$Local Workspace, 2026-03-12],
  logo-relative-width: 20%,
  logo: poster-logo-strip(
    widths: (1fr, 1.4fr, 0.6fr),
    [
      #rect(
        width: 100%,
        height: 3cm,
        inset: 0.4cm,
        fill: rgb("#dce7f7"),
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
        fill: rgb("#f8efd5"),
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
        fill: rgb("#e1f3e0"),
        stroke: none,
      )[
        #align(center + horizon)[*C*]
      ]
    ],
  ),
  bibliography: "/examples/biblio.bib",
)

#show: poster-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)
#poster-title()

#columns(
  2,
  [
    #pop.column-box(heading: [*基本要素*])[
      #text(24pt)[#align(right)[共同研究者表記のサンプル]]
      #v(-0.2em)
      #question[どの部品を形式横断で再利用できますか？]
      #summary[
        question / summary box と #textbox([inline 強調], navy) は文書種別をまたいで再利用できます．
      ]
      == 参考文献
      @Tanogami2024_information
      #v(0.2em)
      行内数式も #colormath($H(Y bar X)$, blue) のように色分けできます．
      #v(0.2em)
      本文内の補足も右へ逃がせます．#h(1fr)#text(18pt)[右寄せ注記の例]
      #v(0.5em)
      #showybox(frame: showybox-focus)[
        *Focus*: 再利用可能なコールアウトを各セクション内に配置できます．
      ]
      #v(0.3em)
      #showybox(
        frame: (
          border-color: white,
          body-color: rgb("#E03C8A").lighten(70%),
        ),
      )[
        *Idea*: 実ポスターでは，注目結果やアイデア提示に色違いの `showybox` もよく使います．
      ]
    ]
    #colbreak()
    #pop.column-box(heading: [*レイアウトと図版*])[
      = 非対称 `grid`
      #grid(
        columns: (3fr, 2fr),
        gutter: 0.8em,
        [
          #rect(
            width: 100%,
            height: 15cm,
            fill: luma(235),
            stroke: gray,
          )
          #v(0.3em)
          非対称 `grid` の左側を広く取る例
        ],
        [
          #showybox(
            frame: (
              border-color: white,
              body-color: gray.lighten(65%),
            ),
          )[
            *Side note*:\
            狭い列には，図や模式図の横に置く短い補足を入れられます．
          ]
          #v(0.4em)
          #summary-no-num[
            狭い列では `summary` も短く使うと収まりやすいです．
          ]
          #v(0.4em)
          #question-no-num[
            狭い列の問いかけ例
          ]
        ],
      )
      #v(0.5em)
      = 注釈付き数式
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
      #pinit-highlight-equation-from(
        "po:eq3",
        "po:eq4",
        fill: rgb("#D95F02"),
        height: 32pt,
        dy: 5pt,
        pos: "bottom",
        arrow-length: 18pt,
      )[
        ソース項
      ]
      $
        partial_t q + #pin("po:eq1")u dot grad q #pin("po:eq2")
        = #pin("po:eq3")S(q)#pin("po:eq4")
      $
      #v(0.3em)
      == 数式中の強調
      $
        partial_t q = #textbox($S(q)$, gray)
      $
      #v(0.5em)
      = `cetz.canvas` オーバーレイ
      #align(center)[#cetz.canvas({
        import cetz.draw: *
        grid(
          (-10, -4),
          (10, 4),
          stroke: gray,
        )
        circle((0, 0), radius: .3, fill: black, stroke: none)
        rect((2.0, -1.5), (8.0, 1.5), radius: 3pt, fill: rgb("#4C78A8").transparentize(65%), stroke: none)
        rect((-4.4, 1.2), (-1.5, 2.7), fill: white, stroke: none)
        content((-2.95, 1.9), [図注])
        content((4.5, -2.3), text(fill: rgb("#4C78A8"))[注目領域])
        line((-6.0, -2.0), (1.0, 1.0), stroke: (paint: red, thickness: 0.2), mark: (end: "stealth"))
        circle((-6.0, -2.0), radius: 0.3, fill: red, stroke: none)
      })]
    ]
  ],
)

#showybox(
  frame: (
    border-color: white,
    body-color: gray.lighten(60%),
  ),
)[
  #grid(
    columns: (75%, 25%),
    gutter: 0.8em,
    [
      *まとめ*: このパネルでは，セクションをまたぐ締めの要点や今後の方針をまとめて配置できます．\
      *使い方*: 左側に本文，右側に小さな図版・ロゴ・文献メモを置くと，実ポスターの最終ブロックに近い構成になります．
    ],
    [
      #rect(
        width: 100%,
        height: 2.8cm,
        inset: 0.3cm,
        fill: rgb("#dce7f7"),
        stroke: none,
      )[
        #align(center + horizon)[*Panel*]
      ]
    ],
  )
]

#v(1fr)
#poster-bottom-box()
