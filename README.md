# typst-templates

（個人用）Typstのテンプレートや便利なスニペットのまとめ

## 現在の構成

- `lib/core`: フォント、色、locale、日本語設定、共通 config
- `lib/components`: box 部品や数式注釈
- `lib/adapters`: `js` `touying` `peace-of-posters` への依存点
- `lib/presets`: `document / slide / poster` ごとの既定値
- `starters`: 新しい文書を始める最小テンプレート
- `examples`: starter を参照する簡単な例

## 共通 metadata API

`document / slide / poster` は共通の `metadata` 辞書を受け取る。

```typ
#let metadata = (
  title: [Title],
  subtitle: [Subtitle],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [ryo@example.com],
    ),
  ),
  date: datetime.today(),
  summary: [short summary],
  abstract: [abstract text],
  venue: [conference info],
  logo: [],
  bibliography: "/starters/biblio.bib",
)
```

用途ごとに使わない key は空のままでよい。

- `document`: 主に `title`, `authors`, `date`, `abstract`, `bibliography`
- `slide`: 主に `title`, `subtitle`, `authors`, `date`, `summary`, `logo`
- `poster`: 主に `title`, `authors`, `venue`, `logo`

`poster` では `bibliography` を設定した上で `@BibKey` を使うと，
本文中に `Author, Journal Abbrev., Volume (Year)` 形式の短い引用を直接出せる．
`poster` は参考文献節を自動生成しない．
そのために，poster の setup では `#show ref: poster-citation-ref.with(config: metadata)` と
`#setup-poster(config: metadata)` を入れる．
`examples/poster-column.typ` と `starters/poster-column.typ` にはこの setup が最初から入っているので，
そのまま `@BibKey` を書けば使い始められる．
雑誌名の短縮形は [`lib/core/journal-abbrev.typ`](lib/core/journal-abbrev.typ) に共通定義してある．

`slide` は `#show: slide-theme.with(config: metadata + (date-locale: "ja",))` のように
`date-locale` を追加すると，日付表示を日本語に切り替えられる．
既定値は `"en"` で，`datetime-format` を明示した場合はその指定が優先される．
title slide では各著者が `氏名 `メールアドレス` 所属` の1行形式で表示され，`authors[].email` が空ならその部分は省略される．
数式番号を参照された表示式だけに付けたい場合は，slide metadata に
`equation-numbering: "referenced-only"` と `equation-numbering-pattern: "(1)"` を追加する．
この設定は slide preset だけに効き，未ラベルの表示式は番号なし，ラベル付き表示式と `@eq` 参照は同じ番号へリンクされる．
slide で通常の引用と参考文献スライドを使う最小例は `examples/slide-bibliography.typ` にある．
この例では `metadata.bibliography` に `examples/biblio.bib` を指定し，reference slide で Typst 標準の `#bibliography(...)` を明示的に呼び出す．

### Slide speaker notes and exports

speaker notes の最小例は `examples/slide-speaker-notes.typ` にある．
通常の PDF は Typst だけでコンパイルできる．

```bash
typst compile --root . examples/slide-speaker-notes.typ /tmp/slide-speaker-notes.pdf
```

Touying は既定で pdfpc 用 metadata を埋め込むので，speaker view 用の `.pdfpc` は
必要なときだけ `typst query` で取り出す．

```bash
typst query --root . examples/slide-speaker-notes.typ --field value --one "<pdfpc-file>" > /tmp/slide-speaker-notes.pdfpc
pdfpc /tmp/slide-speaker-notes.pdf
```

PPTX や HTML が必要な場合は，外部コマンドの `touying-exporter` を任意で使う．
`pdfpc`，`polylux2pdfpc`，`touying-exporter` は通常の slide コンパイルには不要で，
このリポジトリの slide preset からも import しない．

### Column A0 poster

`poster-column` は `peace-of-posters` の column-box を使うA0ポスター用レイアウトです．
従来の2カラムまたは複数カラムのポスターを作るときは `poster-column-theme`，
`poster-column-title`，`poster-column-bottom-box` を使います．
新規作成には `starters/poster-column.typ`，機能カタログには `examples/poster-column.typ` を参照する．

### Portrait A0 takeaway poster

`poster-portrait-takeaway` は縦長A0向けに，2枚の大きな図を上下に置くポスター用レイアウトです．
`headline-takeaway` / `headline-detail` と `conclusion-takeaway` / `conclusion-detail` は必須で，
冒頭と結論の band に take-home message と本文サイズの補足説明を2行で表示します．
`upper` と `lower` は辞書で渡し，それぞれ `figure` と `caption` が必須です．
`title` は図側の見出し，`caption-title` はガイド側の見出しです．`caption-title` の既定値は `[Guide]` で，`caption-title: none` にするとガイド側の見出しを非表示にできます．
`figure-side` は `left` または `right` で，`figure-width` と `caption-width` は物理的な左右ではなく図列と caption 列の幅として指定します．未指定時は図列が広くなります．
`headline-height` と `conclusion-height` で band の高さを変えられ，残りの高さは `figure-heights` の `upper`/`lower` 比率に従って図・caption row に配分されます．
タイトルや footer は `title-style` と `footer-style` の部分 override で調整できます．`metadata.logo` と `metadata.logo-relative-width` を設定すると，タイトル・著者の右列に `poster-logo-strip` などのロゴを配置できます．`footer:` は既定で `metadata.venue` を最下部に置き，`footer: none` で非表示にできます．
`theme:` には `"default"`，`"solarized-magenta"`，`"wine"`，`"brewer-dark2-magenta"` の名前を渡します．図と layout で同じ色を共有したい場合は `poster-portrait-takeaway-palette(theme: ..., overrides: ...)` の戻り値を `palette:` に渡します．`theme:` と `palette:` は同時指定できません．

- Main + Support: メイン図 / サポート図または数式
- Method + Main: 手法の模式図 / メイン図
- Main 1 + Main 2: メイン図1 / メイン図2

```typ
#show: poster-portrait-takeaway-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)

#let palette = poster-portrait-takeaway-palette(theme: "solarized-magenta")

#poster-portrait-takeaway(
  palette: palette,
  headline-height: 10%,
  conclusion-height: 13cm,
  figure-heights: (1fr, 1.25fr),
  title-style: (
    height: 6.5%,
    title-size: 88pt,
    author-size: 46pt,
    author-email-size: 36pt,
    author-offset: -2.0cm,
    logo-gutter: 1cm,
  ),
  footer-style: (height: 1.6%, text-size: 30pt, gutter: 1cm),
  headline-takeaway: [Main result in one sentence.],
  headline-detail: [One detail line explains the scope, condition, or evidence behind it.],
  upper: (
    title: [Main figure],
    figure: [#cetz.canvas({ import cetz.draw: * })],
    caption: [What the viewer should read first.],
    caption-title: [Guide],
    figure-side: left,
  ),
  lower: (
    title: [Support figure or equation],
    figure: [#cetz.canvas({ import cetz.draw: * })],
    caption: [How this supports the claim.],
    caption-title: [Support guide],
    figure-side: right,
    figure-width: 1.3fr,
    caption-width: 0.7fr,
  ),
  conclusion-takeaway: [One concise conclusion.],
  conclusion-detail: [One detail line connects the figures to the next discussion.],
)
```

新規作成には `starters/poster-portrait-takeaway.typ`，3系統の使い分けには `examples/poster-portrait-takeaway.typ` を参照する．

### Poster logo strip

`poster` では `logo:` に `poster-logo-strip(..logos, gap:, widths:)` を渡すと，
タイトル右側の logo 領域を分割して複数の画像や content を横並びにできる．

- `gap:` はロゴ間の余白
- `widths:` は各列の幅比率
- `widths:` はロゴ数と同じ長さの tuple を渡したときだけ使われ，未指定時は等幅になる
- `logo-relative-width:` を metadata に入れると，title box 全体に対する logo 領域の幅を上書きできる
- `#poster-column-title(logo-relative-width: 22%)` と書くと，metadata より優先してその場で上書きできる

```typ
#import "../lib/presets/poster.typ": *

#let metadata = (
  title: [Poster title],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
    ),
  ),
  venue: [Conference info],
  logo-relative-width: 22%,
  logo: poster-logo-strip(
    widths: (1fr, 1.4fr, 0.8fr),
    [#image("../fig/logo-a.png")],
    [#image("../fig/logo-b.png")],
    [#image("../fig/logo-c.png")],
  ),
)
```

新しく文書を始めるときは `starters/document-jp.typ` `starters/slide.typ` `starters/poster-column.typ` `starters/poster-portrait-takeaway.typ` を入口にする．
機能カタログは `examples/document-jp.typ` `examples/slide.typ` `examples/poster-column.typ` `examples/poster-portrait-takeaway.typ` を見る．

`starters/<name>.typ` はリポジトリ root で `typst compile --root . starters/<name>.typ` を使ってコンパイルする．

### Aligned list helpers

`document / slide / poster` の各 preset からは `aligned-items` と `aligned-enum` をそのまま使える．
追加の direct import は不要で，具体例は `examples/slide.typ` と `examples/poster-column.typ` にある．

### Slide template references

Touying slide template の改善候補を検討するときに，以下のリポジトリを参照した．

- [Kgm1500/touying-template](https://gitlab.com/Kgm1500/touying-template):
  - Beamer 風 block，色 token，ヘッダー付き slide，数式番号制御，参考文献例
- [ytseis/touying-template](https://github.com/ytseis/touying-template):
  - academic presentation theme，speaker notes，export workflow，header layout，appendix example

## [git submodule](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%81%95%E3%81%BE%E3%81%96%E3%81%BE%E3%81%AA%E3%83%84%E3%83%BC%E3%83%AB-%E3%82%B5%E3%83%96%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB)を通じて利用する

以下の手順でこのリポジトリ内のテンプレートやスニペットを利用できる

```bash
# 1. Typst文書を管理するリポジトリを作成する
# 2. そのリポジトリをクローンする
gh repo clone user/repository  # GitHub CLIを利用
# 3. このリポジトリをサブモジュールとして登録する
cd repository
git submodule add git@github.com:ryo-ARAKI/typst-templates.git
# 4. 新規Typst文書を作成する
touch sample.typ
```

この`sample.typ`に以下のように記述すると，`lib/components/math.typ` で管理している `pinit-highlight-equation-from` 関数が使える．

```typ
#import "@preview/physica:0.9.4": *
#import "typst-templates/lib/components/math.typ": *

#pinit-highlight-equation-from(1, 2, height: 30pt, dx: -12pt, dy: 0pt, pos: bottom, fill: red, arrow-length: 0pt)[
  Time derivative
]
#pinit-highlight-equation-from(3, 4, height: 15pt, dx: -5pt, dy: -8pt, pos: top, fill: blue, arrow-length: 10pt)[
  Advect
]
#pinit-highlight-equation-from(5, 6, height: 30pt, dx: -8pt, dy: 0pt, pos: bottom, fill: green, arrow-length: 0pt)[
  Pressure gradient
]
#pinit-highlight-equation-from(7, 8, height: 15pt, dx: -5pt, dy: -8pt, pos: top, fill: orange, arrow-length: 30pt)[
  Viscous
]
#pinit-highlight-equation-from(9, 10, height: 15pt, dx: 0pt, dy: -8pt, pos: right, fill: aqua, arrow-length: 10pt)[
  Force
]
$
// pdv(vb(u), t) + (vb(u) dprod grad) vb(u) = - 1 / rho grad p + nu laplacian vb(u) + vb(f)
#pin(1);(partial vb(u)) / (partial t)#pin(2)
+ #pin(3);(vb(u) dprod grad) vb(u)#pin(4)
= - #pin(5);1/rho grad p#pin(6)
+ #pin(7)nu laplacian vb(u)#pin(8)
+ #pin(9)vb(f)#pin(10)
$
```

※よりきれいな出力を得るためには`pinit-highlight-equation-from`関数中の`dy-line`パラメータを調整する必要がある．
