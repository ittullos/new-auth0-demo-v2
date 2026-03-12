require 'webmock/rspec'
require 'rack/test'

ENV['AUTH0_DOMAIN']   = 'test.auth0.com'
ENV['AUTH0_AUDIENCE'] = 'https://api.auth0-demo-v2.dev'
ENV['FRONTEND_ORIGIN'] = 'http://localhost:5173'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include JwtTestHelper

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random

  WebMock.disable_net_connect!
end
