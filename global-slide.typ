// ===========================================
// Import necessary packages
// ===========================================
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/showybox:2.0.4": showybox // Colorful and customizable boxes
#import "@preview/physica:0.9.5": * // Math constructs for science and engineering
#import "@preview/pinit:0.2.2": * // Annotation
#import "@preview/cetz:0.3.4" // Draw figures
#import "@preview/theorion:0.3.3": * // theorem environment
#import "annotated-equation.typ": pinit-highlight-equation-from // Equation annotation
#import "@preview/muchpdf:0.1.1": muchpdf // include PDF figure

// ===========================================
// General settings
// ===========================================
// Add animation to CeTZ
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
// tcolorbox equivalent
#let showybox_focus = (
  border-color: white,
  body-color: rgb("#f93d6e").lighten(60%),
)
#let showybox_advanced = (
  border-color: white,
  body-color: orange.lighten(80%),
)
// textbox
#let textbox(text, color, baseline: 0%) = box(
  fill: color.lighten(50%),
  outset: (x: 4pt, y: 10pt),
  radius: 5pt,
  baseline: baseline,
  text,
)
// Math expression with colored text
#let colormath(math, color) = text(fill: color, math)

// ===========================================
// Configuration of Summary & Question environments
// ===========================================
#let create-box-environment(name, title-text, color, state-obj, numbering: true) = {
  return body => {
    block(width: 100%, fill: color.lighten(70%), inset: 25pt, radius: 10pt, {
      set text(fill: rgb(0, 50, 100), weight: "bold")
      if numbering {
        [#title-text ]
        context {
          let state_arr = state-obj.get()
          if state_arr.contains(body) {
            state_arr.enumerate().find(it => it.at(1) == body).at(0) + 1
          } else {
            if type(state_arr) == array {
              [#{ state_arr.len() + 1 }]
            } else {
              1
            }
          }
        }
        state-obj.update(it => {
          let arr = it
          if not arr.contains(body) {
            arr.push(body)
          }
          arr
        })
      } else {
        [#title-text]
      }
      set text(fill: black, weight: "regular")
      h(0.5em)
      body
    })
  }
}

#let summary-state = state("summary-state", ())
#let question-state = state("question-state", ())

#let summary = create-box-environment("summary", "Sum.", rgb("#f93d6e"), summary-state)
#let question = create-box-environment("question", "Q.", rgb("#fece5a"), question-state)
#let summary-no-num = create-box-environment("summary", "Sum.", rgb("#f93d6e"), summary-state, numbering: false)
#let question-no-num = create-box-environment("question", "Q.", rgb("#fece5a"), question-state, numbering: false)
