#import "../lib/presets/slide.typ": *

#let metadata = (
  text-font: "Noto Sans CJK JP",
  cjk-font: "Noto Sans CJK JP",
  title: [スライド機能カタログ],
  subtitle: [実装済み要素の一覧],
  authors: (
    (
      name: [荒木亮],
      affiliation: [Typst Templates],
      email: "ryo@example.com",
    ),
    (
      name: [山田花子],
      affiliation: [Typst Templates],
      email: "hanako@example.com",
    ),
  ),
  date: datetime.today(),
  summary: [catalog$at$slide],
  abstract: [],
  venue: [],
  logo: [],
  bibliography: none,
)

#show: slide-theme.with(config: metadata + (date-locale: "ja"))
#slide-title-slide()

== 基本レイアウト
#slide[
  このスライドでは、基本テーマ、フッター、標準的な本文レイアウトを確認できます。
]

== 質問と要約
#slide[
  #question[主張はどの順番で提示するべきか？]
  #answer[結論を先に示し、その後に必要最小限の背景だけを補います。]
  #summary-no-num[囲み枠コンポーネントは slide と poster で共通利用できます。]
]

== 2カラムレイアウト
#slide[
  左カラムには短い箇条書きを置けます。

  - preset theme
  - footer metadata
  - reusable boxes
][
  #align(center)[
    #textbox([再利用できるコールアウト], aqua)
  ]
]

== aligned list
#slide[
  `aligned-items` と `aligned-enum` は preset import だけで使えます。
  #v(0.8em)
  #aligned-items(
    (
      ([導入目的], [説明ラベルと本文をきれいに揃えたいときに使います。]),
      ([用途], [用語集、設定表、短い注記一覧に向いています。]),
    ),
  )
  #v(1.0em)
  #aligned-enum(
    (
      ([Step 123], [左列に長めの見出しを書いても本文開始位置は揃います。]),
      ([Step 2], [右列に説明や補足を置きます。]),
    ),
  )
]

== 注釈付き数式
#slide[
  #let annot(color) = (fill: color, height: 24pt, arrow-length: 18pt)
  #v(3em)
  #pinit-highlight-equation-from("sl:lhs1", "sl:lhs2", ..annot(red), height: 30pt, dy: 4pt, pos: "top", arrow-length: 25pt)[
    左辺の項
  ]
  #pinit-highlight-equation-from("sl:rhs1", "sl:rhs2", ..annot(green), height: 30pt, dy: 4pt, pos: "bottom", arrow-length: 15pt)[
    右辺の拡散項
  ]
  $
    #pin("sl:lhs1"); partial_t u #pin("sl:lhs2")
    = - grad p + #pin("sl:rhs1"); nu laplacian u #pin("sl:rhs2")
  $
]

== CeTZ
#slide[
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
