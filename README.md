# typst-templates

（個人用）Typstのテンプレートや便利なスニペットのまとめ

## 現在の構成

- `lib/core`: フォント、色、locale、日本語設定、共通 config
- `lib/components`: box 部品や数式注釈
- `lib/adapters`: `js` `touying` `peace-of-posters` への依存点
- `lib/presets`: `document / slide / poster` ごとの既定値
- `starters`: 新しい文書を始める最小テンプレート
- `examples`: starter を参照する簡単な例

新しく文書を始めるときは `starters/document-jp.typ` `starters/slide.typ` `starters/poster.typ` を入口にする．
既存の `template_*.typ` は互換用の完成形サンプルとして残している．

`starters/` 配下を直接コンパイルするときは，リポジトリ直下で `typst compile --root . starters/<name>.typ` を使う．

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

この`sample.typ`に以下のように記述すると，[annotated-equation.typ](https://github.com/ryo-ARAKI/typst-templates/blob/main/annotated-equation.typ)で管理している`pinit-highlight-equation-from`関数が使える．

```typ
#import "@preview/physica:0.9.4": *
#import "typst-templates/annotated-equation.typ": *

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
