require 'httparty'
require 'json'
require 'jwt'

class JwksClient
  CACHE_TTL = 3600 # seconds

  def initialize(domain)
    @uri = "https://#{domain}/.well-known/jwks.json"
    @cached_at = nil
    @jwk_set = nil
  end

  def public_key(kid)
    refresh_if_stale
    jwk = @jwk_set.find { |k| k[:kid] == kid }
    raise JwtValidator::ValidationError, 'No matching key found in JWKS' unless jwk

    jwk.keypair.public_key
  end

  private

  def refresh_if_stale
    return if @jwk_set && (Time.now - @cached_at) < CACHE_TTL

    response = HTTParty.get(@uri, timeout: 5)
    raise JwtValidator::ValidationError, 'Failed to fetch JWKS' unless response.success?

    @jwk_set = JWT::JWK::Set.new(JSON.parse(response.body))
    @cached_at = Time.now
  end
end
