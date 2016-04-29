module DriveWealth
  module User
    class Refresh < DriveWealth::Base
      values do
        attribute :token, String
      end

      def call
        uri = URI.join(DriveWealth.api_uri, "v1/userSessions/#{token}?action=heartbeat")

        req = Net::HTTP::Put.new(uri, initheader = {
                                   'Content-Type' => 'application/json',
                                   'x-mysolomeo-session-key' => token
                                 })

        resp = DriveWealth.call_api(uri, req)
        result = JSON.parse(resp.body)

        if resp.code == '200'
          self.response = DriveWealth::User::Login.new(
            user_id: '',
            user_token: token
          ).call.response
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: result['message'],
            messages: result['message']
          )
        end

        DriveWealth.logger.info response.to_h
        self
      end
    end
  end
end
