# Project Board 設計書

## 機能仕様

### 概要

SES案件管理アプリケーション。ユーザー登録・ログインによりユーザーごとに案件を管理し、参画状況を一覧で管理する。

### 機能一覧

| # | 機能 | 画面 | 説明 |
|---|------|------|------|
| 1 | ユーザー登録 | `GET /signup` `POST /users` | 名前・メールアドレス・パスワードで新規ユーザーを登録 |
| 2 | ログイン | `GET /login` `POST /sessions` | メールアドレス・パスワードで認証しセッションを開始 |
| 3 | ログアウト | `DELETE /sessions` | セッションを終了しログイン画面へリダイレクト |
| 4 | 案件一覧表示 | `GET /` `/projects` | ログインユーザーの案件をカード形式で一覧表示。ステータス別の件数サマリーを表示 |
| 5 | 案件詳細表示 | `GET /projects/:id` | 案件の全情報を詳細画面で表示 |
| 6 | 案件登録 | `GET /projects/new` `POST /projects` | フォームから新規案件を登録 |
| 7 | 案件編集 | `GET /projects/:id/edit` `PATCH /projects/:id` | 既存案件の情報を編集 |
| 8 | 案件削除 | `DELETE /projects/:id` | 確認ダイアログ後に案件を削除 |
| 9 | 検索・絞り込み | `GET /projects?keyword=...&status=...` | キーワード・ステータス・勤務形態・単価範囲でリアルタイム絞り込み |
| 10 | メモ | 案件詳細・編集画面 | 案件ごとにマークダウン形式のメモを記述・表示する |
| 11 | 参画期間タイムライン | `GET /projects/timeline` | 全案件の参画期間を横軸（時系列）のバーで可視化する |

### 画面仕様

#### ユーザー登録画面（signup）
- 入力項目：名前、メールアドレス、パスワード、パスワード確認
- 登録後はログイン状態になり案件一覧へリダイレクト
- すでにアカウントをお持ちの方向けにログインリンクを表示

#### ログイン画面（login）
- 入力項目：メールアドレス、パスワード
- 認証失敗時はエラーメッセージを表示
- 新規登録リンクを表示

#### 案件一覧画面（index）
- ステータス別サマリー（参画中 / 参画前 / 終了 の件数）
- 企業名表示切替ボタン：ヘッダーに配置し、全案件のクライアント名の表示/非表示を一括で切り替える（デフォルト: 非表示、JavaScript で切り替え、状態は localStorage に保存）
- 案件カードに以下を表示：案件名、クライアント名（表示ON時のみ）、単価、勤務形態、期間、技術スタック
- ステータスに応じた色分けインジケーター（緑: 参画中、黄: 参画前、灰: 終了）
- ホバー時に詳細・編集・削除ボタンを表示
- 検索・絞り込みフォーム（一覧上部に常時表示）：
  - キーワード検索：案件名・クライアント名の部分一致（LIKE検索）
  - ステータス絞り込み：セレクトボックスで単一選択
  - 勤務形態絞り込み：セレクトボックスで単一選択
  - 単価範囲絞り込み：下限・上限を数値入力（¥プレフィックス付き、10,000円ステップ）
  - 絞り込み中はヒット件数とクリアリンクを表示
  - 絞り込み結果が0件の場合は専用の空状態メッセージを表示

#### 案件詳細画面（show）
- パンくずナビゲーション
- 左カラム：案件名、クライアント名、技術スタック、参画期間
- 右カラム：月額単価、勤務形態、操作ボタン（編集・削除）
- メモセクション：案件情報の下部にインライン編集可能な形式で表示
  - **表示モード**（デフォルト）：マークダウンをHTMLにレンダリングして表示。メモが空の場合は「メモを追加する...」のプレースホルダーテキストを表示
  - **編集モード**：「編集」ボタンまたはメモエリアのクリックでテキストエリアに切り替わる
  - 編集モードには「保存」「キャンセル」ボタンを表示。保存は `PATCH /projects/:id` へフォーム送信
  - 表示・編集モードの切り替えはJavaScriptで行い、ページ遷移なしで操作できる

#### タイムライン画面（timeline）

- パンくずナビゲーション（案件一覧 > タイムライン）
- 横軸に年月ラベルを表示し、各案件を横バーで描画する
- 案件バーはステータスに応じた色で塗り分け（緑: 参画中、黄: 参画前、灰: 終了）
- 終了日が未設定の案件は今日を終端として描画し、バーの右端に「継続中」ラベルを表示
- バーにホバーすると案件名・期間・月額単価のツールチップを表示
- バーをクリックすると案件詳細画面へ遷移
- 案件が0件の場合は空状態メッセージと案件登録リンクを表示
- ナビゲーションバーに「タイムライン」リンクを追加

```
参画期間タイムライン

  2023年           2024年           2025年
  04  05  06  07  08  09  10  11  12  01  02  ...
  |   |   |   |   |   |   |   |   |   |   |
  [████████████████████████]              案件A（参画前）
       [████████████████████████████████] 案件B（参画中） 継続中
                        [████]           案件C（終了）
```

#### 案件登録・編集画面（new / edit）
- パンくずナビゲーション
- 入力フォーム（バリデーションエラー表示付き）
- メモ入力欄：マークダウン形式のテキストエリア（プレースホルダーでマークダウン記法を案内）

### バリデーション

#### ユーザー

| フィールド | ルール |
|-----------|--------|
| 名前 | 必須 |
| メールアドレス | 必須、形式チェック、一意 |
| パスワード | 必須、6文字以上 |

#### 案件

| フィールド | ルール |
|-----------|--------|
| 案件名 | 必須 |
| クライアント名 | 必須 |
| 単価 | 必須、数値、0以上 |
| 勤務形態 | 必須 |
| 開始日 | 必須 |
| 状態 | 必須 |
| 終了日 | 任意 |
| 技術スタック | 任意（カンマ区切り文字列） |
| メモ | 任意（マークダウン形式テキスト） |

---

## 構造仕様

### ER図

```
+-------------------+       +-------------------+
|      users        |       |     projects      |
+-------------------+       +-------------------+
| id          : PK  |1     N| id          : PK  |
| name        : STR |-------| user_id     : FK  |
| email       : STR |       | name        : STR |
| password_   : STR |       | client_name : STR |
|   digest        |       | unit_price  : INT |
| created_at  : TS  |       | work_style  : INT |  ← enum
| updated_at  : TS  |       | start_date  : DATE|
+-------------------+       | end_date    : DATE|
                            | tech_stack  : STR |
                            | status      : INT |  ← enum
                            | memo        : TEXT|
                            | created_at  : TS  |
                            | updated_at  : TS  |
                            +-------------------+
```

- users と projects は 1対多 の関係
- パスワードは bcrypt でハッシュ化して `password_digest` に保存（`has_secure_password` 利用）

### テーブル定義

#### users

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | integer | NO | auto | 主キー |
| name | string | NO | - | 名前 |
| email | string | NO | - | メールアドレス（一意） |
| password_digest | string | NO | - | パスワードハッシュ（bcrypt） |
| created_at | datetime | NO | auto | 作成日時 |
| updated_at | datetime | NO | auto | 更新日時 |

#### projects

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | integer | NO | auto | 主キー |
| user_id | integer | NO | - | 外部キー（users.id） |
| name | string | YES | - | 案件名 |
| client_name | string | YES | - | クライアント名 |
| unit_price | integer | YES | - | 月額単価（円） |
| work_style | integer | YES | - | 勤務形態（enum） |
| start_date | date | YES | - | 開始日 |
| end_date | date | YES | - | 終了日 |
| tech_stack | string | YES | - | 技術スタック（カンマ区切り） |
| status | integer | YES | - | 状態（enum） |
| memo | text | YES | - | メモ（マークダウン形式） |
| created_at | datetime | NO | auto | 作成日時 |
| updated_at | datetime | NO | auto | 更新日時 |

#### enum 定義

**work_style:**

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | full_onsite | フル出社 |
| 1 | remote_1day | 週1リモート |
| 2 | remote_2days | 週2リモート |
| 3 | remote_3days | 週3リモート |
| 4 | remote_4days | 週4リモート |
| 5 | full_remote | フルリモート |

**status:**

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | upcoming | 参画前 |
| 1 | active | 参画中 |
| 2 | completed | 終了 |

### 検索・絞り込みロジック

#### クエリパラメーター

| パラメーター | 型 | 説明 |
|------------|-----|------|
| `keyword` | string | 案件名・クライアント名の部分一致検索 |
| `status` | string | ステータスキー（`upcoming` / `active` / `completed`） |
| `work_style` | string | 勤務形態キー（`full_onsite` 〜 `full_remote`） |
| `min_price` | integer | 単価の下限（円） |
| `max_price` | integer | 単価の上限（円） |

#### モデルスコープ

`Project` モデルに以下のスコープを定義し、コントローラーでチェーンして使用する。

| スコープ | 条件 |
|---------|------|
| `search_by_keyword(keyword)` | `name LIKE ?` または `client_name LIKE ?`（空白時は全件） |
| `filter_by_status(status)` | `status = ?`（空白時は全件） |
| `filter_by_work_style(work_style)` | `work_style = ?`（空白時は全件） |
| `filter_by_unit_price(min_price:, max_price:)` | `unit_price >= min` かつ `unit_price <= max`（各値が空白の場合はその条件をスキップ） |

#### コントローラー処理

`@filtering` フラグ（絞り込みパラメーターがひとつでも存在するか）をビューに渡し、ヒット件数表示・クリアリンク・空状態メッセージの切り替えに使用する。

---

## メモ機能仕様

### 概要

案件ごとにマークダウン形式のメモを記述・表示できる。

### 実装方針

| 項目 | 内容 |
|------|------|
| データ保持 | `projects.memo`（text型）カラムに格納 |
| マークダウンレンダリング | `redcarpet` gem を使用してサーバーサイドでHTMLに変換 |
| レンダリングオプション | `autolink`, `tables`, `fenced_code_blocks`, `strikethrough` を有効化 |
| XSS対策 | `Redcarpet::Render::HTML` の `filter_html: true` オプションでサニタイズ |
| ヘルパー | `ProjectsHelper#render_markdown(text)` でレンダリング処理を共通化 |

### 使用 gem

```ruby
# Gemfile
gem "redcarpet"
```

### 詳細画面のインライン編集（show）

メモの編集は詳細画面から直接行えるようにする。編集画面（edit）への遷移は不要。

```
[ メモ                              ✏️ 編集 ]
─────────────────────────────────────────
（レンダリングされたマークダウンの表示）
```

↓ 「編集」クリック後

```
[ メモ                                    ]
─────────────────────────────────────────
┌─────────────────────────────────────┐
│ # テキスト                          │
│                                     │
│ - リスト                            │
└─────────────────────────────────────┘
        [ キャンセル ]  [ 保存する ]
```

- 表示・編集モードの切り替えは JavaScript（Stimulus または素のJS）で実装
- 保存ボタンは `PATCH /projects/:id`（既存のupdateアクション）にフォーム送信
- キャンセルは編集前の内容に戻して表示モードに切り替える

### 入力画面（new / edit）

- `memo` フィールドに `<textarea>` を配置
- プレースホルダー例：`# 見出し\n\n- リスト\n\n**太字** *斜体*`
- 高さは `rows: 10` 程度を目安とする

### 表示（show）

- `render_markdown(@project.memo)` の結果を `html_safe` で出力
- メモが空（nil または空文字）の場合は「メモを追加する...」のプレースホルダーテキストを薄く表示

---

## 参画期間タイムライン機能仕様

### 概要

全案件の `start_date` / `end_date` を横軸（時系列）に並べたガントチャート風のビューで、キャリアの流れ・空白期間・案件の重なりを視覚的に把握できる。

### ルーティング

```ruby
# config/routes.rb
resources :projects do
  get :timeline, on: :collection
end
```

### コントローラー処理

`ProjectsController#timeline` アクションに以下を実装する。

| 変数 | 内容 |
|------|------|
| `@projects` | ログインユーザーの全案件を `start_date` 昇順で取得 |
| `@timeline_start` | 全案件の最も古い `start_date`（月初に切り捨て） |
| `@timeline_end` | 全案件の最も新しい `end_date` または今日の大きい方（月末に切り上げ） |
| `@total_days` | `@timeline_end - @timeline_start`（日数） |

案件が0件の場合は `@projects` が空になるため、ビュー側で空状態メッセージを表示する。

### バー位置・幅の計算

ヘルパーメソッド `ProjectsHelper` に以下を定義し、ビューから呼び出す。

```ruby
# app/helpers/projects_helper.rb

# バーの左端位置（%）
def timeline_bar_left(project, timeline_start, total_days)
  ((project.start_date - timeline_start).to_f / total_days * 100).round(4)
end

# バーの幅（%）
def timeline_bar_width(project, timeline_start, total_days)
  effective_end = project.end_date || Date.today
  ((effective_end - project.start_date).to_f / total_days * 100).round(4)
end
```

### 年月ラベルの生成

横軸の年月ラベルもパーセント位置で配置する。

- `@timeline_start` から `@timeline_end` までの各月初日を列挙
- 各月の左端位置を `timeline_bar_left` と同じ計算式で算出
- 月ラベルは `YYYY年M月` 形式（ただし `1月` と先頭月のみ年を表示、それ以外は `M月` のみ）
- **今月のラベルは赤文字（`text-red-400` / `font-bold`）で強調表示する**

### ビュー構成

```
app/views/projects/timeline.html.erb
```

```html
<!-- タイムライン全体のコンテナ（overflow-x: auto でスクロール可） -->
<div class="timeline-container" style="position: relative; min-width: 800px;">

  <!-- 年月ラベル行 -->
  <div style="position: relative; height: 24px;">
    <!-- 各月ラベルを position: absolute で配置 -->
  </div>

  <!-- 案件バー行（1案件ごとに1行） -->
  <% @projects.each do |project| %>
    <div style="position: relative; height: 40px;">
      <!-- バー本体 -->
      <a href="<%= project_path(project) %>"
         style="position: absolute;
                left: <%= timeline_bar_left(project, @timeline_start, @total_days) %>%;
                width: <%= timeline_bar_width(project, @timeline_start, @total_days) %>%;">
        <%= project.name %>
      </a>
    </div>
  <% end %>

</div>
```

### スタイリング

Tailwind ユーティリティクラスを使用し、既存ステータス配色に揃える。

| ステータス | バーの色 |
|-----------|---------|
| active（参画中） | `bg-green-500` |
| upcoming（参画前） | `bg-yellow-400` |
| completed（終了） | `bg-gray-400` |

- コンテナには `overflow-x-auto` を付与し、案件数・期間が多い場合は横スクロールで対応
- バーには `rounded-full` でピル型にし、ホバー時に `opacity-80` で視覚フィードバック
- バー内のテキストは `truncate` でオーバーフロー処理

### ナビゲーション追加

`app/views/layouts/application.html.erb` のナビゲーションバーに「タイムライン」リンクを追加する。

```erb
<%= link_to "タイムライン", timeline_projects_path, class: "..." %>
```
