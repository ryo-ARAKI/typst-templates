# Examples Catalog Design

## Goal

`examples/` を `document / slide / poster` ごとの機能カタログとして再導入し、このリポジトリに実装済みの部品や表現を用途単位で一覧できるようにする。

## Constraints

- `examples/` は `starters/` と同じく用途単位の 3 ファイル構成にする
- `examples/*.typ` は repo root で `typst compile --root . examples/<name>.typ` によりコンパイルできる
- 共有本体は `lib/` を使い、example のためだけの重複実装は増やさない

## Target Structure

```text
examples/
  document-jp.typ
  slide.typ
  poster.typ
```

## Catalog Contents

### Document

- 日本語文書 preset
- 章節見出し
- inline / block math
- 注釈付き数式
- bibliography

### Slide

- title slide
- standard content slide
- question / answer / summary boxes
- two-column layout
- annotated equation

### Poster

- title box
- two-column poster sections
- question / summary boxes
- highlighted callout box
- figure placeholder and bottom box

## Design Notes

- `examples/*.typ` は starter の最小例ではなく、実装機能を見せるカタログに寄せる
- 1 ファイルに用途ごとの主要機能を集約し、部品別にファイルを分けない
- サンプル本文は将来の regression fixture としても使える程度に安定させる

## Verification

- `typst compile --root . examples/document-jp.typ /tmp/...`
- `typst compile --root . examples/slide.typ /tmp/...`
- `typst compile --root . examples/poster.typ /tmp/...`
