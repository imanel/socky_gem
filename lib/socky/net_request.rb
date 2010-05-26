require 'em-http'

module Socky
  class NetRequest
    include Socky::Misc

    class << self

      def post(url, params = {}, &block)
        http = EventMachine::HttpRequest.new(url).post :body => params, :timeout => options[:timeout] || 3
        http.errback  { yield false }
        http.callback { yield http.response_header.status == 200 }
        true
      rescue => e
        error "Bad request", e
        false
      end

    end

  end
end