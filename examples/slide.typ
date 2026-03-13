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
      email: [],
    ),
  ),
  date: datetime.today(),
  summary: [catalog$at$slide],
  abstract: [],
  venue: [],
  logo: [],
  bibliography: none,
)

#show: slide-theme.with(config: metadata)
#slide-title-slide()

= カタログ

==
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

== 2 カラムレイアウト

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

== 注釈付き数式

#slide[
  #let annot(color) = (fill: color, height: 24pt, arrow-length: 18pt)
  #v(3em)
  #pinit-highlight-equation-from("sl:lhs1", "sl:lhs2", ..annot(red), dx: -4pt, dy: -2pt, pos: "top")[
    左辺の項
  ]
  #pinit-highlight-equation-from("sl:rhs1", "sl:rhs2", ..annot(green), dx: 0pt, dy: 4pt, pos: "bottom")[
    右辺の拡散項
  ]
  $
    #pin("sl:lhs1"); partial_t u #pin("sl:lhs2")
    = - grad p + #pin("sl:rhs1"); nu laplacian u #pin("sl:rhs2")
  $
]
