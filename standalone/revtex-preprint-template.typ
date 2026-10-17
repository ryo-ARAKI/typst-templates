#import "revtex-preprint.typ": revtex-preprint, appendices, outline-note, todo-note
#import "@preview/unify:0.8.1": qty
#import "@preview/physica:0.9.8"

// Uncomment to hide authoring notes in the shared manuscript.
// #let outline-note = outline-note.with(visible: false)
// #let todo-note = todo-note.with(visible: false)

#show: revtex-preprint.with(
  title: [Manuscript title],
  authors: ((name: "Author Name", affiliations: ("uni",)),),
  affiliations: ((id: "uni", text: [Department, University]),),
  abstract: [Summarize the question, approach, main result, and conclusion.],
  keywords: ("keyword",),
  mode: "read", // Use "review" for line numbers and wider leading.
)

= Introduction

#outline-note(lang: "ja")[
  研究課題を示し，先行研究との関係を整理する．
]

Introduce the research question and its motivation.
Discuss related work, for example @example2025.

= Methods

== Velocity measurements

Define the measured velocity from the particle position $x(t)$:

$ v(t) = physica.dv(x, t). $ <eq-velocity>

Use @eq-velocity to obtain the velocity samples illustrated in @fig-measurements.

#figure(
  grid(columns: (auto, auto, auto, auto, auto), column-gutter: 1em, align: horizon,
    box(inset: 6pt, stroke: 0.6pt)[$x(t)$],
    [$arrow.r$],
    box(inset: 6pt, stroke: 0.6pt)[$v_i$],
    [$arrow.r$],
    box(inset: 6pt, stroke: 0.6pt)[$overline(v)$],
  ),
  caption: [From position measurements to the mean velocity.],
  alt: "Position measurements yield velocity samples, which are averaged.",
) <fig-measurements>

== Sample mean

For $N$ velocity samples, compute the sample mean as

$ overline(v) = 1 / N sum_(i=1)^N v_i. $ <eq-mean>

=== Computational procedure

Implement the sample mean with the following procedure.

#figure(
  [
    ```
    function mean(v, N)
        s ← 0
        for i ← 1 to N do
            s ← s + v[i]
        end for
        return s / N
    end function
    ```
  ],
  kind: "algorithm",
  supplement: [Algorithm],
  placement: none,
  caption: [Compute the sample mean.],
) <alg-mean>

Refer to @alg-mean when describing the computation.

= Results

== Mean velocity

For the illustrative measurements in @tab-velocities, @eq-mean gives the mean velocity.
The mean and sample standard deviation are $qty("1.23+-0.04", "m/s")$.
The latter is defined by @eq-deviation in @app-statistics.

#todo-note(lang: "ja")[
  - 測定値を実際の結果に置き換える．
  - 既存研究との比較を追記する．
]

#figure(
  table(columns: 2, align: (left, right),
    table.hline(stroke: 0.8pt),
    table.header([Sample], [Velocity (m/s)]),
    table.hline(stroke: 0.4pt),
    [1], [1.19],
    [2], [1.23],
    [3], [1.27],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Illustrative velocity measurements.],
) <tab-velocities>

= Conclusion

Summarize the findings and their implications.

#heading(numbering: none)[Acknowledgments]

Acknowledge helpful discussions, technical assistance, and funding support.

#show: appendices

= Sample standard deviation <app-statistics>

For the $N$ measurements in @tab-velocities, the sample standard deviation is

$ s_v = sqrt(1 / (N - 1) sum_(i=1)^N (v_i - overline(v))^2). $ <eq-deviation>

#bibliography("references.bib")
