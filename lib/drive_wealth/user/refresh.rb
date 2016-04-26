module DriveWealth
  module User
    class Refresh < DriveWealth::Base
      values do
        attribute :token, String
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/user/keepSessionAlive').to_s

        body = {
          token: token,
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
