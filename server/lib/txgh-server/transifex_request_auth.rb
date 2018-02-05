require 'json'
require 'openssl'
require 'base64'

module TxghServer
  class TransifexRequestAuth
    HMAC_DIGEST = OpenSSL::Digest.new('sha256')
    RACK_HEADER = 'HTTP_X_TX_SIGNATURE_V2'
    TRANSIFEX_HEADER = 'X-TX-Signature-V2'

    class << self
      def authentic_request?(request, secret)
        request.body.rewind

        expected_signature = compute_signature(
          http_verb: request.request_method,
          date_str: request.env['HTTP_DATE'],
          url: request.env['HTTP_X_TX_URL'],
          content: request.body.read,
          secret: secret
        )

        actual_signature = signature_from(request)
        actual_signature == expected_signature
      end

      def compute_signature(http_verb: 'POST', url:, date_str:, content:, secret:)
        data = [http_verb, url, date_str, Digest::MD5.hexdigest(content)]
        digest(data.join("\n"), secret)
      end

      def signature_from(request)
        request.env[RACK_HEADER]
      end

      private

      def digest(content, secret)
        Base64.encode64(
          OpenSSL::HMAC.digest(HMAC_DIGEST, secret, content)
        ).strip
      end
    end
  end
end
