require 'jwt'
require 'openssl'

module JwtTestHelper
  TEST_DOMAIN   = 'test.auth0.com'
  TEST_AUDIENCE = 'https://api.auth0-demo-v2.dev'
  TEST_KID      = 'test-key-id'

  # Generated once per process; shared across examples
  RSA_KEY = OpenSSL::PKey::RSA.generate(2048)

  def rsa_private_key
    RSA_KEY
  end

  def rsa_public_key
    RSA_KEY.public_key
  end

  # Builds a JWKS payload using the JWT gem's JWK export (OpenSSL 3.0 compatible)
  def stub_jwks
    jwk = JWT::JWK.new(rsa_public_key, { kid: TEST_KID })
    jwks_body = JWT::JWK::Set.new([jwk]).export.to_json

    stub_request(:get, "https://#{TEST_DOMAIN}/.well-known/jwks.json")
      .to_return(status: 200, body: jwks_body, headers: { 'Content-Type' => 'application/json' })
  end

  def valid_token(overrides = {})
    payload = {
      sub:   'auth0|test-user',
      iss:   "https://#{TEST_DOMAIN}/",
      aud:   TEST_AUDIENCE,
      iat:   Time.now.to_i,
      exp:   Time.now.to_i + 3600,
      name:  'Test User',
      email: 'test@example.com'
    }.merge(overrides)

    JWT.encode(payload, rsa_private_key, 'RS256', { kid: TEST_KID })
  end

  def expired_token
    valid_token(exp: Time.now.to_i - 3600, iat: Time.now.to_i - 7200)
  end

  def wrong_audience_token
    valid_token(aud: 'https://wrong-audience.example.com')
  end

  def invalid_token
    'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.invalid.signature'
  end
end
