module DriveWealth
  module User
    class Link < DriveWealth::Base
      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/userSessions')
        body = {
          appTypeID: '28',
          appVersion: DriveWealth::VERSION,
          username: username,
          languageID: DriveWealth.language,
          password: password,
          osVersion: 'Ubuntu 64',
          osType: 'Linux',
          scrRes: '1920x1080'
        }

        req = Net::HTTP::Post.new(uri, initheader = { 'Content-Type' => 'application/json' })
        req.body = body.to_json

        resp = DriveWealth.call_api(uri, req)

        result = JSON.parse(resp.body)

        if resp.code == '200'
          self.response = DriveWealth::Base::Response.new(raw: result,
                                                          status: 200,
                                                          payload: {
                                                            type: 'success',
                                                            user_id: result['userID'],
                                                            user_token: result['sessionKey']
                                                          },
                                                          messages: ['success'])
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: result['message'],
            messages: result['message']
          )
        end
        # pp response.to_h
        DriveWealth.logger.info response.to_h
        self
      end
    end
  end
end
