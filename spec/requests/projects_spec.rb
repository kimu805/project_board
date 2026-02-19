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
