#import "../lib/presets/slide.typ": *

#let metadata = (
  title: [Slide Catalog],
  subtitle: [Implemented features overview],
  authors: (
    (
      name: [Ryo Araki],
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
