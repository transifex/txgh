require 'openssl'

module Txgh
  class TransifexRequestAuth
    HMAC_DIGEST = OpenSSL::Digest.new('sha1')
    HMAC_DIGEST_256 = OpenSSL::Digest.new('sha256')
    RACK_HEADER = 'HTTP_X_TX_SIGNATURE'
    RACK_HEADER_V2 = 'HTTP_X_TX_SIGNATURE_V2'
    TRANSIFEX_HEADER = 'X-TX-Signature'

    class << self
      def authentic_request?(request, secret)
        request.body.rewind
        content = request.body.read
        http_verb = request.request_method
        url = request.url
        date = request.env['HTTP_DATE']
        expected_signature_v1 = header_value_v1(content, secret)
        expected_signature_v2 = header_value_v2(http_verb, url, date, content, secret)
        actual_signature_v1 = request.env[RACK_HEADER]
        actual_signature_v2 = request.env[RACK_HEADER_V2]
        actual_signature_v1 == expected_signature_v1 or actual_signature_v2 == expected_signature_v2
      end

      def header_value_v1(content, secret)
        digest(HMAC_DIGEST, secret, transform(content))
      end

      def header_value_v2(http_verb, url, date, content, secret)
        content_md5 = Digest::MD5.hexdigest content
        data = [http_verb, url, date, content_md5].join("\n")
        digest(HMAC_DIGEST_256, secret, data)
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

      def digest(hmac_digest, secret, content)
        Base64.encode64(
          OpenSSL::HMAC.digest(hmac_digest, secret, content)
        ).strip
      end

    end
  end
end
