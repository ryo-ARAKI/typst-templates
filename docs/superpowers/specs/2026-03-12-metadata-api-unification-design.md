# Metadata API Unification Design

## Goal

`document / slide / poster` の metadata 指定方法を 1 つの共通 API に揃え、starter と example の設定を AI Agent が機械的に編集しやすい形にする。

## Non-Goals

- Phase 2 の外部設定ファイル対応そのもの
- 図表 component の追加
- 既存 preset の見た目変更

## Current Problems

- `document` は `authors` と `abstract` を使うが、`slide` は `author` と `summary`、`poster` は `authors` と `venue` を使っている
- metadata のキー名と型が揃っておらず、starter/example を横断編集しにくい
- `poster-title()` や `document-title()` のような helper が preset ごとに別々の期待値を持つ
- 将来の `toml` 外部設定化を考えると、まず共通の内部 schema が必要

## Unified Metadata Schema

共通 schema は次を基本とする。

```typ
(
  title: content,
  subtitle: content,
  authors: (
    (
      name: content,
      affiliation: content,
      email: content,
    ),
  ),
  date: content,
  summary: content,
  abstract: content,
  venue: content,
  logo: content,
  bibliography: "path/to/file.bib",
)
```

設計方針:

- 全用途で `authors` を使う
- `authors` は tuple of dictionaries を正規形にする
- `subtitle`, `summary`, `abstract`, `venue`, `logo`, `bibliography` は全 preset で受け付ける
- 使わないキーは preset 側で無視してよい

## Compatibility Policy

P2 では移行を安全にするため、旧キーも一時的に受け付ける。

- `slide` の `author` は `authors` に正規化する
- `document` の `authors: ("name", "affiliation", "email")` も `authors: ((name: ..., affiliation: ..., email: ...),)` に正規化する
- `poster` の `authors: [raw content]` もそのまま受けつつ、正規形があればそれを優先する

この正規化は `lib/core/config.typ` か新しい `lib/core/metadata.typ` に閉じ込める。

## Design Decisions

### 1. Normalize once in core

各 preset が独自に key 変換を持つのではなく、共通の metadata 正規化関数を `lib/core` に置く。preset は正規化済みデータだけを見る。

### 2. Keep target-specific rendering in presets/adapters

共通 schema を使っても、rendering は用途ごとに違う。`document` は `maketitle`、`slide` は `config-info(...)`、`poster` は `pop.title-box(...)` に変換する責務を維持する。

### 3. Make starter/example config literals consistent

`starters/*` と `examples/*` は同じ metadata 形を使う。これにより、新規文書の開始方法と機能カタログの見比べが容易になる。

### 4. Prefer explicit structure over free-form content

可能な範囲で `authors` を structured data に寄せる。posters/slides で複雑な見せ方が必要な場合も、まずは構造化 metadata を受けて preset 側で表示に落とす。

## Target File Changes

- Create: `lib/core/metadata.typ`
- Modify: `lib/core/config.typ`
- Modify: `lib/core/tokens.typ`
- Modify: `lib/adapters/js.typ`
- Modify: `lib/presets/document.typ`
- Modify: `lib/presets/slide.typ`
- Modify: `lib/presets/poster.typ`
- Modify: `starters/document-jp.typ`
- Modify: `starters/slide.typ`
- Modify: `starters/poster.typ`
- Modify: `examples/document-jp.typ`
- Modify: `examples/slide.typ`
- Modify: `examples/poster.typ`
- Modify: `README.md`
- Modify: `docs/architecture.md`

## Verification Strategy

- `typst compile --root . starters/document-jp.typ`
- `typst compile --root . starters/slide.typ`
- `typst compile --root . starters/poster.typ`
- `typst compile --root . examples/document-jp.typ`
- `typst compile --root . examples/slide.typ`
- `typst compile --root . examples/poster.typ`
- starter/example の config literal が全用途で同じキー集合に寄っていることを目視確認する

## Risks

- `authors` の構造化が `slide` と `poster` の既存表示ロジックにうまくはまらない可能性がある
- `js` の `maketitle` 向けに author 情報を再整形する薄い adapter が必要になる
- 旧キー互換を長く残しすぎると API が二重化する
