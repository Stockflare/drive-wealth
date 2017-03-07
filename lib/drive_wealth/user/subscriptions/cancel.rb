# Get all the current user subscriptions that belong to Stockflare
#
#
module DriveWealth
  module User
    module Subscriptions
      class Cancel < DriveWealth::Base
        values do
          attribute :token, String
          attribute :account_number, String
        end

        def call
          subs_response = DriveWealth::User::Subscriptions::Get.new(
            token: token,
            account_number: account_number
          ).call.response
          subscriptions = subs_response.payload.subscriptions

          if subscriptions.length > 0
            results = subscriptions.map do |subscription|
              # Cancel the subscription
              uri = URI.join(DriveWealth.api_uri, "v1/subscriptions/#{subscription.subscriptionID}")
              req = Net::HTTP::Delete.new(uri, initheader = {
                                         'Content-Type' => 'application/json',
                                         'x-mysolomeo-session-key' => token
                                       })

              resp = DriveWealth.call_api(uri, req)
              if resp.code == '204'
                subscription
              else
                raise Trading::Errors::LoginException.new(
                  type: :error,
                  code: resp.code,
                  description: result['message'],
                  messages: result['message']
                )
              end
            end

            payload = {
              type: 'success',
              subscriptions: results,
              token: token
            }
            self.response = DriveWealth::Base::Response.new(
              raw: subs_response,
              payload: payload,
              messages: Array('success'),
              status: 200
            )
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
