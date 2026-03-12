#import "@preview/js:0.1.3": *
#import "@preview/enja-bib:0.1.0": *
#import bib-setting-jsme: *
#import "../core/config.typ": document-config
#import "../core/locale.typ": apply-japanese-text, wrap-block-equation
#import "../components/math.typ": apply-inline-japanese-math-spacing

#let apply-js-document(config: none) = {
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
  apply-japanese-text()
  wrap-block-equation()
  apply-inline-japanese-math-spacing()
}

#let apply-document-bibliography() = {
  show: bib-init
}

#let document-title(config: none) = {
  let resolved = document-config(overrides: config)
  maketitle(
    title: resolved.at("title"),
    authors: resolved.at("authors"),
    date: resolved.at("date"),
    abstract: resolved.at("abstract"),
  )
}

#let bibliography-list-from(path: "biblio.bib") = bibliography-list(..bib-file(read(path)))
