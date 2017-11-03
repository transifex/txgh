require 'openssl'
require 'base64'

module TxghServer
  class TransifexRequestAuth
    HMAC_DIGEST = OpenSSL::Digest.new('sha1')
    RACK_HEADER = 'HTTP_X_TX_SIGNATURE'
    TRANSIFEX_HEADER = 'X-TX-Signature'

    class << self
      def authentic_request?(request, secret)
        request.body.rewind
        expected_signature = header_value(request.body.read, secret)
        actual_signature = signature_from(request)
        actual_signature == expected_signature
      end

      def header_value(content, secret)
        digest(transform(content), secret)
      end

      def signature_from(request)
        request.env[RACK_HEADER]
      end

      private

      # In order to generate a correct HMAC hash, the request body must be
      # parsed and made to look like a python map. If you're thinking that's
      # weird, you're correct, but it's apparently expected behavior.
      def transform(content)
        params = URI.decode_www_form(content)

        params = params.map do |key, val|
          key = "'#{key}'"
          val = interpret_val(val)
          "#{key}: #{val}"
        end

        "{#{params.join(', ')}}"
      end

      def interpret_val(val)
        if val =~ /\A[\d]+\z/
          val
        else
          "u'#{val}'"
        end
      end

      def digest(content, secret)
        Base64.encode64(
          OpenSSL::HMAC.digest(HMAC_DIGEST, secret, content)
        ).strip
      end
    end
  end
end
