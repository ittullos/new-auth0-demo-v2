require 'spec_helper'
require_relative '../../app/middleware/jwt_validator'

RSpec.describe JwtValidator do
  let(:inner_app) do
    lambda do |env|
      payload = env['jwt.payload']
      [200, { 'Content-Type' => 'application/json' }, [JSON.generate(payload)]]
    end
  end

  let(:app) { described_class.new(inner_app) }

  before { stub_jwks }

  def make_request(token: nil)
    env = Rack::MockRequest.env_for('/profile')
    env['HTTP_AUTHORIZATION'] = "Bearer #{token}" if token
    app.call(env)
  end

  describe 'missing token' do
    it 'returns 401' do
      status, _headers, body = make_request
      expect(status).to eq(401)
    end

    it 'returns unauthorized error code' do
      _status, _headers, body = make_request
      parsed = JSON.parse(body.first)
      expect(parsed['error']).to eq('unauthorized')
    end

    it 'includes a descriptive message' do
      _status, _headers, body = make_request
      parsed = JSON.parse(body.first)
      expect(parsed['message']).to match(/authorization header/i)
    end
  end

  describe 'invalid token' do
    it 'returns 401' do
      status, = make_request(token: invalid_token)
      expect(status).to eq(401)
    end

    it 'returns unauthorized error code' do
      _status, _headers, body = make_request(token: invalid_token)
      parsed = JSON.parse(body.first)
      expect(parsed['error']).to eq('unauthorized')
    end
  end

  describe 'expired token' do
    it 'returns 401' do
      status, = make_request(token: expired_token)
      expect(status).to eq(401)
    end

    it 'returns unauthorized error code' do
      _status, _headers, body = make_request(token: expired_token)
      parsed = JSON.parse(body.first)
      expect(parsed['error']).to eq('unauthorized')
    end

    it 'message mentions expiry' do
      _status, _headers, body = make_request(token: expired_token)
      parsed = JSON.parse(body.first)
      expect(parsed['message']).to match(/expired/i)
    end
  end

  describe 'wrong audience' do
    it 'returns 401' do
      status, = make_request(token: wrong_audience_token)
      expect(status).to eq(401)
    end

    it 'returns unauthorized error code' do
      _status, _headers, body = make_request(token: wrong_audience_token)
      parsed = JSON.parse(body.first)
      expect(parsed['error']).to eq('unauthorized')
    end

    it 'message mentions audience' do
      _status, _headers, body = make_request(token: wrong_audience_token)
      parsed = JSON.parse(body.first)
      expect(parsed['message']).to match(/audience/i)
    end
  end

  describe 'algorithm confusion' do
    it 'rejects a token with alg: none' do
      payload = {
        sub: 'attacker', iss: "https://#{JwtTestHelper::TEST_DOMAIN}/",
        aud: JwtTestHelper::TEST_AUDIENCE, exp: Time.now.to_i + 3600
      }
      token = JWT.encode(payload, nil, 'none')
      status, = make_request(token: token)
      expect(status).to eq(401)
    end

    it 'rejects a token claiming HS256' do
      payload = {
        sub: 'attacker', iss: "https://#{JwtTestHelper::TEST_DOMAIN}/",
        aud: JwtTestHelper::TEST_AUDIENCE, exp: Time.now.to_i + 3600
      }
      token = JWT.encode(payload, 'secret', 'HS256')
      status, = make_request(token: token)
      expect(status).to eq(401)
    end
  end

  describe 'valid token' do
    it 'returns 200' do
      status, = make_request(token: valid_token)
      expect(status).to eq(200)
    end

    it 'forwards jwt.payload to inner app' do
      _status, _headers, body = make_request(token: valid_token)
      parsed = JSON.parse(body.first)
      expect(parsed['sub']).to eq('auth0|test-user')
    end
  end
end
