# P1 Common Templates Design

## Goal

`document / slide / poster` の 3 完成形テンプレートを維持しながら、共通設定と共通部品を分離し、依存更新と見た目調整を 1 か所で扱えるようにする。

## Non-Goals

- Universe 向けの配布用 package 化
- 見た目バリエーションの大量追加
- 新しい文書種別の追加

## Current Problems

- 日本語設定、数式フォント、和欧文間空白がテンプレートごとに重複している
- `question / answer / summary / textbox / annotated equation` が用途別ファイルに散っている
- `Touying` と `peace-of-posters` への依存が完成形テンプレートに直接書かれている
- `template_slide.typ` は `state` ベースの番号付けにより `layout did not converge within 5 attempts` 警告が出る
- サンプル本文とテンプレート定義が同じファイルにあり、保守対象が肥大化している

## Target Structure

```text
lib/
  core/
    config.typ
    locale.typ
    tokens.typ
  components/
    boxes.typ
    math.typ
  adapters/
    js.typ
    touying.typ
    peace-of-posters.typ
  presets/
    document.typ
    slide.typ
    poster.typ
starters/
  document-jp.typ
  slide.typ
  poster.typ
examples/
  document/
  slide/
  poster/
docs/
  architecture.md
  dependencies.md
```

## Design Decisions

### 1. Core layer centralizes visual and locale defaults

`lib/core` にフォント、色、余白、日付書式、日本語処理、共通設定辞書を置く。ここは外部 package 依存を最小化し、用途ごとの違いは preset から渡す。

### 2. Reusable components become usage-agnostic

`question / answer / summary / textbox / annotated equation` は `lib/components` に移す。各 component は色やラベルを引数で上書きできる API にする。

### 3. External packages are isolated behind adapters

`js` `touying` `peace-of-posters` に依存するコードは `lib/adapters` に閉じ込める。完成形テンプレートと starter は adapter を直接触らず、preset を通す。

### 4. Presets own target-specific defaults

`document / slide / poster` ごとの既定値は `lib/presets` で定義する。preset は `config` 辞書を受けて、必要に応じて利用側が細かく上書きできるようにする。

### 5. Starters become thin entrypoints

`starters` は新しい文書を始めるための最小ファイルとし、本文例は `examples` に分離する。利用者は starter をコピーするか submodule 越しに import する。

### 6. Slide box numbering drops state-based convergence risk

`global-slide.typ` の `state` ベース番号付けは収束警告の原因になっている可能性が高い。P1 では UI 部品を `figure(kind: "...")` ベースの counter へ寄せ、安定した番号付けに置き換える。

## Migration Mapping

- `utils.typ` -> `lib/core/locale.typ`
- `annotated-equation.typ` -> `lib/components/math.typ`
- `global-slide.typ` -> `lib/components/boxes.typ` と `lib/adapters/touying.typ`
- `template_document_jp.typ` -> `lib/presets/document.typ` と `starters/document-jp.typ`
- `template_slide.typ` -> `lib/presets/slide.typ` と `starters/slide.typ`
- `template_poster.typ` -> `lib/presets/poster.typ` と `starters/poster.typ`

## Verification Strategy

- `typst compile starters/document-jp.typ /tmp/...`
- `typst compile starters/slide.typ /tmp/...`
- `typst compile starters/poster.typ /tmp/...`
- 収束警告が `slide` で出ないことを確認する
- 旧テンプレートファイルは互換 import として残すか、preset/starter への移行を示す薄いラッパにする

## Risks

- package API 変更により adapter 側の修正が必要になる
- `question / answer / summary` の番号付け仕様を変更すると見た目が微妙に変わる
- 日本語フォントがローカル環境依存のため、共通化の際に要求フォントを明示する必要がある

## Phase Scope

P1 では次を実施する。

- 共通テーマ層の新設
- 共通 UI 部品化
- adapter 層の新設
- 完成形テンプレートの薄型化
- 依存台帳の作成
