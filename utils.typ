// Common utility functions

// Japanese spacing for inline math
// https://qiita.com/zr_tex8r/items/a9d82669881d8442b574
#let jp-spacing(it) = {
  let ghost = text(font: "Adobe Blank", "\u{375}") // 欧文ゴースト
  ghost
  it
  ghost
}
