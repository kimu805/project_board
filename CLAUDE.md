# CLAUDE.md - Project Board 開発ルール

## プロジェクト概要

SES案件管理アプリ（Rails 8.0.4 / SQLite3 / Tailwind CSS 4）
詳細はdocs/design.mdにて記載あり。

## よく使うコマンド

```bash
# サーバー起動
bin/dev

# マイグレーション
bin/rails db:migrate

# コンソール
bin/rails console

# テスト
bin/rails test

# ルーティング確認
bin/rails routes

# Lint / 静的解析
bin/rubocop
bin/brakeman

# Tailwind CSS ビルド（bin/dev に含まれるが単体実行時）
bin/rails tailwindcss:build
```

## コーディング規約

### 全般
- ロケールは日本語（`config.i18n.default_locale = :ja`）
- タイムゾーンは `Tokyo`
- rubocop-rails-omakase に準拠

### モデル
- enum は `enum :name, { key: value }, validate: true` 形式で定義
- enum の表示名は `config/locales/ja.yml` の `enums.model.attribute` で管理
- バリデーションはモデルに集約

### コントローラー
- scaffold 標準の RESTful 構成を維持
- Strong Parameters は `params.expect` を使用（Rails 8 スタイル）
- フラッシュメッセージは日本語で記述

### ビュー
- Tailwind CSS のユーティリティクラスで直接スタイリング
- カスタムカラー: `navy-600〜950`（背景）、`warm-50〜600`（アクセント）
- フォント: `font-display`（見出し）、`font-body`（本文）
- ヘルパーメソッドで表示ロジックを分離（`ProjectsHelper`）
- SVG アイコンはインラインで記述

### ファイル構成
```
app/
  models/project.rb          # モデル・バリデーション・enum定義
  controllers/projects_controller.rb
  helpers/projects_helper.rb  # 表示用ヘルパー
  views/projects/
    index.html.erb            # 一覧
    show.html.erb             # 詳細
    new.html.erb              # 新規登録
    edit.html.erb             # 編集
    _form.html.erb            # フォーム部品
config/locales/ja.yml         # 日本語翻訳・enum表示名
```
