require 'spec_helper'
require_relative '../../app/controllers/application'

RSpec.describe 'GET /profile' do
  def app
    ApplicationController
  end

  before { stub_jwks }

  context 'missing token' do
    it 'returns 401' do
      get '/profile'
      expect(last_response.status).to eq(401)
    end

    it 'returns JSON error body' do
      get '/profile'
      body = JSON.parse(last_response.body)
      expect(body['error']).to eq('unauthorized')
      expect(body['status']).to eq(401)
    end
  end

  context 'invalid token' do
    it 'returns 401' do
      get '/profile', {}, 'HTTP_AUTHORIZATION' => "Bearer #{invalid_token}"
      expect(last_response.status).to eq(401)
    end
  end

  context 'expired token' do
    it 'returns 401' do
      get '/profile', {}, 'HTTP_AUTHORIZATION' => "Bearer #{expired_token}"
      expect(last_response.status).to eq(401)
    end

    it 'message mentions expiry' do
      get '/profile', {}, 'HTTP_AUTHORIZATION' => "Bearer #{expired_token}"
      body = JSON.parse(last_response.body)
      expect(body['message']).to match(/expired/i)
    end
  end

  context 'wrong audience' do
    it 'returns 401' do
      get '/profile', {}, 'HTTP_AUTHORIZATION' => "Bearer #{wrong_audience_token}"
      expect(last_response.status).to eq(401)
    end

    it 'message mentions audience' do
      get '/profile', {}, 'HTTP_AUTHORIZATION' => "Bearer #{wrong_audience_token}"
      body = JSON.parse(last_response.body)
      expect(body['message']).to match(/audience/i)
    end
  end

  context 'valid token' do
    it 'returns 200' do
      get '/profile', {}, 'HTTP_AUTHORIZATION' => "Bearer #{valid_token}"
      expect(last_response.status).to eq(200)
    end

    it 'returns profile data from token payload' do
      get '/profile', {}, 'HTTP_AUTHORIZATION' => "Bearer #{valid_token}"
      body = JSON.parse(last_response.body)
      expect(body['sub']).to eq('auth0|test-user')
      expect(body['email']).to eq('test@example.com')
      expect(body['name']).to eq('Test User')
    end
  end
end
