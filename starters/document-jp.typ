#import "../lib/presets/document.typ": *

#let metadata = (
  title: "文書のタイトル",
  subtitle: [],
  authors: (
    (
      name: "荒木亮",
      affiliation: "東京理科大学",
      email: "araki.ryo@rs.tus.ac.jp",
    ),
  ),
  date: datetime.today().display(),
  summary: [],
  abstract: [文書の要旨．],
  venue: [],
  logo: [],
  bibliography: "/starters/biblio.bib",
)

#show: setup-document.with(config: metadata)
#document-title(config: metadata)

= 章

== 節

=== 小節

参考文献の引用~#cite(<Tanogami2024_information>)．

#bibliography(metadata.bibliography, style: "harvard-cite-them-right", full: true)
