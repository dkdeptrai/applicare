module CookieHelper
  def cookies_signed
    # In test environment, we'll just use a simple hash-like approach
    @signed_cookies ||= {}
  end
end

RSpec.configure do |config|
  config.include CookieHelper, type: :request
end
