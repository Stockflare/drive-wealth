# Get all the current user subscriptions that belong to Stockflare
#
#
module DriveWealth
  module User
    module Subscriptions
      class Get < DriveWealth::Base
        values do
          attribute :token, String
          attribute :account_number, String
        end

        def call
          details = DriveWealth::User.get_account(token, account_number)
          account = details[:account]

          uri = URI.join(DriveWealth.api_uri, "v1/subscriptions/#{account['accountID']}")
          req = Net::HTTP::Get.new(uri, initheader = {
                                     'Content-Type' => 'application/json',
                                     'x-mysolomeo-session-key' => token
                                   })

          resp = DriveWealth.call_api(uri, req)
          result = JSON.parse(resp.body)
          if resp.code == '200'
            subscriptions = result['subscriptions'].reject do |subscription|
              subscription['provider'] != 'StockFlare' || subscription['active'] == false
            end
            payload = {
              type: 'success',
              subscriptions: subscriptions,
              token: token
            }

            self.response = DriveWealth::Base::Response.new(
              raw: result,
              payload: payload,
              messages: Array('success'),
              status: 200
            )
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
end
