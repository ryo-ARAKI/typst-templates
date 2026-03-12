#import "../core/tokens.typ": colors

#let textbox(text, color, baseline: 0%) = box(
  fill: color.lighten(50%),
  outset: (x: 4pt, y: 10pt),
  radius: 5pt,
  baseline: baseline,
  text,
)

#let showybox-focus = (
  border-color: white,
  body-color: colors.at("accent").lighten(60%),
)

#let showybox-advanced = (
  border-color: white,
  body-color: colors.at("advanced").lighten(80%),
)

#let labeled-box(
  body,
  label: none,
  color: gray,
  numbering: false,
  key: none,
  title-fill: rgb(0, 50, 100),
  inset: 15pt,
  radius: 10pt,
) = context {
  let counter-value = if numbering and key != none {
    let c = counter(key)
    c.step()
    c.display()
  } else {
    none
  }
  let header = if label == none {
    []
  } else if numbering and counter-value != none {
    [#label #counter-value]
  } else {
    [#label]
  }
  block(
    width: 100%,
    fill: color.lighten(70%),
    inset: inset,
    radius: radius,
    [
      #if label != none {
        set text(fill: title-fill, weight: "bold")
        header
        h(0.3em)
      }
      #set text(fill: black, weight: "regular")
      #body
    ],
  )
}

#let question = body => labeled-box(body, label: [Q.], color: colors.at("question"), numbering: true, key: "question-box")
#let answer = body => labeled-box(body, label: [A.], color: colors.at("answer"), numbering: true, key: "answer-box")
#let summary = body => labeled-box(body, label: [Sum.], color: colors.at("accent"), numbering: true, key: "summary-box")
#let question-no-num = body => labeled-box(body, label: [Q.], color: colors.at("question"))
#let answer-no-num = body => labeled-box(body, label: [A.], color: colors.at("answer"))
#let summary-no-num = body => labeled-box(body, color: colors.at("accent"))
