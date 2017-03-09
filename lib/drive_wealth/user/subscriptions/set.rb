# Get all the current user subscriptions that belong to Stockflare
#
#
module DriveWealth
  module User
    module Subscriptions
      class Set < DriveWealth::Base
        values do
          attribute :token, String
          attribute :account_number, String
        end

        def call
          subs_response = DriveWealth::User::Subscriptions::Get.new(
            token: token,
            account_number: account_number
          ).call.response
          account_id = subs_response.raw['accountID']
          subscriptions = subs_response.payload.subscriptions

          if subscriptions.length == 0
            # Subscribe the user
            uri = URI.join(DriveWealth.api_uri, "v1/subscriptions")
            req = Net::HTTP::Post.new(uri, initheader = {
                                       'Content-Type' => 'application/json',
                                       'x-mysolomeo-session-key' => token
                                     })
            req.body = {
              accountID: account_id,
              productID: DriveWealth.subscription_product_id
            }.to_json

            resp = DriveWealth.call_api(uri, req)
            result = JSON.parse(resp.body)
            if resp.code == '200'
              payload = {
                type: 'success',
                subscription: result['subscriptionID'],
                subscriptions: [],
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
          else
            # Done need to do anything
            self.response = DriveWealth::Base::Response.new(
              raw: {
                subscriptions: subscriptions
              },
              payload: {
                type: 'success',
                subscriptions: subscriptions,
                status: 200,
                token: token
              },
              messages: Array('success'),
              status: 200
            )
          end

          DriveWealth.logger.info response.to_h
          self

        end
      end

    end
  end
end
