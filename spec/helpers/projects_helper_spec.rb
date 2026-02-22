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
end
