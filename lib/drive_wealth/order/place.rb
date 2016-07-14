module DriveWealth
  module Order
    class Place < DriveWealth::Base
      values do
        attribute :token, String
        attribute :price, Float
      end

      def call
        # Get the Order Details from the cache

        begin
          preview = JSON.parse(DriveWealth.cache.get("#{DriveWealth::CACHE_PREFIX}_#{token}"))
          if preview
            body = {
              accountID: preview['raw']['account']['accountID'],
              accountNo: preview['raw']['account']['accountNo'],
              userID: preview['raw']['user_id'],
              accountType: preview['raw']['account']['accountType'],
              ordType: DriveWealth.price_types[preview['raw']['price_type'].to_sym],
              side: DriveWealth.order_actions[preview['raw']['order_action'].to_sym],
              instrumentID: preview['raw']['instrument']['instrumentID'],
              orderQty: preview['raw']['quantity'].to_f,
              comment: ''
            }

            body[:price] = price if preview['raw']['price_type'].to_sym == :stop_market
            body[:limitPrice] = price if preview['raw']['price_type'].to_sym == :limit
            body[:amountCash] = preview['raw']['amount'].to_f if preview['raw']['price_type'].to_sym == :market && preview['raw']['amount'] && preview['raw']['amount'] != 0.0

            uri = URI.join(DriveWealth.api_uri, 'v1/orders')
            req = Net::HTTP::Post.new(uri, initheader = {
                                        'Content-Type' => 'application/json',
                                        'x-mysolomeo-session-key' => token,
                                        'Accept' => 'application/json'
                                      })
            req.body = body.to_json

            resp = DriveWealth.call_api(uri, req)

            result = JSON.parse(resp.body)
            if resp.code == '200'
              order_id = result['orderID']

              case preview['raw']['price_type'].to_sym
              when :market
                price_label = 'Market'
              when :limit
                price_label = 'Limit'
              when :stop_market
                price_label = 'Stop on Quote'
              else
                price_label = 'Unknown'
              end

              payload = {
                type: 'success',
                ticker: preview['raw']['ticker'],
                order_action: DriveWealth.place_order_actions.key(result['side']),
                quantity: result['leavesQty'].to_f,
                expiration: :day,
                price_label: price_label,
                message: 'success',
                last_price: preview['raw']['instrument']['lastTrade'].to_f,
                bid_price: preview['raw']['instrument']['rateBid'].to_f,
                ask_price: preview['raw']['instrument']['rateAsk'].to_f,
                price_timestamp: Time.now.utc.to_i,
                timestamp: Time.now.utc.to_i,
                order_number: result['orderNo'],
                token: token,
                price: price
              }

              self.response = DriveWealth::Base::Response.new(
                raw: result,
                payload: payload,
                messages: ['success'],
                status: 200
              )
            else
              raise Trading::Errors::OrderException.new(
                type: :error,
                code: resp.code,
                description: result['message'],
                messages: result['message']
              )
            end
          else
            raise Trading::Errors::OrderException.new(
              type: :error,
              code: '403',
              description: 'Order could not be found',
              messages: 'Order could not be found'
            )            
          end
        rescue Exception => e
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: '403',
            description: 'Order could not be found',
            messages: 'Order could not be found'
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
