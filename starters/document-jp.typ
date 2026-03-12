#import "../lib/presets/document.typ": *

#let catalog-config = (
  title: "文書のタイトル",
  authors: ("荒木亮", "東京理科大学", "araki.ryo@rs.tus.ac.jp"),
  abstract: [文書の要旨．],
)

#show: setup-document.with(config: catalog-config)
#document-title(config: catalog-config)

= 章

== 節

=== 小節

参考文献の引用~#citep(<Tanogami2024_information>)．

#bibliography-list-from(path: "/starters/biblio.bib")
