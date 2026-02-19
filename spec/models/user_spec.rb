require "rails_helper"

RSpec.describe User, type: :model do
  let(:valid_attrs) do
    { name: "山田太郎", email: "yamada@example.com", password: "password123", password_confirmation: "password123" }
  end

  def build_user(overrides = {})
    User.new(valid_attrs.merge(overrides))
  end

  # -------------------------
  # バリデーション
  # -------------------------
  describe "バリデーション" do
    it "有効な属性ですべて揃っていれば valid" do
      expect(build_user).to be_valid
    end

    describe "name" do
      it "必須：空は invalid" do
        expect(build_user(name: "")).not_to be_valid
      end

      it "必須：nil は invalid" do
        expect(build_user(name: nil)).not_to be_valid
      end
    end

    describe "email" do
      it "必須：空は invalid" do
        expect(build_user(email: "")).not_to be_valid
      end

      it "形式チェック：@ のない文字列は invalid" do
        expect(build_user(email: "invalid-email")).not_to be_valid
      end

      it "形式チェック：正しい形式は valid" do
        expect(build_user(email: "user@example.co.jp")).to be_valid
      end

      it "一意性：同じメールアドレスは invalid" do
        User.create!(valid_attrs)
        expect(build_user).not_to be_valid
      end

      it "一意性：大文字小文字を区別しない" do
        User.create!(valid_attrs)
        expect(build_user(email: "YAMADA@EXAMPLE.COM")).not_to be_valid
      end

      it "保存時に小文字へ正規化される" do
        user = build_user(email: "YAMADA@EXAMPLE.COM")
        user.save!
        expect(user.email).to eq("yamada@example.com")
      end
    end

    describe "password" do
      it "6文字未満は invalid" do
        u = build_user(password: "abc12", password_confirmation: "abc12")
        expect(u).not_to be_valid
        expect(u.errors[:password]).to be_present
      end

      it "ちょうど6文字は valid" do
        expect(build_user(password: "abc123", password_confirmation: "abc123")).to be_valid
      end

      it "password_confirmation と不一致は invalid" do
        expect(build_user(password_confirmation: "different")).not_to be_valid
      end
    end

    describe "has_secure_password" do
      it "正しいパスワードで authenticate が User を返す" do
        user = User.create!(valid_attrs)
        expect(user.authenticate("password123")).to eq(user)
      end

      it "誤ったパスワードで authenticate が false を返す" do
        user = User.create!(valid_attrs)
        expect(user.authenticate("wrong")).to be_falsey
      end
    end
  end

  # -------------------------
  # アソシエーション
  # -------------------------
  describe "アソシエーション" do
    let(:user) { User.create!(valid_attrs) }

    def build_project(user)
      user.projects.build(
        name: "案件", client_name: "テスト株式会社",
        unit_price: 500_000, work_style: :full_remote,
        start_date: Date.today, status: :active
      )
    end

    it "has_many :projects でプロジェクトを持てる" do
      project = build_project(user)
      project.save!
      expect(user.projects).to include(project)
    end

    it "dependent: :destroy でユーザー削除時にプロジェクトも削除される" do
      build_project(user).save!
      expect { user.destroy }.to change(Project, :count).by(-1)
    end
  end
end
