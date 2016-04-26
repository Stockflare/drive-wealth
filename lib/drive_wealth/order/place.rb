module DriveWealth
  module Order
    class Place < DriveWealth::Base
      values do
        attribute :token, String
        attribute :price, Float
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/order/placeStockOrEtfOrder').to_s

        body = {
          token: token,
          apiKey: DriveWealth.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'SUCCESS'
          details = result['orderInfo']
          # binding.pry
          payload = {
            type: 'success',
            ticker: details['symbol'],
            order_action: DriveWealth.place_order_actions.key(details['action']),
            quantity: details['quantity'].to_i,
            expiration: DriveWealth.order_expirations.key(details['universalOrderInfo']['expiration']),
            price_label: details['price']['type'],
            message: result['confirmationMessage'],
            last_price: details['price']['last'].to_f,
            bid_price: details['price']['bid'].to_f,
            ask_price: details['price']['ask'].to_f,
            price_timestamp: parse_time(details['price']['timestamp']),
            timestamp: parse_time(result['timestamp']),
            order_number: result['orderNumber'],
            token: result['token'],
            price: price
          }

          self.response = DriveWealth::Base::Response.new(
            raw: result,
            payload: payload,
            messages: [result['shortMessage']],
            status: 200
          )
        else
          #
          # Order failed
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
