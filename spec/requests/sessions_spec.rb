require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) do
    User.create!(name: "山田太郎", email: "yamada@example.com",
                 password: "password123", password_confirmation: "password123")
  end

  describe "GET /login" do
    it "200 を返す" do
      get login_path
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /login" do
    context "正しい認証情報の場合" do
      it "ルートパスへリダイレクトする" do
        post login_path, params: { session: { email: user.email, password: "password123" } }
        expect(response).to redirect_to(root_path)
      end

      it "セッションに user_id が設定される" do
        post login_path, params: { session: { email: user.email, password: "password123" } }
        expect(session[:user_id]).to eq(user.id)
      end

      it "メールアドレスの大文字小文字を区別しない" do
        user  # ユーザーを事前に作成（let は遅延評価のため明示的に参照）
        post login_path, params: { session: { email: "YAMADA@EXAMPLE.COM", password: "password123" } }
        expect(response).to redirect_to(root_path)
      end
    end

    context "誤ったパスワードの場合" do
      it "422 を返す" do
        post login_path, params: { session: { email: user.email, password: "wrong" } }
        expect(response).to have_http_status(422)
      end

      it "セッションに user_id が設定されない" do
        post login_path, params: { session: { email: user.email, password: "wrong" } }
        expect(session[:user_id]).to be_nil
      end
    end

    context "存在しないメールアドレスの場合" do
      it "422 を返す" do
        post login_path, params: { session: { email: "nobody@example.com", password: "password123" } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE /logout" do
    it "ログインパスへリダイレクトする" do
      login_as(user)
      delete logout_path
      expect(response).to redirect_to(login_path)
    end

    it "セッションから user_id が削除される" do
      login_as(user)
      delete logout_path
      expect(session[:user_id]).to be_nil
    end
  end
end
