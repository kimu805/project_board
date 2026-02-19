require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:user) do
    User.create!(name: "山田太郎", email: "yamada@example.com",
                 password: "password123", password_confirmation: "password123")
  end

  let(:other_user) do
    User.create!(name: "鈴木花子", email: "suzuki@example.com",
                 password: "password123", password_confirmation: "password123")
  end

  let(:project_attrs) do
    { name: "基幹システム開発", client_name: "株式会社サンプル",
      unit_price: 600_000, work_style: "full_remote",
      start_date: "2025-04-01", status: "active" }
  end

  let(:project)       { user.projects.create!(project_attrs) }
  let(:other_project) { other_user.projects.create!(project_attrs.merge(name: "他ユーザーの案件")) }

  # -------------------------
  # 未ログイン時のリダイレクト
  # -------------------------
  describe "未ログイン時" do
    it "GET /projects はログインページへリダイレクト" do
      get projects_path
      expect(response).to redirect_to(login_path)
    end

    it "GET /projects/new はログインページへリダイレクト" do
      get new_project_path
      expect(response).to redirect_to(login_path)
    end

    it "GET /projects/:id はログインページへリダイレクト" do
      get project_path(project)
      expect(response).to redirect_to(login_path)
    end

    it "POST /projects はログインページへリダイレクト" do
      post projects_path, params: { project: project_attrs }
      expect(response).to redirect_to(login_path)
    end

    it "GET /projects/:id/edit はログインページへリダイレクト" do
      get edit_project_path(project)
      expect(response).to redirect_to(login_path)
    end

    it "PATCH /projects/:id はログインページへリダイレクト" do
      patch project_path(project), params: { project: { name: "変更後" } }
      expect(response).to redirect_to(login_path)
    end

    it "DELETE /projects/:id はログインページへリダイレクト" do
      delete project_path(project)
      expect(response).to redirect_to(login_path)
    end
  end

  # -------------------------
  # ログイン済みの CRUD
  # -------------------------
  describe "ログイン済み" do
    before { login_as(user) }

    describe "GET /projects（一覧）" do
      it "200 を返す" do
        get projects_path
        expect(response).to have_http_status(200)
      end

      it "自分の案件のみ表示される（他ユーザーの案件は含まない）" do
        project        # 自分の案件（"基幹システム開発"）を作成
        other_project  # 他ユーザーの案件（"他ユーザーの案件"）を作成

        get projects_path
        expect(response.body).to include(project.name)
        expect(response.body).not_to include(other_project.name)
      end

      describe "検索・フィルタリング" do
        let!(:active_project) do
          user.projects.create!(project_attrs.merge(
            name: "参画中案件", status: "active",
            work_style: "full_remote", unit_price: 700_000
          ))
        end
        let!(:upcoming_project) do
          user.projects.create!(project_attrs.merge(
            name: "参画前案件", status: "upcoming",
            work_style: "full_onsite", unit_price: 400_000
          ))
        end

        context "keyword パラメーターがある場合" do
          it "案件名に一致する案件のみ表示される" do
            get projects_path, params: { keyword: "参画中" }
            expect(response.body).to include("参画中案件")
            expect(response.body).not_to include("参画前案件")
          end
        end

        context "status パラメーターがある場合" do
          it "指定したステータスの案件のみ表示される" do
            get projects_path, params: { status: "active" }
            expect(response.body).to include("参画中案件")
            expect(response.body).not_to include("参画前案件")
          end
        end

        context "work_style パラメーターがある場合" do
          it "指定した勤務形態の案件のみ表示される" do
            get projects_path, params: { work_style: "full_remote" }
            expect(response.body).to include("参画中案件")
            expect(response.body).not_to include("参画前案件")
          end
        end

        context "min_price パラメーターがある場合" do
          it "単価が min_price 以上の案件のみ表示される" do
            get projects_path, params: { min_price: 600_000 }
            expect(response.body).to include("参画中案件")
            expect(response.body).not_to include("参画前案件")
          end
        end

        context "max_price パラメーターがある場合" do
          it "単価が max_price 以下の案件のみ表示される" do
            get projects_path, params: { max_price: 500_000 }
            expect(response.body).to include("参画前案件")
            expect(response.body).not_to include("参画中案件")
          end
        end

        context "パラメーターがない場合" do
          it "全案件が表示される" do
            get projects_path
            expect(response.body).to include("参画中案件", "参画前案件")
          end
        end
      end
    end

    describe "GET /projects/:id（詳細）" do
      it "自分の案件は 200 を返す" do
        get project_path(project)
        expect(response).to have_http_status(200)
      end

      it "他ユーザーの案件は 404 を返す" do
        get project_path(other_project)
        expect(response).to have_http_status(404)
      end
    end

    describe "GET /projects/new（新規登録フォーム）" do
      it "200 を返す" do
        get new_project_path
        expect(response).to have_http_status(200)
      end
    end

    describe "POST /projects（新規登録）" do
      context "有効なパラメーターの場合" do
        it "案件が1件増える" do
          expect {
            post projects_path, params: { project: project_attrs }
          }.to change(Project, :count).by(1)
        end

        it "作成された案件は自分に紐付く" do
          post projects_path, params: { project: project_attrs }
          expect(Project.last.user).to eq(user)
        end

        it "詳細ページへリダイレクトする" do
          post projects_path, params: { project: project_attrs }
          expect(response).to redirect_to(project_path(Project.last))
        end
      end

      context "無効なパラメーターの場合" do
        it "案件が増えない" do
          expect {
            post projects_path, params: { project: project_attrs.merge(name: "") }
          }.not_to change(Project, :count)
        end

        it "422 を返す" do
          post projects_path, params: { project: project_attrs.merge(name: "") }
          expect(response).to have_http_status(422)
        end
      end
    end

    describe "GET /projects/:id/edit（編集フォーム）" do
      it "自分の案件は 200 を返す" do
        get edit_project_path(project)
        expect(response).to have_http_status(200)
      end

      it "他ユーザーの案件は 404 を返す" do
        get edit_project_path(other_project)
        expect(response).to have_http_status(404)
      end
    end

    describe "PATCH /projects/:id（更新）" do
      context "有効なパラメーターの場合" do
        it "案件名が更新される" do
          patch project_path(project), params: { project: { name: "更新後の案件名" } }
          expect(project.reload.name).to eq("更新後の案件名")
        end

        it "詳細ページへリダイレクトする" do
          patch project_path(project), params: { project: { name: "更新後の案件名" } }
          expect(response).to redirect_to(project_path(project))
        end
      end

      context "無効なパラメーターの場合" do
        it "422 を返す" do
          patch project_path(project), params: { project: { name: "" } }
          expect(response).to have_http_status(422)
        end
      end

      it "他ユーザーの案件は 404 を返す" do
        patch project_path(other_project), params: { project: { name: "改ざん" } }
        expect(response).to have_http_status(404)
      end
    end

    describe "メモ機能" do
      context "POST /projects（メモ付き登録）" do
        it "メモが保存される" do
          post projects_path, params: { project: project_attrs.merge(memo: "**test**") }
          expect(Project.last.memo).to eq("**test**")
        end
      end

      context "PATCH /projects/:id（メモ更新）" do
        it "メモが更新される" do
          patch project_path(project), params: { project: { memo: "# updated" } }
          expect(project.reload.memo).to eq("# updated")
        end
      end

      context "GET /projects/:id（詳細表示）" do
        it "メモがHTMLレンダリングされて表示される" do
          project.update!(memo: "**太字**")
          get project_path(project)
          expect(response.body).to include("<strong>太字</strong>")
        end

        it "メモが空の場合はプレースホルダーを表示" do
          project.update!(memo: nil)
          get project_path(project)
          expect(response.body).to include("メモを追加する")
        end
      end
    end

    describe "DELETE /projects/:id（削除）" do
      it "案件が1件減る" do
        project  # 事前に作成
        expect { delete project_path(project) }.to change(Project, :count).by(-1)
      end

      it "一覧ページへリダイレクトする" do
        delete project_path(project)
        expect(response).to redirect_to(projects_path)
      end

      it "他ユーザーの案件は 404 を返す" do
        delete project_path(other_project)
        expect(response).to have_http_status(404)
      end
    end
  end
end
