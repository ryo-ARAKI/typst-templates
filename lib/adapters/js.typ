#import "@preview/js:0.1.3": *
#import "../core/config.typ": document-config
#import "../core/metadata.typ": authors-for-js
#import "../core/locale.typ": wrap-block-equation
#import "../components/math.typ": apply-inline-japanese-math-spacing

#let js-document(body, config: none) = {
  let resolved = document-config(overrides: config)
  show: js.with(
    lang: resolved.at("lang"),
    seriffont: resolved.at("seriffont"),
    seriffont-cjk: resolved.at("seriffont-cjk"),
    sansfont: resolved.at("sansfont"),
    sansfont-cjk: resolved.at("sansfont-cjk"),
    paper: resolved.at("paper"),
    fontsize: resolved.at("fontsize"),
    baselineskip: auto,
    textwidth: auto,
    lines-per-page: auto,
    book: false,
    cols: 1,
  )
  set par(justify: resolved.at("justify"))
  wrap-block-equation()
  apply-inline-japanese-math-spacing()
  body
}

#let citep(
  key,
  supplement: none,
  style: auto,
) = cite(
  key,
  supplement: supplement,
  form: "normal",
  style: style,
)

#let _document-author-name-text(value) = {
  if type(value) == str {
    value
  } else if type(value) == content {
    if value.func() == linebreak {
      " "
    } else if value.has("text") {
      value.text
    } else if value.has("children") {
      value.children.fold("", (result, child) => result + _document-author-name-text(child))
    } else if value.has("body") {
      _document-author-name-text(value.body)
    } else if value.has("child") {
      _document-author-name-text(value.child)
    } else {
      ""
    }
  } else {
    ""
  }
}

#let document-title(config: none) = {
  let resolved = document-config(overrides: config)
  let metadata = resolved.at("metadata")
  let authors = metadata.at("authors-js")
  // js.maketitle couples visible author content to the string-only PDF field.
  // Keep its title layout and boxtable while passing plain names to the PDF.
  set document(
    title: metadata.at("title"),
    author: metadata.at("authors")
      .map(author => _document-author-name-text(author.name))
      .filter(name => name != ""),
    keywords: (),
  )
  place(top + center, scope: "parent", float: true)[
    #set align(center)
    #v(2em)
    #text(1.7em, metadata.at("title"))
    #v(1.5em)
    #pad(
      x: 2em,
      if type(authors) == array {
        authors.map(boxtable).join("      ")
      } else {
        authors
      },
    )
    #v(1em)
    #metadata.at("date")
    #v(1.5em)
    #if metadata.at("abstract") != [] {
      block(width: 90%)[
        #set text(0.9em)
        _概要_
        #align(left)[#metadata.at("abstract")]
      ]
      v(1.5em)
    }
  ]
}

#let bibliography-list-from(
  path: "biblio.bib",
) = bibliography(
  path,
  full: true,
  style: "harvard-cite-them-right",
)
