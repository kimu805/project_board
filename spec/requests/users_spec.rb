require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "200 を返す" do
      get signup_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /signup" do
    let(:valid_params) do
      { user: { name: "山田太郎", email: "yamada@example.com",
                password: "password123", password_confirmation: "password123" } }
    end

    context "有効なパラメーターの場合" do
      it "ユーザーが1件増える" do
        expect { post signup_path, params: valid_params }.to change(User, :count).by(1)
      end

      it "ルートパスへリダイレクトする" do
        post signup_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "登録後にログイン状態になる（セッションが設定される）" do
        post signup_path, params: valid_params
        expect(session[:user_id]).to eq(User.last.id)
      end
    end

    context "無効なパラメーターの場合" do
      it "ユーザーが増えない" do
        expect {
          post signup_path, params: { user: { name: "", email: "bad", password: "short" } }
        }.not_to change(User, :count)
      end

      it "422 を返す" do
        post signup_path, params: { user: { name: "", email: "bad", password: "short" } }
        expect(response).to have_http_status(422)
      end
    end
  end
end
