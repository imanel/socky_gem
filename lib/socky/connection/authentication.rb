module Socky
  class Connection
    module Authentication
      include Socky::Misc

      def subscribe_request
        send_subscribe_request do |response|
          if response
            debug [self.name, "authentication successed"]
            add_to_pool
            @authenticated_by_url = true
          else
            debug [self.name, "authentication failed"]
            disconnect
          end
        end unless authenticated?
      end

      def unsubscribe_request
        if authenticated?
          remove_from_pool
          send_unsubscribe_request{} unless admin
        end
      end

      def authenticated?
        @authenticated ||= (admin ? authenticate_as_admin : authenticate_as_user)
      end

      def authenticate_as_admin
        secret == options[:secret]
      end

      def authenticate_as_user
        authenticated_by_url?
      end

      def authenticated_by_url?
        @authenticated_by_url
      end

      def send_subscribe_request(&block)
        subscribe_url = options[:subscribe_url]
        if subscribe_url
          debug [self.name, "sending subscribe request to", subscribe_url]
          Socky::NetRequest.post(subscribe_url, params_for_request, &block)
          true
        end
        true
      end

      def send_unsubscribe_request(&block)
        unsubscribe_url = options[:unsubscribe_url]
        if unsubscribe_url
          debug [self.name, "sending unsubscribe request to", unsubscribe_url]
          Socky::NetRequest.post(unsubscribe_url, params_for_request, &block)
        else
          true
        end
      end

      def params_for_request
        {
          :client_id => client,
          :client_secret => secret,
          :channels => channels
        }.reject{|key,value| value.nil? || value.empty?}
      end

    end
  end
end