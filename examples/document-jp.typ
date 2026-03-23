#import "../lib/presets/document.typ": *
#import "../lib/components/math.typ": pinit-highlight-equation-from
#import "@preview/pinit:0.2.2": pin

#let metadata = (
  title: "Document Catalog",
  subtitle: [],
  authors: (
    (
      name: "Ryo Araki",
      affiliation: "Typst Templates",
      email: "ryo@example.com",
    ),
  ),
  date: datetime.today().display(),
  summary: [],
  abstract: [
    日本語文書 preset、数式、注釈、参考文献まわりの機能カタログ．
  ],
  venue: [],
  logo: [],
  bibliography: "/starters/biblio.bib",
)

#show: setup-document.with(config: metadata)
#document-title(config: metadata)

= 見出しと本文

== 日本語と数式

和文と inline math の組み合わせ $f(x) = x^2 + 1$．

#set math.equation(numbering: "(D1)")
$ integral_0^1 x^2 dif x = 1 / 3 $

== 注釈付き数式

#v(2.2em)
#pinit-highlight-equation-from(
  "doc:lhs-start",
  "doc:lhs-end",
  fill: blue,
  height: 16pt,
  dx: -2pt,
  dy: -6pt,
  pos: "top",
  arrow-length: 15pt,
)[
  Left-hand side
]
#pinit-highlight-equation-from(
  "doc:rhs-start",
  "doc:rhs-end",
  fill: green,
  height: 16pt,
  dx: -2pt,
  dy: -6pt,
  pos: "bottom",
  arrow-length: -5pt,
)[
  Right-hand side
]
$
  #pin("doc:lhs-start")a x + b #pin("doc:lhs-end")
  = #pin("doc:rhs-start")c x^2 + d #pin("doc:rhs-end")
$

== 参考文献

参考文献の引用~#citep(<Tanogami2024_information>)．

#bibliography-list-from(path: metadata.at("bibliography"))
