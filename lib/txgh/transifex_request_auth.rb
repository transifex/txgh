require 'openssl'

module Txgh
  class TransifexRequestAuth
    HMAC_DIGEST = OpenSSL::Digest.new('sha1')
    RACK_HEADER = 'HTTP_X_TX_SIGNATURE'
    TRANSIFEX_HEADER = 'X-TX-Signature'

    class << self
      def request_valid?(request, secret)
        request.body.rewind
        expected_signature = header(request.body.read, secret)
        actual_signature = request.env[RACK_HEADER]
        actual_signature == expected_signature
      end

      def header(content, secret)
        digest(content, secret)
      end

      private

      def digest(content, secret)
        OpenSSL::HMAC.hexdigest(HMAC_DIGEST, secret, content)
      end
    end
  end
end
