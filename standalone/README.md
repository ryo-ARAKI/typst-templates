# Standalone RevTeX preprint

[`revtex-preprint.typ`](revtex-preprint.typ) は，RevTeX preprintを参考にした，読みやすいA4・1段組の研究原稿スタイルです．
RevTeXの寸法・行数・改ページの一致は目標にせず，通常のTypst単位とフォントメトリクスを使います．
この1ファイルを原稿の隣へコピーして利用できます．
`lib/`，リポジトリのスクリプト，追加Typstパッケージ，LaTeX，外部CSLファイルは不要です．
Typst 0.15.0以降と，同梱のNew Computer Modern / New Computer Modern Mathを既定にします．

```typst
#import "revtex-preprint.typ": revtex-preprint, appendices

#show: revtex-preprint.with(
  title: [Information flow with $k$],
  pdf-title: "Information flow with k",
  authors: ((name: "Alice Example", affiliations: ("uni",)),),
  affiliations: ((id: "uni", text: [Department of Physics, Example University]),),
  abstract: [We study information flow in a simple model.],
  keywords: ("information flow", "statistical physics"),
)

= Introduction <sec-intro>

See @eq-energy and @app-check.

$ E = m c^2 $ <eq-energy>

#show: appendices

= Consistency check <app-check>

The main result is @eq-energy in @sec-intro.

$ x = 1 $ <eq-check>
```

この入力を `main.typ` に保存し，同じディレクトリで `typst compile main.typ` を実行します．
`draft` は `revtex-preprint` の別名で，同じ既定値を使います．

| 引数 | 型・既定値 | 動作 |
| --- | --- | --- |
| `title` / `pdf-title` | strまたはcontent，`[]` / `auto`またはstr，`auto` | 表示タイトルとPDF文書情報．`auto`は表示タイトルを利用 |
| `authors` / `affiliations` | 辞書の配列，`()` / `()` | 下記の構造化した著者・所属 |
| `abstract` / `keywords` | noneまたはcontent，`none` / strの配列，`()` | Abstractとキーワード．キーワードはPDF文書情報にも設定 |
| `date` | noneまたは日付成分付きdatetime，`none` | 省略時は日付表示・PDF作成日なし．指定時はISO日付を表示 |
| `mode` | `"read"` / `"review"`，`"read"` | 閲覧用／行番号と広い行送りを持つ査読用 |
| `line-numbers` / `leading` | autoまたはbool，`auto` / autoまたはlength，`auto` | 個別指定がmodeより優先 |
| `font` / `math-font` | `text.font`に渡せる値 | `"New Computer Modern"` / `"New Computer Modern Math"` |
| `font-size` / `lang` | length，`12pt` / str，`"en"` | 基本文字サイズ・文書言語 |
| `paper` / `margin` | str，`"a4"` / `page.margin`に渡せる値，`25mm` | 1段組の用紙・余白 |
| `section-numbering` | str，`"1.1"` | 見出し番号．例：`"I.1"`でローマ数字の最上位節 |
| `equation-numbering` | `"global"` / `"section"`，`"global"` | 数式の全体連番／最上位節ごとの番号 |

本文は両端揃え，連続段落の字下げは1em，ページ番号は下部中央です．
`read` は行番号なし・`leading: 0.65em`，`review` は行番号あり・`leading: 1em`です．
行番号は8pt・灰色（`#808080`）で表示します．
`leading` は `par.leading` の行間の隙間であり，固定の基線間隔ではありません．
例えば `mode: "review", line-numbers: false` で広い行送りだけを使えます．
`font: "Libertinus Serif"` などで本文書体を変更できます．

著者には必須の文字列 `name` と，任意の所属ID配列 `affiliations`（既定 `()`）を指定します．
所属辞書には文字列 `id` とcontentの `text` を指定します．
宣言順の所属番号を著者名の上付きに付け，所属段落へリンクします．
全著者が同じ1所属だけを持つ場合は所属番号を省略します．
所属なしの著者も指定でき，所属を推測して補いません．

```typst
// revtex-preprint.with(...) の引数例
  authors: (
    (name: "Alice Example", affiliations: ("uni", "lab"),
     corresponding: true, email: "alice@example.org", orcid: "0000-0000-0000-0000"),
    (name: "Bob Example", affiliations: ("lab",), corresponding: true),
    (name: "Carol Example",),
  ),
  affiliations: (
    (id: "uni", text: [Example University]),
    (id: "lab", text: [Example Laboratory]),
  ),
```

`corresponding` はbool（既定false），`email` / `orcid` は任意の文字列です．
責任著者には `*` を付け，氏名付きの連絡先欄にメール・ORCIDのリンクを表示します．
複数の責任著者や連絡先を省略した責任著者も指定できます．
この欄は本文の脚注番号を消費しません．
上記ORCIDは形式を示すダミーであり，オンライン登録やチェックディジットの検証は行いません．
重複・未知・未使用の所属IDや型違い，メール・ORCIDの形式違反は診断します．
`date` は `datetime(year: 2026, month: 10, day: 16)` のように日付成分を指定し，時刻だけの値は受け付けません．

見出しの大文字・小文字を保ち，本文は既定で1 / 1.1 / 1.1.1です．
`#show: appendices` は本文の後に1回置き，以降を末尾の付録として扱います．
付録見出しはA / A.1 / A.1.1で，題名がない場合は `#heading[]` と書きます．
`global` の数式番号は本文から付録まで `(1)`, `(2)`, … と続きます．
`section` は番号付きの最上位節ごとにリセットし，本文 `(2.1)`，付録 `(A.1)` の形式です．
見出しがローマ数字でも数式の本文prefixはアラビア数字です．
小見出し・番号なし見出しではリセットせず，番号なし数式はカウンターを消費しません．
`section` の番号付き数式は，本文・付録とも最初の番号付き最上位見出しの後に置きます．
タイトル・Abstractのdisplay数式は無番号で，本文の番号を消費しません．
Abstractのラベルは本文と同じ文字サイズの太字・中央揃えとし，本文の節見出しと区別します．
本文・付録をまたぐ前方参照・後方参照も標準の `@label` / `ref` で扱います．

数式の短い導入文をページ末に取り残さない場合は，その段落を `block(sticky: true)` で包みます．
直後の数式と同じページに保持し，数式番号・参照と図表の自動配置を維持します．

```typst
#block(width: 100%, sticky: true)[
  The directed statistic satisfies
]
$ cal(I)_(X arrow.r Y)(Delta t) >= 0. $ <eq-positive>
```

図表はnativeの `figure` と `table` を使い，別々のアラビア数字連番を付録でも継続します．
図表の配置は `auto` を既定とし，1ページ目の上端だけを避けます．
1ページ目に載る浮動図表は下端へ配置し，2ページ目以降は通常の `auto`・`top`・`bottom` を使います．
この判定はページ番号の表示を変更しても物理的なページ順に従い，`placement: top` の明示指定にも適用します．
`placement: none` を指定すれば本文中に配置できます．
図キャプションは下，表キャプションは上です．
表は既定の格子罫線を省きます．
上下端と見出し下の横罫線は，次の例のように標準の `table.hline` で指定します（既定の太さ `0.6pt`）．
セル余白は左右 `0.7em`，上下 `0.4em` です．
列見出しは `table.header` で指定し，数値列は `align` で揃えます．
`#set table(inset: ..., align: ..., stroke: ...)` でセル書式，`#set table.hline(stroke: ...)` で横罫線を変更できます．
標準の `set` ルールや要素の引数で表記・配置・参照接頭辞を変更できます．
表キャプションを下へ移す場合は `#show figure.where(kind: table): set figure.caption(position: bottom)` と指定します．

```typst
#set figure(supplement: [Fig.])
#figure(rect(width: 30mm, height: 10mm), caption: [A schematic.],
        alt: "A rectangular schematic") <fig-model>
// tableを別要素で包む場合はkindを明示する
#figure(block(table(columns: 2, align: (left, right),
  table.hline(),
  table.header([Quantity], [Value]),
  table.hline(),
  [Sample count], [1000],
  table.hline(),
)), kind: table,
        supplement: [Table], caption: [Measurements.])
See @fig-model and #ref(<fig-model>, supplement: [Diagram]).
```

引用は `@BibKey`，参考文献は `#bibliography("references.bib")` と書きます．
bibファイルのパスは原稿からの相対パスで，既定CSLはTypst組み込みの `annual-reviews-author-date` です．
本文では著者名と出版年による引用を表示します．
`#set bibliography(style: "apa")` や `bibliography` の `style` 引数で交換できます．
nativeのタイトル・見出し・数式・図表・参照を保ち，PDF文書情報，しおり，リンク，タグを出力します．
図や数式の `alt`，`table.header` も標準の書き方で指定してください．
行番号はAbstract・本文・付録・参考文献の段落を通して連番になり，タイトル・著者所属・連絡先・keywords・見出し・display数式・図表・キャプション・脚注を除外します．

恒久的な公開契約の検証は，リポジトリルートで次を実行します．
Bash，Python 3.9以降，Typst 0.15.0以降，`pdftotext`，`qpdf` が必要です．

```sh
bash script/check-revtex-preprint.sh
```

スクリプトは番号・参照，図表の配置と1ページ目上端の除外，設定上書き，著者所属，日付，CSL，PDF構造・リンク，行番号の対象・除外を確認します．
表示された一時ディレクトリに入力・PDF・診断を残し，リポジトリ外の持ち出し先で，空のpackage/cacheと `--ignore-system-fonts` を使って依存も確認します．
これは既存の `script/check-local.sh` とは独立して実行します．

Poppler 24.02.0の `pdfinfo` は，タグ付きPDF内の正常な `/Suspects false` に対して `Suspects object is wrong type (boolean)` を誤って表示します．
[Typstの調査記録](https://github.com/typst/typst/issues/7140)でも確認されている閲覧ツール側の問題です．
この警告はスタイルなしの最小文書でも再現し，`qpdf --check` は成功します．
この警告を避けるためにPDFのタグを削除する必要はありません．

[リポジトリ全体のREADME](../README.md)
