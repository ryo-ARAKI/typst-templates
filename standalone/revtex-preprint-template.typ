#import "revtex-preprint.typ": revtex-preprint

#show: revtex-preprint.with(
  title: [Manuscript title],
  authors: ((name: "Author Name", affiliations: ("uni",)),),
  affiliations: ((id: "uni", text: [Department, University]),),
  abstract: [Summarize the question, approach, main result, and conclusion.],
  keywords: ("keyword",),
)

= Introduction

Introduce the research question and its motivation.
Discuss related work, for example @example2025.

= Results

Present the main result and explain its significance.

$ E = m c^2 $ <eq-energy>

Refer to @eq-energy when discussing the result.

= Conclusion

Summarize the findings and their implications.

#bibliography("references.bib")
