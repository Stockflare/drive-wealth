module DriveWealth
  module Order
    class Status < DriveWealth::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_number, String
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/order/getAllOrderStatus').to_s
        uri =  URI.join(DriveWealth.api_uri, 'v1/order/getSingleOrderStatus').to_s if order_number

        body = {
          token: token,
          accountNumber: account_number,
          apiKey: DriveWealth.api_key
        }

        body[:orderNumber] = order_number if order_number

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'SUCCESS'

          payload = {
            type: 'success',
            orders: DriveWealth::Order.parse_order_details(result['orderStatusDetailsList']),
            token: result['token']
          }

          self.response = DriveWealth::Base::Response.new(
            raw: result,
            payload: payload,
            messages: Array(result['shortMessage']),
            status: 200
          )
        else
          #
          # Status failed
          #
          raise DriveWealth::Errors::OrderException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        DriveWealth.logger.info response.to_h
        self
      end

      def parse_time(time_string)
        Time.parse(time_string).utc.to_i
      rescue
        Time.now.utc.to_i
      end
    end
  end
end
