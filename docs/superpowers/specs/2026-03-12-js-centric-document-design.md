# JS-Centric Document Design

## Goal

日本語 document テンプレートは Typst Universe の `js` package を最大限そのまま使い、本リポジトリでは数式・注釈・囲み枠・参考文献などの補助要素だけを追加する。

## Principles

- document の日本語フォント方針と見出し設計は `js` package に委ねる
- `lib/` 側で `js` の font / heading へ追加の regex wrapper を重ねない
- 本リポジトリの責務は `js` を壊さない補助機能に限定する

## Scope

### Keep from `js`

- `js.with(...)`
- `maketitle`
- 日本語本文と見出しの設計
- 基本的な段落・見出しレイアウト

### Add from this repository

- block math の安定化
- inline math spacing
- equation numbering
- annotated equation
- reusable boxes
- bibliography helper

## File Responsibilities

- `lib/adapters/js.typ`
  `js` package の薄い adapter。font policy を独自に上書きしない。
- `lib/presets/document.typ`
  `js` を適用したうえで document 向けの追加機能だけを有効化する。
- `starters/document-jp.typ`
  `js` ベースの最小例。
- `examples/document-jp.typ`
  `js` の標準見た目を維持しつつ、追加機能のカタログを示す。

## Verification

- `typst compile --root . starters/document-jp.typ /tmp/...`
- `typst compile --root . examples/document-jp.typ /tmp/...`
- 日本語フォントや見出しの見た目は `js` の標準に従うこと
