require 'openssl'

module Txgh
  class GithubRequestAuth
    HMAC_DIGEST = OpenSSL::Digest.new('sha1')
    RACK_HEADER = 'HTTP_X_HUB_SIGNATURE'
    GITHUB_HEADER = 'X-Hub-Signature'

    class << self
      def request_valid?(request, secret)
        request.body.rewind
        expected_signature = header(request.body.read, secret)
        actual_signature = request.env[RACK_HEADER]
        actual_signature == expected_signature
      end

      def header(content, secret)
        "sha1=#{digest(content, secret)}"
      end

      private

      def digest(content, secret)
        OpenSSL::HMAC.hexdigest(HMAC_DIGEST, secret, content)
      end
    end
  end
end
