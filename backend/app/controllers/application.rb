require 'sinatra/base'
require 'sinatra/json'
require_relative '../middleware/jwt_validator'

class ApplicationController < Sinatra::Base
  use JwtValidator

  before do
    content_type :json
  end

  get '/profile' do
    payload = request.env['jwt.payload']
    ns = 'https://auth0-demo-v2.dev'
    json({
      sub:   payload['sub'],
      email: payload["#{ns}/email"],
      name:  payload["#{ns}/name"]
    })
  end

  error 404 do
    json({ error: 'not_found', message: 'Route not found', status: 404 })
  end

  error 500 do
    json({ error: 'internal_server_error', message: 'An unexpected error occurred', status: 500 })
  end
end
