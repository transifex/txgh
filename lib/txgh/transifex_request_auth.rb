require 'openssl'

module Txgh
  class TransifexRequestAuth
    HMAC_DIGEST = OpenSSL::Digest.new('sha1')
    RACK_HEADER = 'HTTP_X_TX_SIGNATURE'
    TRANSIFEX_HEADER = 'X-TX-Signature'

    class << self
      def authentic_request?(request, secret)
        request.body.rewind
        content = request.body.read
        if request.env['CONTENT_TYPE'] == "application/json"
          params = JSON.parse(content)
        else
          params = URI.decode_www_form(content)
        end

        expected_signature = header_value(params, secret)
        actual_signature = request.env[RACK_HEADER]
        actual_signature == expected_signature
      end

      def header_value(content, secret)
        digest(transform(content), secret)
      end

      private

      # In order to generate a correct HMAC hash, the request body must be
      # parsed and made to look like a python map. If you're thinking that's
      # weird, you're correct, but it's apparently expected behavior.
      def transform(params)
        params = params.map do |key, val|
          key = "'#{key}'"
          val = interpret_val(val)
          "#{key}: #{val}"
        end

        "{#{params.join(', ')}}"
      end

      def interpret_val(val)
        val = "#{val}"
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
