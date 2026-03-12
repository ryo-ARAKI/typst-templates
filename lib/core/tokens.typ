#let colors = (
  accent: rgb("#f93d6e"),
  question: rgb("#FFB11B"),
  answer: rgb("#E03C8A"),
  advanced: orange,
  muted: gray,
  navy: navy,
)

#let fonts = (
  document-serif: "Libertinus Serif",
  document-serif-cjk: "IPAexMincho",
  document-sans: "Liberation Sans",
  document-sans-cjk: "IPAexGothic",
  ui: "Cabin",
  math: "Latin Modern Math",
  cjk: "Noto Sans CJK JP",
)

#let spacing = (
  block-gap: 1.2em,
  poster-margin: 1cm,
)

#let document-defaults = (
  lang: "ja",
  paper: "a4",
  fontsize: 12pt,
  seriffont: fonts.at("document-serif"),
  seriffont-cjk: fonts.at("document-serif-cjk"),
  sansfont: fonts.at("document-sans"),
  sansfont-cjk: fonts.at("document-sans-cjk"),
  justify: false,
  equation-numbering: "(1)",
  title: "文書のタイトル",
  authors: ("荒木亮", "東京理科大学", "araki.ryo@rs.tus.ac.jp"),
  subtitle: [],
  summary: [],
  abstract: [文書の要旨．],
  venue: [],
  logo: [],
  bibliography: "/starters/biblio.bib",
  date: datetime.today().display(),
)

#let slide-defaults = (
  text-font: fonts.at("ui"),
  cjk-font: fonts.at("cjk"),
  math-font: fonts.at("math"),
  title: [Presentation title\ ...continued to the second line],
  subtitle: [Subtitle],
  author: [
    *Presenter name*$at$Institution\
    Co-author name$at$Institution
  ],
  authors: (),
  date: datetime.today(),
  institution: [],
  logo: "",
  summary: [presenter$at$subtitle],
  abstract: [],
  venue: [],
  bibliography: none,
  datetime-format: "[month repr:short]. [day], [year]",
  footer-columns: (45%, 45%, 10%),
  handout: false,
)

#let poster-defaults = (
  text-font: fonts.at("ui"),
  cjk-font: fonts.at("cjk"),
  math-font: fonts.at("math"),
  box-spacing: spacing.at("block-gap"),
  title: [*Title of the poster*],
  authors: [Presenter name$at$Institution #h(4.5cm) `email@address`],
  subtitle: [],
  date: [],
  summary: [],
  abstract: [],
  venue: [Conference name$at$~Conference venue, October 1--10, 2025],
  logo: [],
  bibliography: none,
)
