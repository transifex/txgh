require 'openssl'

module Txgh
  class GithubRequestAuth
    HMAC_DIGEST = OpenSSL::Digest.new('sha1')

    def self.request_valid?(request, secret)
      request.body.rewind

      sha = OpenSSL::HMAC.hexdigest(
        HMAC_DIGEST, secret, request.body.read
      )

      request.body.rewind

      expected_signature = "sha1=#{sha}"
      actual_signature = request.env['HTTP_X_HUB_SIGNATURE']
      actual_signature == expected_signature
    end
  end
end
