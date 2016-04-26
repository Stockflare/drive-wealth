module DriveWealth
  module User
    class Verify < DriveWealth::Base
      values do
        attribute :token, String
        attribute :answer, String
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/user/answerSecurityQuestion').to_s

        body = {
          securityAnswer: answer,
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
