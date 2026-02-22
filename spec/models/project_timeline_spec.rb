require "rails_helper"

RSpec.describe ProjectTimeline do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) do
    User.create!(name: "テスト", email: "test_tl@example.com",
                 password: "password123", password_confirmation: "password123")
  end

  let(:base_attrs) do
    { user: user, client_name: "株式会社サンプル",
      unit_price: 600_000, work_style: :full_remote, status: :active }
  end

  # -------------------------
  # 空状態
  # -------------------------
  describe "#empty?" do
    it "案件が0件なら true を返す" do
      expect(ProjectTimeline.new(user.projects)).to be_empty
    end

    it "案件があれば false を返す" do
      user.projects.create!(base_attrs.merge(name: "案件A", start_date: Date.new(2025, 1, 1)))
      expect(ProjectTimeline.new(user.projects)).not_to be_empty
    end
  end

  # -------------------------
  # 期間計算（today を 2025-04-11 に固定）
  # -------------------------
  context "案件が存在するとき" do
    around { |ex| travel_to(Date.new(2025, 4, 11)) { ex.run } }

    before do
      # 案件A: start=2025-01-15, end=2025-03-31
      # 案件B: start=2025-03-01, end=nil（今日=2025-04-11 を使用）
      user.projects.create!(base_attrs.merge(name: "案件A", start_date: Date.new(2025, 1, 15), end_date: Date.new(2025, 3, 31)))
      user.projects.create!(base_attrs.merge(name: "案件B", start_date: Date.new(2025, 3, 1),  end_date: nil))
    end

    subject(:timeline) { ProjectTimeline.new(user.projects) }

    describe "#timeline_start" do
      it "全案件中で最も古い start_date の月初を返す" do
        expect(timeline.timeline_start).to eq(Date.new(2025, 1, 1))
      end
    end

    describe "#timeline_end" do
      it "end_date が nil の案件がある場合は今日の月末を使う" do
        # today=2025-04-11 → end_of_month=2025-04-30
        expect(timeline.timeline_end).to eq(Date.new(2025, 4, 30))
      end

      it "全案件の end_date が今日より後なら最大 end_date の月末を使う" do
        user.projects.destroy_all
        user.projects.create!(base_attrs.merge(name: "案件X", start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 6, 15)))
        expect(ProjectTimeline.new(user.projects).timeline_end).to eq(Date.new(2025, 6, 30))
      end
    end

    describe "#total_days" do
      it "timeline_start から timeline_end の日数を返す" do
        # Date.new(2025,4,30) - Date.new(2025,1,1) = 119
        expect(timeline.total_days).to eq(119)
      end
    end

    describe "#months" do
      it "timeline_start から timeline_end までの月初日の配列を返す" do
        expect(timeline.months).to eq([
          Date.new(2025, 1, 1),
          Date.new(2025, 2, 1),
          Date.new(2025, 3, 1),
          Date.new(2025, 4, 1)
        ])
      end
    end

    describe "#projects" do
      it "start_date 昇順で返す" do
        expect(timeline.projects.map(&:name)).to eq([ "案件A", "案件B" ])
      end
    end
  end

  # -------------------------
  # 位置計算メソッド
  # （timeline_start=2025-01-01, total_days=100 を直接設定）
  # -------------------------
  describe "位置計算メソッド" do
    subject(:tl) do
      t = described_class.allocate
      t.instance_variable_set(:@timeline_start, Date.new(2025, 1, 1))
      t.instance_variable_set(:@total_days, 100)
      t
    end

    describe "#bar_left_pct" do
      it "開始日が timeline_start と同じなら 0.0 を返す" do
        expect(tl.bar_left_pct(double(start_date: Date.new(2025, 1, 1)))).to eq(0.0)
      end

      it "開始日が 50 日後（2025-02-20）なら 50.0 を返す" do
        expect(tl.bar_left_pct(double(start_date: Date.new(2025, 2, 20)))).to eq(50.0)
      end

      it "開始日が 100 日後（2025-04-11）なら 100.0 を返す" do
        expect(tl.bar_left_pct(double(start_date: Date.new(2025, 4, 11)))).to eq(100.0)
      end
    end

    describe "#bar_width_pct" do
      it "end_date が 100 日後なら 100.0 を返す" do
        project = double(start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 4, 11))
        expect(tl.bar_width_pct(project)).to eq(100.0)
      end

      it "end_date が 40 日後（2025-02-10）なら 40.0 を返す" do
        project = double(start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 2, 10))
        expect(tl.bar_width_pct(project)).to eq(40.0)
      end

      it "end_date が nil の場合は今日を終端として計算する" do
        start_date = Date.new(2025, 1, 1)
        expected = ((Date.today - start_date).to_f / 100 * 100).round(4)
        expect(tl.bar_width_pct(double(start_date: start_date, end_date: nil))).to eq(expected)
      end
    end

    describe "#month_left_pct" do
      it "timeline_start の月なら 0.0 を返す" do
        expect(tl.month_left_pct(Date.new(2025, 1, 1))).to eq(0.0)
      end

      it "50 日後（2025-02-20）なら 50.0 を返す" do
        expect(tl.month_left_pct(Date.new(2025, 2, 20))).to eq(50.0)
      end
    end
  end
end
