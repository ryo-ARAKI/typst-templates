# Poster Ready Citation Design

## Goal

`examples/poster.typ` と `starters/poster.typ` を、追加の下準備なしで `@key` をすぐ書ける状態にする。

## Current State

- `poster` の `@key` 引用は `bibliography` の設定に加えて `#setup-poster(config: metadata)` と `#show ref: poster-citation-ref.with(config: metadata)` が必要。
- `examples/poster.typ` と `starters/poster.typ` はまだその setup を持たず、`bibliography` も `none` のままなので、貼ってすぐ引用できない。

## Design

### Poster Example

`examples/poster.typ` を ready-to-use に更新する。

- `metadata.bibliography` を `"/examples/biblio.bib"` に設定する
- 冒頭に `#show: poster-theme.with(config: metadata)` に加えて
  `#setup-poster(config: metadata)` と
  `#show ref: poster-citation-ref.with(config: metadata)` を入れる
- 本文中に `@Tanogami2024_information` を置いた短い引用例を追加する

### Poster Starter

`starters/poster.typ` も同じ setup を最初から含める。

- `metadata.bibliography` を `"/examples/biblio.bib"` に設定する
- `#setup-poster(config: metadata)` と
  `#show ref: poster-citation-ref.with(config: metadata)` を初期状態で入れる
- starter 自体には引用本文を必須では入れないが、ユーザーがすぐ `@key` を足せる状態にする

### Documentation

README には、poster starter と example が最初から citation-ready になっていることを一文だけ補足する。

## Alternatives Considered

### Option 1: starter/example に setup を明示的に書く

採用案。現在の Typst の評価順と実装に素直で、使う側から見ても挙動が明確。

### Option 2: `setup-poster` だけで `show ref` まで完全自動化する

見た目は簡潔だが、現在の実装では評価順の都合で安定しないため採用しない。

## Testing

- `typst compile --root . examples/poster.typ /tmp/examples-poster-ready.pdf`
- `typst compile --root . starters/poster.typ /tmp/starters-poster-ready.pdf`
- `typst compile --root . examples/document-jp.typ /tmp/document-jp-ready.pdf`
- `pdftotext /tmp/examples-poster-ready.pdf -`

`examples/poster.typ` の抽出テキストで、`Tanogami and Araki, Phys. Rev. Res., 6 (2024)` が出ることを確認する。
