require 'jwt'
require 'openssl'
require 'base64'
require_relative '../services/jwks_client'

class JwtValidator
  class ValidationError < StandardError; end

  def initialize(app)
    @app = app
    @domain   = ENV.fetch('AUTH0_DOMAIN')
    @audience = ENV.fetch('AUTH0_AUDIENCE')
    @jwks     = JwksClient.new(@domain)
  end

  def call(env)
    token = extract_token(env)
    payload = validate(token)
    env['jwt.payload'] = payload
    @app.call(env)
  rescue ValidationError => e
    error_response(401, 'unauthorized', e.message)
  end

  private

  def extract_token(env)
    header = env['HTTP_AUTHORIZATION'] || ''
    raise ValidationError, 'Missing or invalid Authorization header' unless header.start_with?('Bearer ')

    header.delete_prefix('Bearer ')
  end

  def validate(token)
    header = JWT.decode(token, nil, false).last
    kid = header['kid']
    raise ValidationError, 'Missing kid in token header' unless kid
    raise ValidationError, 'Unsupported algorithm' unless header['alg'] == 'RS256'

    public_key = @jwks.public_key(kid)

    payload, = JWT.decode(
      token,
      public_key,
      true,
      algorithms: ['RS256'],
      iss: "https://#{@domain}/",
      verify_iss: true,
      aud: @audience,
      verify_aud: true
    )
    payload
  rescue JWT::ExpiredSignature
    raise ValidationError, 'Token has expired'
  rescue JWT::InvalidAudError
    raise ValidationError, 'Invalid audience'
  rescue JWT::InvalidIssuerError
    raise ValidationError, 'Invalid issuer'
  rescue JWT::DecodeError => e
    raise ValidationError, "Token decode failed: #{e.message}"
  end

  def error_response(status, error, message)
    body = JSON.generate({ error: error, message: message, status: status })
    [status, { 'Content-Type' => 'application/json' }, [body]]
  end
end
