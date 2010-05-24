module Socky
  class Connection
    module Authentication

      def subscribe_request
        if authenticated?
          debug [self.name, "authentication successed"]
          add_to_pool
        else
          debug [self.name, "authentication failed"]
          disconnect
        end
      end

      def unsubscribe_request
        if authenticated?
          remove_from_pool
          send_unsubscribe_request unless admin
        end
      end

      def authenticated?
        if @authenticated.nil?
          @authenticated = (admin ? authenticate_as_admin : authenticate_as_user)
        else
          @authenticated
        end
      end

      def authenticate_as_admin
        true
      end

      def authenticate_as_user
        authenticated_by_url?
      end

      def authenticated_by_url?
        send_subscribe_request
      end

      def send_subscribe_request
        subscribe_url = options[:subscribe_url]
        if subscribe_url
          debug [self.name, "sending subscribe request to", subscribe_url]
          Socky::NetRequest.post(subscribe_url, params_for_request)
        else
          true
        end
      end

      def send_unsubscribe_request
        unsubscribe_url = options[:unsubscribe_url]
        if unsubscribe_url
          debug [self.name, "sending unsubscribe request to", unsubscribe_url]
          Socky::NetRequest.post(unsubscribe_url, params_for_request)
        else
          true
        end
      end

      def params_for_request
        params = {}
        params.merge!(:client_id => self.client) unless self.client.nil?
        params.merge!(:client_secret => self.secret) unless self.secret.nil?
        params.merge!(:channels => self.channels) unless self.channels.empty?
        params
      end

    end
  end
end