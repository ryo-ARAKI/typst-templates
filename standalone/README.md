# Standalone RevTeX preprint

[`revtex-preprint.typ`](revtex-preprint.typ) は，RevTeX preprintを参考にした，読みやすいA4・1段組の研究原稿スタイルです．
この1ファイルを原稿の隣へコピーして利用できます．
Typst 0.15.0以降に対応し，同梱のNew Computer Modern / New Computer Modern Mathを既定のフォントにします．

## 使い方

[`revtex-preprint-template.typ`](revtex-preprint-template.typ) を原稿のひな形として使います．
`revtex-preprint.typ`，[`references.bib`](references.bib) とともに原稿ディレクトリへコピーし，タイトル・著者・所属・Abstract・本文・文献を書き換えます．
そのディレクトリで次を実行するとPDFを生成できます．

```sh
typst compile revtex-preprint-template.typ
```

`draft` は `revtex-preprint` の別名で，同じ既定値を使います．

## 設定

| 引数 | 既定値 | 用途 |
| --- | --- | --- |
| `title` / `pdf-title` | `[]` / `auto` | 表示タイトルとPDF文書情報．`auto`は表示タイトルを利用 |
| `authors` / `affiliations` | `()` / `()` | 著者・所属の辞書の配列 |
| `abstract` / `keywords` | `none` / `()` | Abstractのcontentとキーワードの文字列配列 |
| `date` | `none` | 日付をISO形式で表示し，PDF文書情報にも設定 |
| `mode` | `"read"` | 閲覧用 `"read"`／査読用 `"review"` |
| `line-numbers` / `leading` | `auto` / `auto` | 行番号の有無・行送り．個別指定がmodeより優先 |
| `font` / `math-font` | `"New Computer Modern"` / `"New Computer Modern Math"` | 本文・数式のフォント |
| `font-size` / `lang` | `12pt` / `"en"` | 基本文字サイズ・文書言語 |
| `paper` / `margin` | `"a4"` / `25mm` | 用紙・余白 |
| `section-numbering` | `"1.1"` | 見出し番号．例：`"I.1"`でローマ数字の最上位節 |
| `equation-numbering` | `"global"` | 数式の全体連番 `"global"`／節ごとの番号 `"section"` |

本文は両端揃え，連続段落の字下げは1em，ページ番号は下部中央です．
`read` は `leading: 0.65em`，`review` は `leading: 1em` と8pt・灰色（`#808080`）の行番号を使います．
行番号はAbstract・本文・付録・参考文献の段落を通して連番になります．
`leading` は `par.leading` の行間の隙間を指定します．
例えば `mode: "review", line-numbers: false` で広い行送りだけを使えます．
`font: "Libertinus Serif"` などで本文書体を変更できます．
`date` は `datetime(year: 2026, month: 10, day: 16)` のように指定します．

## 著者・所属

著者の `name` に氏名，`affiliations` に所属IDの配列を指定します．
所属の `id` にID，`text` に所属名のcontentを指定します．
所属番号は宣言順に付き，著者名から所属段落へリンクします．

```typst
// revtex-preprint.with(...) の引数例
  authors: (
    (name: "Alice Example", affiliations: ("uni", "lab"),
     corresponding: true, email: "alice@example.org"),
    (name: "Bob Example", affiliations: ("lab",)),
  ),
  affiliations: (
    (id: "uni", text: [Example University]),
    (id: "lab", text: [Example Laboratory]),
  ),
```

責任著者には `corresponding: true` を指定すると `*` が付きます．
`email` と `orcid` は任意の文字列で，氏名付きの連絡先欄にリンクを表示します．

## 見出し・数式

見出しの大文字・小文字を保ち，本文は既定で1 / 1.1 / 1.1.1です．
`#show: appendices` は本文の後に1回置き，以降を末尾の付録として扱います．
付録見出しはA / A.1 / A.1.1です．
`global` の数式番号は本文から付録まで `(1)`, `(2)`, … と続きます．
`section` は番号付きの最上位節ごとにリセットし，本文 `(2.1)`，付録 `(A.1)` の形式です．
`section` の番号付き数式は，本文・付録とも最初の番号付き最上位見出しの後に置きます．
Abstractのラベルは本文と同じ文字サイズの太字・中央揃えとし，本文の節見出しと区別します．
数式や見出しの参照には `@label` / `ref` を使います．

数式の短い導入文を `block(sticky: true)` で包むと，直後の数式と同じページに保持します．

```typst
#block(width: 100%, sticky: true)[
  The directed statistic satisfies
]
$ cal(I)_(X arrow.r Y)(Delta t) >= 0. $ <eq-positive>
```

## 図表

図表は標準の `figure` と `table` を使い，それぞれの連番を付録まで継続します．
配置は既定の `auto` で自動調整し，1ページ目の浮動図表は下端に配置します．
`placement: none` で本文中の配置を指定できます．
図キャプションは下，表キャプションは上です．
表は `table.hline`（既定の太さ `0.6pt`）で上下端と見出し下に横罫線を引く三線表を基本にします．
列見出しは `table.header` で指定し，数値列は `align` で揃えます．
セル余白は左右 `0.7em`，上下 `0.4em` です．

```typst
#figure(rect(width: 30mm, height: 10mm), caption: [A schematic.],
        alt: "A rectangular schematic") <fig-model>
#figure(table(columns: 2, align: (left, right),
  table.hline(),
  table.header([Quantity], [Value]),
  table.hline(),
  [Sample count], [1000],
  table.hline(),
), caption: [Measurements.]) <tab-measurements>
See @fig-model and @tab-measurements.
```

表記や配置は標準の `set` / `show` ルールや要素の引数で変更できます．

## 引用・参考文献

テンプレートには，同梱の [`references.bib`](references.bib) にある架空の文献1件を引用する例を含めています．
引用は `@BibKey`，参考文献は `#bibliography("references.bib")` と書き，bibファイルは原稿からの相対パスで指定します．
既定のCSLは `annual-reviews-author-date` で，本文では著者名と出版年を表示します．
`#set bibliography(style: "apa")` や `bibliography` の `style` 引数で交換できます．

## 検証

Bash，Python 3.9以降，Typst 0.15.0以降，`pdftotext`，`qpdf` を用意し，リポジトリルートで実行します．

```sh
bash script/check-revtex-preprint.sh
```

番号・参照，図表の配置，設定，PDF構造，行番号と単体での利用を検証します．
入力・PDF・診断は，実行時に表示される一時ディレクトリで確認できます．

[リポジトリ全体のREADME](../README.md)
