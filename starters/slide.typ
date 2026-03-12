#import "../lib/presets/slide.typ": *

#show: slide-theme
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
