module DriveWealth
  module Order
    class Status < DriveWealth::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_number, String
      end

      def call
        blotter = DriveWealth::User::Account.new(token: token, account_number: account_number).call.response
        orders = blotter.raw['orders']
        orders = blotter.raw['orders'].select { |o| o['orderNo'] == order_number } if order_number
        if orders.count > 0
          payload_orders = orders.map do |order|
            filled_value = blotter.raw['transactions'].inject(0.0) do |sum, transaction|
              if transaction['orderNo'] == order['orderNo']
                sum + (transaction['cumQty'].to_f * transaction['executedPrice'].to_f)
              end
            end
            filled_quantity = blotter.raw['transactions'].inject(0.0) do |sum, transaction|
              if transaction['orderNo'] == order['orderNo']
                sum + transaction['cumQty'].to_f
              end
            end
            filled_price = filled_price && filled_quantity && filled_quantity != 0 ? filled_value / filled_quantity : 0.0

            {
              ticker: order['symbol'].downcase,
              order_action: DriveWealth.order_status_actions[order['side']],
              filled_quantity: filled_quantity,
              filled_price: filled_price,
              order_number: order['orderNo'],
              quantity: order['orderQty'].to_f,
              expiration: :day,
              status: DriveWealth.order_statuses[order['orderStatus']]
            }
          end

          payload = {
            type: 'success',
            orders: payload_orders,
            token: token
          }

          self.response = DriveWealth::Base::Response.new(
            raw: blotter.raw,
            payload: payload,
            messages: Array('success'),
            status: 200
          )
        else
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: '403',
            description: 'No Orders found',
            messages: ['No Orders found']
          )
        end

        # pp response.to_h
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
