# CLAUDE.md

## プロジェクト概要

SES案件管理アプリ。詳細仕様は `docs/design.md` を参照。

**スタック:** Rails 8.0.4 / SQLite3 / Tailwind CSS 4 / Stimulus / Turbo / importmap

## コマンド

```bash
bin/dev                      # サーバー起動（Tailwind watch 含む）
bin/rails db:migrate         # マイグレーション実行
bin/rails console            # コンソール
bin/rails test               # テスト（RSpec: bundle exec rspec）
bin/rubocop                  # Lint
bin/brakeman                 # セキュリティ静的解析
bin/rails tailwindcss:build  # CSS 単体ビルド
```

## 実装済み機能

| 機能 | 状態 |
|------|------|
| ユーザー登録・ログイン・ログアウト | 完了 |
| 案件 CRUD（一覧・詳細・登録・編集・削除） | 完了 |
| 検索・絞り込み（キーワード・ステータス・勤務形態・単価範囲） | 完了 |
| メモ（マークダウン・インライン編集） | 完了 |
| 企業名表示切替（localStorage 永続化） | 完了 |

## 主要ファイル

```
app/
  models/
    user.rb                          # has_secure_password、バリデーション
    project.rb                       # enum、バリデーション、スコープ定義
  controllers/
    application_controller.rb        # current_user、require_login
    projects_controller.rb
    sessions_controller.rb
    users_controller.rb
  helpers/projects_helper.rb         # render_markdown、表示ロジック
  javascript/controllers/
    memo_controller.js               # メモのインライン編集（Stimulus）
    client_toggle_controller.js      # 企業名表示切替（Stimulus）
  views/projects/
    index.html.erb / show.html.erb / new.html.erb / edit.html.erb / _form.html.erb
  views/sessions/new.html.erb        # ログイン画面
  views/users/new.html.erb           # 新規登録画面
  assets/tailwind/application.css   # カスタムカラー・フォント定義
config/
  routes.rb
  locales/ja.yml                     # 日本語・enum 表示名
```

## コーディング規約

### Rails パターン
- Strong Parameters: `params.expect(project: [...])` （Rails 8 スタイル）
- ログイン制御: `before_action :require_login`（application_controller で定義）
- enum: `enum :name, { key: value }, validate: true`
- enum 表示名: `ja.yml` の `enums.モデル名.属性名.キー` で管理
- スコープはモデルに定義し、コントローラーでチェーン使用
- バリデーションはモデルに集約
- フラッシュメッセージは日本語

### ビュー・スタイリング
- Tailwind ユーティリティクラスで直接スタイリング（カスタム CSS 禁止）
- カスタムカラー: `navy-600〜950`（背景）、`warm-50〜600`（アクセント）
- フォント: `font-display`（見出し）、`font-body`（本文）
- SVG アイコンはインライン記述
- 表示ロジックは `ProjectsHelper` に切り出す

### JavaScript（Stimulus）
- 既存コントローラー: `memo`、`client-toggle`
- 新規コントローラーは `app/javascript/controllers/` に追加し `index.js` で登録

### テスト
- テストフレームワーク: RSpec（`spec/` 以下）
- 実行: `bundle exec rspec`

### ロケール・タイムゾーン
- `config.i18n.default_locale = :ja`
- タイムゾーン: `Tokyo`
- rubocop-rails-omakase に準拠
