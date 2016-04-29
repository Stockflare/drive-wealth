module DriveWealth
  module User
    class Login < DriveWealth::Base
      values do
        attribute :user_id, String
        attribute :user_token, String
      end

      def call
        uri = URI.join(DriveWealth.api_uri, "v1/userSessions/#{user_token}")

        req = Net::HTTP::Get.new(uri, initheader = {
                                   'Content-Type' => 'application/json',
                                   'x-mysolomeo-session-key' => user_token
                                 })

        resp = DriveWealth.call_api(uri, req)

        result = JSON.parse(resp.body)

        self.response = DriveWealth::User.parse_result(result, resp)

        DriveWealth.logger.info response.to_h
        self
      end
    end
  end
end
