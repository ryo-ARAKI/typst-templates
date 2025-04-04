#import "@preview/js:0.1.3": *
#import "@preview/physica:0.9.4": * // 物理学関連のコマンド
#import "@preview/cetz:0.3.2" // 図形描画
#import "@preview/unify:0.7.0": * // 単位付き数値
#import "@preview/roremu:0.1.0": roremu // 日本語のダミー文書

// 日本語文書の設定
#show: js.with(
  lang: "ja",
  seriffont: "Libertinus Serif",
  seriffont-cjk: "IPAexMincho",
  sansfont: "Liberation Sans",
  sansfont-cjk: "IPAexGothic",
  paper: "a4",
  fontsize: 12pt,
  baselineskip: auto,
  textwidth: auto,
  lines-per-page: auto,
  book: false,
  cols: 1,
)
// 均等割付けをoffにする
#set par(justify: false)
// ソースコード中で改行した際に半角スペースを入れない
// https://github.com/typst/typst/issues/792#issuecomment-2302531474
#let cjkre = regex("[ ]*([\p{Han}\p{Hiragana}\p{Katakana}]+(?:[,\(\)][ ]*[\p{Han}\p{Hiragana}\p{Katakana}]+)*)[ ]*")
#show cjkre: it => it.text.match(cjkre).captures.at(0)
// 独立行数式を#box[]に入れ，直後の行にインデントがついてしまうのを防ぐ
// https://github.com/typst/typst/issues/3206
#show math.equation.where(block: true): it => box[#it]
// 和欧文間空白
// https://qiita.com/zr_tex8r/items/a9d82669881d8442b574
#show math.equation.where(block: false): it => {
  let ghost = text(font: "Adobe Blank", "\u{375}") // 欧文ゴースト
  ghost
  it
  ghost
}

// 参考文献
#import "@preview/enja-bib:0.1.0": *
#import bib-setting-jsme: *
#show: bib-init

// タイトル
#maketitle(
  title: "文書のタイトル",
  authors: ("荒木亮", "東京理科大学", "araki.ryo@rs.tus.ac.jp"),
  date: datetime.today().display(),
  abstract: [
    文書の要旨．
  ],
)

// 数式番号
#set math.equation(numbering: "(1)")

= 章

== 節

=== 小節

参考文献の引用~#citep(<Tanogami2024_information>)．

#bibliography-list(..bib-file(read("biblio.bib")))
