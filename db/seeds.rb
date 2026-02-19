user = User.find_or_create_by!(email: "dev@example.com") do |u|
  u.name = "開発ユーザー"
  u.password = "password"
  u.password_confirmation = "password"
end

Project.find_or_create_by!(name: "ECサイトリプレイス") do |p|
  p.user = user
  p.client_name = "株式会社サンプル商事"
  p.unit_price = 650000
  p.work_style = :full_remote
  p.start_date = Date.new(2025, 4, 1)
  p.end_date = Date.new(2025, 9, 30)
  p.tech_stack = "Ruby, Rails, PostgreSQL, Docker, AWS"
  p.status = :completed
end

Project.find_or_create_by!(name: "社内業務管理システム開発") do |p|
  p.user = user
  p.client_name = "株式会社テックパートナーズ"
  p.unit_price = 700000
  p.work_style = :full_onsite
  p.start_date = Date.new(2025, 10, 1)
  p.end_date = nil
  p.tech_stack = "TypeScript, React, Node.js, PostgreSQL"
  p.status = :active
end

Project.find_or_create_by!(name: "金融系APIマイクロサービス化") do |p|
  p.user = user
  p.client_name = "ABCフィナンシャル株式会社"
  p.unit_price = 750000
  p.work_style = :full_remote
  p.start_date = Date.new(2026, 4, 1)
  p.end_date = Date.new(2026, 9, 30)
  p.tech_stack = "Go, gRPC, Kubernetes, AWS"
  p.status = :upcoming
end
