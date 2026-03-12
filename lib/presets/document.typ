#import "@preview/physica:0.9.8": *
#import "@preview/cetz:0.4.2"
#import "@preview/unify:0.7.1": *
#import "@preview/roremu:0.1.0": roremu
#import "../core/config.typ": document-config
#import "../adapters/js.typ": *

#let setup-document(config: none) = {
  let resolved = document-config(overrides: config)
  apply-js-document(config: resolved)
  apply-document-bibliography()
  set math.equation(numbering: resolved.at("equation-numbering"))
}
