require "rails_helper"

RSpec.describe ProjectsHelper, type: :helper do
  describe "#timeline_bar_color" do
    it "active（参画中）なら緑を返す" do
      expect(helper.timeline_bar_color(double(status: "active"))).to eq("#34d399")
    end

    it "upcoming（参画前）なら黄を返す" do
      expect(helper.timeline_bar_color(double(status: "upcoming"))).to eq("#fbbf24")
    end

    it "completed（終了）なら灰を返す" do
      expect(helper.timeline_bar_color(double(status: "completed"))).to eq("#6b7280")
    end
  end

  describe "#duration_label" do
    include ActiveSupport::Testing::TimeHelpers

    def proj(start_date, end_date)
      double(start_date: start_date, end_date: end_date)
    end

    it "30日 → 1.0ヶ月" do
      p = proj(Date.new(2024, 1, 1), Date.new(2024, 1, 31))
      expect(helper.duration_label(p)).to eq("（1.0ヶ月）")
    end

    it "約258日 → 8.5ヶ月" do
      p = proj(Date.new(2023, 4, 15), Date.new(2023, 12, 29))
      expect(helper.duration_label(p)).to eq("（8.5ヶ月）")
    end

    it "365日ちょうど → 1年" do
      p = proj(Date.new(2023, 1, 1), Date.new(2024, 1, 1))
      expect(helper.duration_label(p)).to eq("（1年）")
    end

    it "約426日（14ヶ月相当） → 1年2ヶ月" do
      p = proj(Date.new(2023, 1, 1), Date.new(2024, 3, 1))
      expect(helper.duration_label(p)).to eq("（1年2ヶ月）")
    end

    it "730日ちょうど → 2年" do
      p = proj(Date.new(2023, 1, 1), Date.new(2025, 1, 1))
      expect(helper.duration_label(p)).to eq("（2年）")
    end

    it "end_date が nil のとき today を終端として計算" do
      travel_to Date.new(2024, 4, 1) do
        p = proj(Date.new(2024, 1, 1), nil)
        expect(helper.duration_label(p)).to eq("（3.0ヶ月）")
      end
    end
  end
end
