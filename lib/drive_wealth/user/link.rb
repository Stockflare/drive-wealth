module DriveWealth
  module User
    class Link < DriveWealth::Base
      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/user/oAuthLink').to_s
        body = {
          id: username,
          password: password,
          broker: DriveWealth.brokers[broker],
          apiKey: DriveWealth.api_key
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)

        if result['status'] == 'SUCCESS'
          self.response = DriveWealth::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        user_id: result['userId'],
                                                        user_token: result['userToken']
                                                      },
                                                      messages: [result['shortMessage']].compact)
        else
          raise DriveWealth::Errors::LoginException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        # pp response.to_h
        DriveWealth.logger.info response.to_h
        self
      end
    end
  end
end
