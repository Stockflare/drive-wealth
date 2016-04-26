module DriveWealth
  module User
    class Login < DriveWealth::Base
      values do
        attribute :user_id, String
        attribute :user_token, String
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/user/authenticate').to_s

        body = {
          userId: user_id,
          userToken: user_token,
          apiKey: DriveWealth.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)

        self.response = DriveWealth::User.parse_result(result)

        DriveWealth.logger.info response.to_h
        self
      end
    end
  end
end
