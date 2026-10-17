# Standalone RevTeX preprint

[`revtex-preprint.typ`](revtex-preprint.typ) は，RevTeX preprintを参考にした，読みやすいA4・1段組の研究原稿スタイルです．
この1ファイルを原稿の隣へコピーして利用できます．
Typst 0.15.0以降に対応し，本文は英語でNew Computer Modern，日本語でNoto Serif CJK JP，数式はNew Computer Modern Mathを既定のフォントにします．

## 目的と構成

原稿と参照ファイルを別のディレクトリへ持ち出しても，同じ書式・番号・参照で閲覧用・査読用のPDFを生成することを目的にします．
組版・相互参照・引用にはTypst標準の機能を使います．

| ファイル | 責務 | コンパイル時の依存先 |
| --- | --- | --- |
| [`revtex-preprint.typ`](revtex-preprint.typ) | 入力の検証，書式と番号の設定，タイトル欄の生成 | Typst標準機能・同梱フォント・CSL |
| [`revtex-preprint-template.typ`](revtex-preprint-template.typ) | 著者が編集する原稿の入口 | スタイル本体・文献ファイル・`unify 0.8.1`・`physica 0.9.8`・Noto Serif CJK JP |
| [`references.bib`](references.bib) | 原稿の `bibliography` が読み込む文献データ | なし |
| このREADME | 使い方・API・検証方法の説明 | コンパイル対象外 |

原稿の引数と本文をスタイルへ渡し，文献データとともにTypstがPDFへ組版します．
リポジトリの検証スクリプトは開発時に使い，原稿を持ち出す際は下記の3ファイルをコピーします．

## 使い方

[`revtex-preprint-template.typ`](revtex-preprint-template.typ) を原稿のひな形として使います．
`revtex-preprint.typ`，[`references.bib`](references.bib) とともに原稿ディレクトリへコピーし，タイトル・著者・所属・Abstract・本文・文献を書き換えます．
ひな形には日本語の構成メモとToDoの例を含むため，Noto Serif CJK JPを実行環境に用意します．
そのディレクトリで次を実行するとPDFを生成できます．

```sh
typst compile revtex-preprint-template.typ
```

`draft` は `revtex-preprint` の別名で，同じ既定値を使います．

## 執筆補助パッケージ

原稿ひな形は [`unify 0.8.1`](https://typst.app/universe/package/unify/) と [`physica 0.9.8`](https://typst.app/universe/package/physica/) を読み込みます．
初回コンパイルには，これらのパッケージのキャッシュ，またはダウンロード可能な環境が必要です．
スタイル本体の `revtex-preprint.typ` は外部パッケージに依存しません．

`unify` の `num`・`unit`・`qty`・`numrange`・`qtyrange` で数値・単位・不確かさ・範囲を表記できます．
`physica` は名前空間付きで使い，標準の数式記号との名前の衝突を避けます．

```typst
$ qty("1.23+-0.04", "m/s") $
$ physica.pdv(f, x) = physica.dv(g, t) $
```

## 設定

| 引数 | 既定値 | 用途 |
| --- | --- | --- |
| `title` / `pdf-title` | `[]` / `auto` | 表示タイトルとPDF文書情報．`auto`は表示タイトルを利用 |
| `authors` / `affiliations` | `()` / `()` | 著者・所属の辞書の配列 |
| `abstract` / `keywords` | `none` / `()` | Abstractのcontentとキーワードの文字列配列 |
| `date` | `none` | 日付をISO形式で表示し，PDF文書情報にも設定 |
| `mode` | `"read"` | 閲覧用 `"read"`／査読用 `"review"` |
| `line-numbers` / `leading` | `auto` / `auto` | 行番号の有無・行送り．個別指定がmodeより優先 |
| `font` / `math-font` | `auto` / `"New Computer Modern Math"` | 本文・数式のフォント |
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
`font: auto`（既定）では，`lang: "ja"` の本文は `("New Computer Modern", "Noto Serif CJK JP")`，それ以外は `"New Computer Modern"` を使います．
和文の明朝体を欧文のセリフ体に合わせ，日本語本文中の英数字もNew Computer Modernで表示します．
日本語の本文を表示する際は，実行環境に Noto Serif CJK JP が必要です．
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
level 1の節見出しは本文サイズの7/6倍の太字（既定は14pt），下位見出しは本文と同じサイズの太字（既定は12pt）にします．
番号なしのAcknowledgments・Referencesにもlevel 1の書式を適用します．
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

## 疑似プログラム

標準の `figure` に `kind: "algorithm"` と `supplement: [Algorithm]` を指定します．
表題は上，表題と本体は左揃えになり，査読用の本文行番号は付きません．
番号は図・表と独立した連番になり，ラベルへの参照は `Algorithm 1` と表示します．
本体には標準のコードブロックを使え，外部パッケージは不要です．
等幅フォントと字下げで，関数・繰り返し・返り値を表します．

````typst
#figure(
  [
    ```
    function mean(x, N)
        s ← 0
        for i ← 1 to N do
            s ← s + x[i]
        end for
        return s / N
    end function
    ```
  ],
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Compute the sample mean.],
) <alg-mean>
See @alg-mean.
````

## 構成メモ・ToDo

`outline-note` は節の役割や配置案を灰色の枠で，`todo-note` は作業メモを淡い赤色の枠で表示します．
どちらも既定では表示し，段落・箇条書き・数式を含むcontentを受け取ります．
枠内は10ptで字下げ・両端揃え・行番号を解除し，長い注記はページをまたげます．

```typst
#import "revtex-preprint.typ": outline-note, todo-note

#outline-note(lang: "ja")[
  この節の役割と，先行研究とのつながりを整理する．
]

#todo-note(lang: "ja")[
  - 比較対象の文献を追加する．
  - 数式 $x = 1$ の説明を見直す．
]
```

両方の注記は `lang: auto`（既定）で文書全体の言語設定を引き継ぎ，個別の `lang` 引数で上書きできます．
文書全体の言語は `revtex-preprint.with(lang: "en", ...)` や `#set text(lang: "en")` で指定します．
`font: auto`（既定）では，日本語は `("New Computer Modern", "Noto Serif CJK JP")`，それ以外の言語は周囲の本文フォントを使います．
ひな形の日本語注記の例を表示する際も，実行環境にこのフォントが必要です．
どちらも `font` 引数で変更でき，例えば `#outline-note(font: "IPAexGothic")[この節の役割を整理する．]` と指定します．

英語の文書に日本語の注記を混在させる場合は次のように指定します．
言語・フォントの変更は注記内だけに適用されます．

```typst
#set text(lang: "en")
#outline-note[Explain the role of this section.]
#todo-note(lang: "en")[Add a comparison with previous studies.]
#todo-note(lang: "ja")[先行研究との比較を追加する．]

// 本文は英語のまま，両方の注記をまとめて日本語にする場合．
#let outline-note = outline-note.with(lang: "ja")
#let todo-note = todo-note.with(lang: "ja")
```

個々の注記は `#todo-note(visible: false)[...]` のように隠せます．
種類ごとにまとめて隠す場合は，本文の前で次のように設定します．
非表示の注記は内容も余白も出力せず，枠内の見出しや数式も番号に影響しません．

```typst
// outline-note は表示したまま，todo-note をすべて隠す．
#let todo-note = todo-note.with(visible: false)

// 個別の指定を優先して，この注記だけ表示する．
#todo-note(visible: true)[この作業だけ共有する．]
```

`outline-note` も同じ方法で個別・種類別に表示を切り替えられます．

## アクノレッジメント

ひな形ではConclusionとReferencesの間に，番号なしのAcknowledgments節を置きます．
議論・技術支援への謝辞と研究費の情報を書き換えます．
日本語原稿では見出しを `謝辞` に変更できます．

```typst
#heading(numbering: none)[Acknowledgments]

Acknowledge helpful discussions, technical assistance, and funding support.
```

## 引用・参考文献

テンプレートには，同梱の [`references.bib`](references.bib) にある架空の文献1件を引用する例を含めています．
引用は `@BibKey`，参考文献は `#bibliography("references.bib")` と書き，bibファイルは原稿からの相対パスで指定します．
既定のCSLは `annual-reviews-author-date` で，本文では著者名と出版年を表示します．
`#set bibliography(style: "apa")` や `bibliography` の `style` 引数で交換できます．

## 検証

Bash，Python 3.9以降，Typst 0.15.0以降，`pdftotext`，`qpdf`，日本語検証用のNoto Serif CJK JPを用意し，リポジトリルートで実行します．

```sh
bash script/check-revtex-preprint.sh
```

配布するスタイル・ひな形・文献ファイルを一時ディレクトリへコピーし，ひな形の数式参照と引用を含めてコンパイルします．
ひな形は通常のパッケージ検索先・キャッシュを使います．
スタイル本体の検証では，外部パッケージの検索先・キャッシュを空にし，依存先が一時ディレクトリ内のファイルに収まることを確認します．
日本語注記の例を含むひな形と日本語注記の検証ではシステムフォントを有効にし，CJKフォントの埋め込みと日本語・英語混在を確認します．
それ以外はシステムフォントを無効にして，同梱フォントだけを使います．
同じ条件で，番号・参照，図表の配置，設定，PDF構造，行番号と入力診断も検証します．
入力・PDF・診断は，実行時に表示される一時ディレクトリで確認できます．

[リポジトリ全体のREADME](../README.md)
