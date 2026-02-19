require "rails_helper"

RSpec.describe Project, type: :model do
  let(:user) do
    User.create!(name: "テスト", email: "test@example.com",
                 password: "password123", password_confirmation: "password123")
  end

  let(:valid_attrs) do
    {
      user: user,
      name: "基幹システム開発",
      client_name: "株式会社サンプル",
      unit_price: 600_000,
      work_style: :full_remote,
      start_date: Date.new(2025, 4, 1),
      status: :active
    }
  end

  def build_project(overrides = {})
    Project.new(valid_attrs.merge(overrides))
  end

  # -------------------------
  # バリデーション
  # -------------------------
  describe "バリデーション" do
    it "必須項目がすべて揃っていれば valid" do
      expect(build_project).to be_valid
    end

    describe "name（案件名）" do
      it "必須：空は invalid" do
        expect(build_project(name: "")).not_to be_valid
      end

      it "必須：nil は invalid" do
        expect(build_project(name: nil)).not_to be_valid
      end
    end

    describe "client_name（クライアント名）" do
      it "必須：空は invalid" do
        expect(build_project(client_name: "")).not_to be_valid
      end

      it "必須：nil は invalid" do
        expect(build_project(client_name: nil)).not_to be_valid
      end
    end

    describe "unit_price（単価）" do
      it "必須：nil は invalid" do
        expect(build_project(unit_price: nil)).not_to be_valid
      end

      it "0 は valid（下限値）" do
        expect(build_project(unit_price: 0)).to be_valid
      end

      it "負の値は invalid" do
        p = build_project(unit_price: -1)
        expect(p).not_to be_valid
        expect(p.errors[:unit_price]).to be_present
      end

      it "正の値は valid" do
        expect(build_project(unit_price: 600_000)).to be_valid
      end

      it "数値以外は invalid" do
        expect(build_project(unit_price: "abc")).not_to be_valid
      end
    end

    describe "work_style（勤務形態）" do
      it "必須：nil は invalid" do
        expect(build_project(work_style: nil)).not_to be_valid
      end

      it "定義済み enum 値は valid" do
        %i[full_onsite remote_1day remote_2days remote_3days remote_4days full_remote].each do |style|
          expect(build_project(work_style: style)).to be_valid, "work_style: #{style} は valid であるべき"
        end
      end
    end

    describe "start_date（開始日）" do
      it "必須：nil は invalid" do
        expect(build_project(start_date: nil)).not_to be_valid
      end
    end

    describe "status（状態）" do
      it "必須：nil は invalid" do
        expect(build_project(status: nil)).not_to be_valid
      end

      it "定義済み enum 値は valid" do
        %i[upcoming active completed].each do |s|
          expect(build_project(status: s)).to be_valid, "status: #{s} は valid であるべき"
        end
      end
    end

    describe "end_date（終了日）" do
      it "任意：nil でも valid" do
        expect(build_project(end_date: nil)).to be_valid
      end

      it "日付を指定しても valid" do
        expect(build_project(end_date: Date.new(2025, 9, 30))).to be_valid
      end
    end

    describe "tech_stack（技術スタック）" do
      it "任意：nil でも valid" do
        expect(build_project(tech_stack: nil)).to be_valid
      end

      it "任意：空文字でも valid" do
        expect(build_project(tech_stack: "")).to be_valid
      end

      it "カンマ区切り文字列を保存できる" do
        p = build_project(tech_stack: "Ruby, Rails, PostgreSQL")
        p.save!
        expect(p.tech_stack).to eq("Ruby, Rails, PostgreSQL")
      end
    end
  end

  # -------------------------
  # enum 定義
  # -------------------------
  describe "enum :work_style" do
    it "full_onsite = 0" do
      expect(Project.work_styles["full_onsite"]).to eq(0)
    end

    it "remote_1day = 1" do
      expect(Project.work_styles["remote_1day"]).to eq(1)
    end

    it "remote_2days = 2" do
      expect(Project.work_styles["remote_2days"]).to eq(2)
    end

    it "remote_3days = 3" do
      expect(Project.work_styles["remote_3days"]).to eq(3)
    end

    it "remote_4days = 4" do
      expect(Project.work_styles["remote_4days"]).to eq(4)
    end

    it "full_remote = 5" do
      expect(Project.work_styles["full_remote"]).to eq(5)
    end
  end

  describe "enum :status" do
    it "upcoming = 0" do
      expect(Project.statuses["upcoming"]).to eq(0)
    end

    it "active = 1" do
      expect(Project.statuses["active"]).to eq(1)
    end

    it "completed = 2" do
      expect(Project.statuses["completed"]).to eq(2)
    end
  end

  # -------------------------
  # アソシエーション
  # -------------------------
  describe "アソシエーション" do
    it "belongs_to :user - user_id なしは invalid" do
      p = Project.new(valid_attrs.except(:user))
      expect(p).not_to be_valid
    end

    it "belongs_to :user - User と紐付けられる" do
      p = build_project
      p.save!
      expect(p.user).to eq(user)
    end
  end

  # -------------------------
  # 検索スコープ
  # -------------------------
  describe ".search_by_keyword" do
    let!(:project_a) { user.projects.create!(valid_attrs.merge(name: "基幹システム開発", client_name: "株式会社ABC")) }
    let!(:project_b) { user.projects.create!(valid_attrs.merge(name: "ECサイト構築", client_name: "株式会社XYZ")) }

    it "案件名に一致するプロジェクトを返す" do
      result = Project.search_by_keyword("基幹")
      expect(result).to include(project_a)
      expect(result).not_to include(project_b)
    end

    it "クライアント名に一致するプロジェクトを返す" do
      result = Project.search_by_keyword("XYZ")
      expect(result).to include(project_b)
      expect(result).not_to include(project_a)
    end

    it "キーワードが空またはnilの場合は全件返す" do
      expect(Project.search_by_keyword(nil)).to include(project_a, project_b)
      expect(Project.search_by_keyword("")).to include(project_a, project_b)
    end
  end

  describe ".filter_by_status" do
    let!(:active_project)    { user.projects.create!(valid_attrs.merge(name: "参画中案件", status: :active)) }
    let!(:upcoming_project)  { user.projects.create!(valid_attrs.merge(name: "参画前案件", status: :upcoming)) }
    let!(:completed_project) { user.projects.create!(valid_attrs.merge(name: "終了案件",   status: :completed)) }

    it "指定したステータスのみ返す" do
      result = Project.filter_by_status("active")
      expect(result).to include(active_project)
      expect(result).not_to include(upcoming_project, completed_project)
    end

    it "ステータスが空またはnilの場合は全件返す" do
      expect(Project.filter_by_status(nil)).to include(active_project, upcoming_project, completed_project)
      expect(Project.filter_by_status("")).to include(active_project, upcoming_project, completed_project)
    end
  end

  describe ".filter_by_work_style" do
    let!(:remote_project)  { user.projects.create!(valid_attrs.merge(name: "フルリモート案件", work_style: :full_remote)) }
    let!(:onsite_project)  { user.projects.create!(valid_attrs.merge(name: "フル出社案件",     work_style: :full_onsite)) }

    it "指定した勤務形態のみ返す" do
      result = Project.filter_by_work_style("full_remote")
      expect(result).to include(remote_project)
      expect(result).not_to include(onsite_project)
    end

    it "勤務形態が空またはnilの場合は全件返す" do
      expect(Project.filter_by_work_style(nil)).to include(remote_project, onsite_project)
      expect(Project.filter_by_work_style("")).to include(remote_project, onsite_project)
    end
  end

  describe ".filter_by_unit_price" do
    let!(:low_price)  { user.projects.create!(valid_attrs.merge(name: "低単価案件",  unit_price: 400_000)) }
    let!(:mid_price)  { user.projects.create!(valid_attrs.merge(name: "中単価案件",  unit_price: 600_000)) }
    let!(:high_price) { user.projects.create!(valid_attrs.merge(name: "高単価案件",  unit_price: 800_000)) }

    it "min_price 以上の案件を返す" do
      result = Project.filter_by_unit_price(min_price: 600_000, max_price: nil)
      expect(result).to include(mid_price, high_price)
      expect(result).not_to include(low_price)
    end

    it "max_price 以下の案件を返す" do
      result = Project.filter_by_unit_price(min_price: nil, max_price: 600_000)
      expect(result).to include(low_price, mid_price)
      expect(result).not_to include(high_price)
    end

    it "min_price と max_price の範囲内の案件を返す" do
      result = Project.filter_by_unit_price(min_price: 500_000, max_price: 700_000)
      expect(result).to include(mid_price)
      expect(result).not_to include(low_price, high_price)
    end

    it "min_price も max_price も nil の場合は全件返す" do
      result = Project.filter_by_unit_price(min_price: nil, max_price: nil)
      expect(result).to include(low_price, mid_price, high_price)
    end
  end
end
