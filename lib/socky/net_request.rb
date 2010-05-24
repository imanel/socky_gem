require 'timeout'
require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'

module Socky
  class NetRequest
    include Socky::Misc

    class << self

      def post(url, params = { })
        uri = URI.parse(url)
        params = params_from_hash(params)
        headers = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}
        begin
          http = Net::HTTP.new(uri.host, uri.port)
          if uri.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          http.read_timeout = options[:timeout] || 5
          resp, data = http.post(uri.path, params, headers)
          return resp.is_a?(Net::HTTPOK)
        rescue => e
          debug ["Bad request", url.to_s, e.class, e.message]
          return false
        rescue Timeout::Error
          debug [url.to_s, "timeout"]
          return false
        end
      end

      def params_from_hash(params)
        result = []
        params.each do |key, value|
          if value.is_a? Array
            value.each{ |v| result << "#{key}[]=#{CGI::escape(v.to_s)}"}
          else
            result << "#{key}=#{CGI::escape(value.to_s)}"
          end
        end
        result.join('&')
      end

    end

  end
end