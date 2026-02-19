module AuthHelpers
  def login_as(user, password: "password123")
    post login_path, params: { session: { email: user.email, password: password } }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
