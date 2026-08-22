#import "@preview/cjk-spacer:0.2.1": cjk-spacer
#import "@preview/physica:0.9.8": *
#import "@preview/cetz:0.5.2"
#import "@preview/unify:0.8.1": *
#import "@preview/roremu:0.1.0": roremu
#import "../core/config.typ": document-config
#import "../adapters/js.typ": *
#import "../components/aligned-list.typ": aligned-items, aligned-enum

#let setup-document(body, config: none) = {
  let resolved = document-config(overrides: config)
  show: cjk-spacer
  show: js-document.with(config: resolved)
  set math.equation(numbering: resolved.at("equation-numbering"))
  set math.accent(dotless: false)
  body
}
