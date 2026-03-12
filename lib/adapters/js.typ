#import "@preview/js:0.1.3": *
#import "@preview/enja-bib:0.1.0": *
#import bib-setting-jsme: *
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

#let apply-document-bibliography() = {
  show: bib-init
}

#let document-title(config: none) = {
  let resolved = document-config(overrides: config)
  let metadata = resolved.at("metadata")
  maketitle(
    title: metadata.at("title"),
    authors: metadata.at("authors-js"),
    date: metadata.at("date"),
    abstract: metadata.at("abstract"),
  )
}

#let bibliography-list-from(path: "biblio.bib") = bibliography-list(..bib-file(read(path)))
