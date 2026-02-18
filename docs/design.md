# Project Board 設計書

## 機能仕様

### 概要

SES案件管理アプリケーション。案件の登録・閲覧・編集・削除を行い、参画状況を一覧で管理する。

### 機能一覧

| # | 機能 | 画面 | 説明 |
|---|------|------|------|
| 1 | 案件一覧表示 | `GET /` `/projects` | 全案件をカード形式で一覧表示。ステータス別の件数サマリーを表示 |
| 2 | 案件詳細表示 | `GET /projects/:id` | 案件の全情報を詳細画面で表示 |
| 3 | 案件登録 | `GET /projects/new` `POST /projects` | フォームから新規案件を登録 |
| 4 | 案件編集 | `GET /projects/:id/edit` `PATCH /projects/:id` | 既存案件の情報を編集 |
| 5 | 案件削除 | `DELETE /projects/:id` | 確認ダイアログ後に案件を削除 |

### 画面仕様

#### 案件一覧画面（index）
- ステータス別サマリー（参画中 / 参画前 / 終了 の件数）
- 企業名表示切替ボタン：ヘッダーに配置し、全案件のクライアント名の表示/非表示を一括で切り替える（デフォルト: 非表示、JavaScript で切り替え、状態は localStorage に保存）
- 案件カードに以下を表示：案件名、クライアント名（表示ON時のみ）、単価、勤務形態、期間、技術スタック
- ステータスに応じた色分けインジケーター（緑: 参画中、黄: 参画前、灰: 終了）
- ホバー時に詳細・編集・削除ボタンを表示

#### 案件詳細画面（show）
- パンくずナビゲーション
- 左カラム：案件名、クライアント名、技術スタック、参画期間
- 右カラム：月額単価、勤務形態、操作ボタン（編集・削除）

#### 案件登録・編集画面（new / edit）
- パンくずナビゲーション
- 入力フォーム（バリデーションエラー表示付き）

### バリデーション

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

---

## 構造仕様

### ER図

```
+-------------------+
|     projects      |
+-------------------+
| id          : PK  |
| name        : STR |
| client_name : STR |
| unit_price  : INT |
| work_style  : INT |  ← enum (0〜5: フル出社〜フルリモート)
| start_date  : DATE|
| end_date    : DATE|
| tech_stack  : STR |
| status      : INT |  ← enum (0: upcoming, 1: active, 2: completed)
| created_at  : TS  |
| updated_at  : TS  |
+-------------------+
```

※ 現在は単一テーブル構成。リレーションなし。

### テーブル定義

#### projects

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | integer | NO | auto | 主キー |
| name | string | YES | - | 案件名 |
| client_name | string | YES | - | クライアント名 |
| unit_price | integer | YES | - | 月額単価（円） |
| work_style | integer | YES | - | 勤務形態（enum） |
| start_date | date | YES | - | 開始日 |
| end_date | date | YES | - | 終了日 |
| tech_stack | string | YES | - | 技術スタック（カンマ区切り） |
| status | integer | YES | - | 状態（enum） |
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
