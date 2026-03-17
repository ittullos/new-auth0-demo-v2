require 'dotenv/load'
require 'rack/cors'
require_relative 'app/middleware/jwt_validator'
require_relative 'app/controllers/application'

use Rack::Cors do
  allow do
    origins ENV.fetch('FRONTEND_ORIGIN')
    resource '*',
      headers: %w[Authorization Content-Type],
      methods: %i[get post put delete options]
  end
end

run ApplicationController
