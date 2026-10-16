#import "revtex-preprint.typ": revtex-preprint, outline-note, todo-note
// Numbers, units, uncertainties, and ranges.
#import "@preview/unify:0.8.1": num, unit, qty, numrange, qtyrange
// Use physica.dv / physica.pdv, etc. without shadowing native math symbols.
#import "@preview/physica:0.9.8"

#show: revtex-preprint.with(
  title: [Manuscript title],
  authors: ((name: "Author Name", affiliations: ("uni",)),),
  affiliations: ((id: "uni", text: [Department, University]),),
  abstract: [Summarize the question, approach, main result, and conclusion.],
  keywords: ("keyword",),
)

= Introduction

#outline-note(lang: "ja")[
  研究課題を示し，先行研究との関係を整理する．
]

Introduce the research question and its motivation.
Discuss related work, for example @example2025.

= Results

#todo-note(lang: "ja")[
  - 結果を示す図を追加する．
  - 既存研究との比較を追記する．
]

Present the main result and explain its significance.

$ E = m c^2 $ <eq-energy>

Refer to @eq-energy when discussing the result.

#figure(
  [
    ```
    function mean(x, N)
        s ← 0
        for i ← 1 to N do
            s ← s + x[i]
        end for
        return s / N
    end function
    ```
  ],
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Compute the sample mean.],
) <alg-mean>

Refer to @alg-mean when describing the computation.

= Conclusion

Summarize the findings and their implications.

#bibliography("references.bib")
