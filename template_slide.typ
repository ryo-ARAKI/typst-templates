#import "lib/presets/slide.typ": *

#setup-slide()
#slide-title-slide()

= Chapter title

==
== Simple slide

Slide contents.

== Slide with `#slide` block and animation
#slide[
  $
        f & = m a \
    pause & = m dv(v, t)
  $
]

== 日本語と数式
#slide[
  運動方程式$f=m a$は質量$m$の物体に力$f$が作用したとき物体に働く加速度$a$を記述する．
]

== Questions and summaries
#slide[
  #question[Question 1]
  #question[Question 2]
  #answer[Answer 1]
  #answer[Answer 2]
]

== Questions and summaries w/o numbering
#slide[
  #question-no-num[Question 1]
  #question-no-num[Question 2]
  #answer-no-num[Answer 1]
  #answer-no-num[Answer 2]
]

#show: appendix

#slide[
  #bibliography(
    title: "References",
    style: "annual-reviews-author-date",
    "biblio.bib",
  )
]

= Appendix

== To Do list
#slide[
  ==
  - Add template contents
  - Add animation example
]
