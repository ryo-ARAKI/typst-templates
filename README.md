# typst-templates

（個人用）Typstのテンプレートや便利なスニペットのまとめ

このリポジトリは Typst 0.15.0 以降を前提にしています。

## 現在の構成

- `lib/core`: フォント、色、locale、日本語設定、共通 config
- `lib/components`: box 部品や数式注釈
- `lib/adapters`: `js` `touying` `peace-of-posters` への依存点
- `lib/presets`: `document / slide / poster` ごとの既定値
- `starters`: 新しい文書を始める最小テンプレート
- `examples`: starter を参照する簡単な例

## フォント

テンプレートは利用環境に以下のフォントがインストールされていることを前提にします．フォントは配布・自動インストールしません．

| 用途 | 既定フォント |
| --- | --- |
| document の欧文セリフ／日本語セリフ | Libertinus Serif / IPAexMincho |
| document の欧文サンセリフ／日本語サンセリフ | Liberation Sans / IPAexGothic |
| slide・poster の本文／日本語 | Cabin / Noto Sans CJK JP |
| slide・poster の数式 | Latin Modern Math |
| slide のコード | Noto Sans Mono |
| inline 数式まわりの日本語 spacing | Adobe Blank |

設定は [`lib/core/tokens.typ`](lib/core/tokens.typ) にあり，inline 数式の spacing では [`lib/core/locale.typ`](lib/core/locale.typ) が Adobe Blank を使います．`poster-portrait-takeaway` starter は本文フォントと日本語フォントを Noto Sans CJK JP に明示的に上書きしています．利用中の環境で Typst から見えるフォントは次のコマンドで確認できます．一覧に上記の名前がなければ，その環境でのコンパイル結果は保証されません．

```bash
typst fonts
```

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
title slide では複数著者の `metadata.authors` が氏名・所属・メールアドレスの3列形式で表示され，列の先頭が著者間で揃う．`authors[].email` が空ならメールアドレス列のそのセルは空になる．
数式番号を参照された表示式だけに付けたい場合は，slide metadata に
`equation-numbering: "referenced-only"` と `equation-numbering-pattern: "(1)"` を追加する．
この設定は slide preset だけに効き，未ラベルの表示式は番号なし，ラベル付き表示式と `@eq` 参照は同じ番号へリンクされる．
引用と参考文献を使う際は `metadata.bibliography` に `examples/biblio.bib` を指定し，citation section ごとに reference slide を置いて Typst 0.15 の multiple bibliographies を示す．
各 reference slide では Typst 標準の `#bibliography(...)` を明示的に呼び出す．

`slide-theme` は `receive-body-for-new-section-slide-fn: false` を明示しているため，
`= Section` 直後の本文を section slide へ暗黙に取り込まない．
section heading の後も本文スライドは `#slide[...]` で明示する．

Touying 0.7 の `touying-get-config`，`cols(lazy-layout: true)`，`lazy-v` の利用例は
`examples/slide.typ` にある．

### Slide speaker notes and exports

speaker notes の最小例は `examples/slide-speaker-notes.typ` にある．
Touying 0.7.4 では `#speaker-note[]` は常に直前の slide に紐づく．
帰属を明確にするため，このリポジトリの例では notes を対象の `#slide[...]` 内に置く．
通常の PDF は Typst だけでコンパイルできる．

```bash
typst compile --root . examples/slide-speaker-notes.typ /tmp/slide-speaker-notes.pdf
```

Touying は既定で pdfpc 用 metadata を埋め込むので，speaker view 用の `.pdfpc` は
必要なときだけ `typst eval` で取り出す．

```bash
typst eval 'query(<pdfpc-file>).first().value' --root . --in examples/slide-speaker-notes.typ > /tmp/slide-speaker-notes.pdfpc
pdfpc /tmp/slide-speaker-notes.pdf
```

PPTX や HTML が必要な場合は，外部コマンドの `touying-exporter` を任意で使う．
`pdfpc`，`polylux2pdfpc`，`touying-exporter` は通常の slide コンパイルには不要で，
このリポジトリの slide preset からも import しない．

PDF/A や PDF/UA の smoke check が必要な場合は `typst compile --root . --pdf-standard a-2a,ua-1 ...` を使える．
PDF/UA では document title，semantic heading，math/image の `alt:` text が必要になるため，slide/poster の full compliance は文書ごとに確認する．

### Column A0 poster

`poster-column` は `peace-of-posters` の column-box を使うA0ポスター用レイアウトです．
従来の2カラムまたは複数カラムのポスターを作るときは `poster-column-theme`，
`poster-column-title`，`poster-column-bottom-box` を使います．
新規作成には `starters/poster-column.typ`，機能カタログには `examples/poster-column.typ` を参照する．

### Portrait A0 takeaway poster

`poster-portrait-takeaway` は縦長A0向けに，複数の大きな図を上下に置くポスター用レイアウトです．
`headline-takeaway` / `headline-detail` と `conclusion-takeaway` / `conclusion-detail` は必須で，
冒頭と結論の band に take-home message と本文サイズの補足説明を2行で表示します．
`sections` は2個以上の辞書を持つ配列で渡し，各 section には `figure` と `caption` が必須です．
`title` は図側の見出し，`caption-title` はガイド側の見出しです．`caption-title` の既定値は `[Guide]` で，`caption-title: none` にするとガイド側の見出しを非表示にできます．
`figure-side` は `left` または `right` で，未指定時は上から `left` / `right` 交互に配置されます．`figure-width` と `caption-width` は物理的な左右ではなく図列と caption 列の幅として指定します．未指定時は図列が広くなります．
`headline-height` と `conclusion-height` で band の高さを変えられ，残りの高さは `figure-heights` の各 section 比率に従って図・caption row に配分されます．`figure-heights` を省略すると全 section が同じ高さになります．
タイトルや footer は `title-style` と `footer-style` の部分 override で調整できます．caption 本文は `caption-style` で `text-size`，`leading`，`list-spacing`，`title-gutter` を調整できます．section 辞書内の `caption-style` はその section だけに効きます．`metadata.logo` と `metadata.logo-relative-width` を設定すると，タイトル・著者の右列に `poster-logo-strip` などのロゴを配置できます．`footer:` は既定で `metadata.venue` を最下部に置き，`footer: none` で非表示にできます．
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
  figure-heights: (1fr, 1.25fr, 0.85fr),
  title-style: (
    height: 6.5%,
    title-size: 88pt,
    author-size: 46pt,
    author-email-size: 36pt,
    author-offset: -2.0cm,
    logo-gutter: 1cm,
  ),
  caption-style: (text-size: 38pt, leading: 0.72em, list-spacing: 0.60em, title-gutter: 0.8cm),
  footer-style: (height: 1.6%, text-size: 30pt, gutter: 1cm),
  headline-takeaway: [Main result in one sentence.],
  headline-detail: [One detail line explains the scope, condition, or evidence behind it.],
  sections: (
    (
      title: [Main figure],
      figure: [#cetz.canvas({ import cetz.draw: * })],
      caption: [What the viewer should read first.],
      caption-title: [Guide],
      figure-side: left,
    ),
    (
      title: [Support figure or equation],
      figure: [#cetz.canvas({ import cetz.draw: * })],
      caption: [How this supports the claim.],
      caption-title: [Support guide],
      figure-side: right,
      figure-width: 1.3fr,
      caption-width: 0.7fr,
    ),
    (
      title: [Additional check],
      figure: [#cetz.canvas({ import cetz.draw: * })],
      caption: [Use extra rows for compact checks or comparisons.],
      caption-title: [Check],
    ),
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

`starters/<name>.typ` はリポジトリ root を compile root にして実行する．`/starters/biblio.bib` のような先頭 `/` から始まるパスは compile root を基準に解決される．

```bash
typst compile --root . starters/document-jp.typ /tmp/document-jp.pdf
```

サブモジュールとして使う場合，文書側の compile root は親リポジトリの root にする．テンプレートの import は文書ファイルからサブモジュール内のファイルへ相対指定できる．例えば親リポジトリ直下の `sample.typ` から document preset を使う場合は次のようにする．

```typ
#import "typst-templates/lib/presets/document.typ": *

#let metadata = (
  title: [Title],
  authors: (
    (name: "Author", affiliation: "Institution", email: "author@example.org"),
  ),
  bibliography: "/refs/biblio.bib",
)

#show: setup-document.with(config: metadata)
#document-title(config: metadata)

引用~#citep(<Tanogami2024_information>)．
#bibliography-list-from(path: metadata.at("bibliography"))
```

この例では文献ファイルを親リポジトリの `refs/biblio.bib` に置き，`bibliography` をその絶対パスに合わせている．サブモジュールを親側へ追加しただけでは，starter の `"/starters/biblio.bib"` は親側にある文献ファイルを指さない．自分の文書へ starter の設定を移すときは，`bibliography` を親リポジトリ root 基準のパス（例えば `"/refs/biblio.bib"`）に書き換える．`sample.typ` が親リポジトリ直下にある場合のコンパイル例は次の通り．

```bash
typst compile --root . sample.typ /tmp/sample.pdf
```

ここで示した import と文献パスは，親リポジトリ内に `typst-templates/` と `refs/biblio.bib` がある配置を前提にします．パスは実際の配置に合わせて変更してください．

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
#import "@preview/physica:0.9.8": *
#import "typst-templates/lib/components/math.typ": *

#pinit-highlight-equation-from(1, 2, height: 30pt, dx: -12pt, dy: 0pt, pos: "bottom", fill: red, arrow-length: 0pt)[
  Time derivative
]
#pinit-highlight-equation-from(3, 4, height: 15pt, dx: -5pt, dy: -8pt, pos: "top", fill: blue, arrow-length: 10pt)[
  Advect
]
#pinit-highlight-equation-from(5, 6, height: 30pt, dx: -8pt, dy: 0pt, pos: "bottom", fill: green, arrow-length: 0pt)[
  Pressure gradient
]
#pinit-highlight-equation-from(7, 8, height: 15pt, dx: -5pt, dy: -8pt, pos: "top", fill: orange, arrow-length: 30pt)[
  Viscous
]
#pinit-highlight-equation-from(9, 10, height: 15pt, dx: 0pt, dy: -8pt, pos: "right", fill: aqua, arrow-length: 10pt)[
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

※注釈ラベルの縦位置は`pinit-highlight-equation-from`関数の`line-offset-y`パラメータで調整できる．
