#import "../lib/presets/slide.typ": *

#show: slide-theme.with(config: (
  // text-font: "Noto Sans CJK JP",  // 日本語用設定
  title: [Slide Catalog],
  subtitle: [Implemented features overview],
  author: [Ryo Araki$at$Typst Templates],
  summary: [catalog$at$slide],
))
#slide-title-slide()

= Chapter title

==
== Simple slide

#slide[
  Slide contents.
]

== Questions and summaries

#slide[
  #question[Question 1]
  #answer[Answer 1]
  #summary-no-num[Important text]
]
