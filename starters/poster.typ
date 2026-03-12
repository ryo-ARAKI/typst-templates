#import "../lib/presets/poster.typ": *

#show: poster-theme.with(config: (
  // text-font: "Noto Sans CJK JP",  // 日本語用設定
  title: [*Poster Catalog*],
  authors: [Ryo Araki$at$Typst Templates],
  venue: [Template Showcase$at$Local Workspace, March 12, 2026],
))
#poster-title()

#columns(
  2,
  [
    #pop.column-box(heading: [*Section title*])[
      #question[Research question]
      #summary[Short summary]
    ]
    #colbreak()
    #pop.column-box(heading: [*Section title*])[
      Dummy text
    ]
  ],
)

#v(1fr)
#poster-bottom-box()
