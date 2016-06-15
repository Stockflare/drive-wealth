module DriveWealth
  module Order
    class Preview < DriveWealth::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_action, Symbol
        attribute :quantity, Float
        attribute :ticker, String
        attribute :price_type, Symbol
        attribute :expiration, Symbol
        attribute :limit_price, Float
        attribute :stop_price, Float
        attribute :amount, Float
      end

      def call
        # Reject any order that has an amount and is not Market
        if amount && amount != 0.0 && price_type != :market
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: 500,
            description: 'Amount only suppoorted for market orders',
            messages: 'Amount only suppoorted for market orders'
          )
        end

        details = DriveWealth::User.get_account(token, account_number)
        account = details[:account]
        user_id = details[:user_id]

        # Get the User details so we can get the Commission amount
        uri = URI.join(DriveWealth.api_uri, "v1/users/#{user_id}")
        req = Net::HTTP::Get.new(uri, initheader = {
                                   'Content-Type' => 'application/json',
                                   'x-mysolomeo-session-key' => token,
                                   'Accept' => 'application/json'
                                 })
        resp = DriveWealth.call_api(uri, req)
        result = JSON.parse(resp.body)

        if resp.code == '200'
          commission_rate = result['commissionRate'].to_f

          # Lookup the Stock in order to get ID and prices
          uri = URI.join(DriveWealth.api_uri, "v1/instruments?symbol=#{ticker}")
          req = Net::HTTP::Get.new(uri, initheader = {
                                     'Content-Type' => 'application/json',
                                     'x-mysolomeo-session-key' => token,
                                     'Accept' => 'application/json'
                                   })

          resp = DriveWealth.call_api(uri, req)

          result = JSON.parse(resp.body)

          if resp.code == '200'
            if result.empty?
              raise Trading::Errors::OrderException.new(
                type: :error,
                code: 403,
                description: 'Broker does not trade this instrument',
                messages: 'Broker does not trade this instrument'
              )
            else
              instrument = result[0]

              if order_action == :buy
                estimated_value = quantity * instrument['rateAsk'].to_f
              else
                estimated_value = quantity * instrument['rateBid'].to_f
              end

              payload = {
                type: 'review',
                ticker: instrument['symbol'].downcase,
                order_action: order_action,
                quantity: quantity,
                expiration: expiration,
                price_label: '',
                value_label: '',
                message: '',
                last_price: instrument['lastTrade'].to_f,
                bid_price: instrument['rateBid'].to_f,
                ask_price: instrument['rateAsk'].to_f,
                timestamp: Time.now.utc.to_i,
                buying_power: account['rtCashAvailForTrading'].to_f,
                estimated_commission: commission_rate,
                estimated_value: estimated_value,
                estimated_total: estimated_value + commission_rate,
                warnings: [],
                must_acknowledge: [],
                amount: amount,
                token: token
              }
              raw = attributes.reject { |k, _v| k == :response }.merge(instrument: instrument,
                                                                       account: account,
                                                                       user_id: user_id,
                                                                       commission: commission_rate,
                                                                       amount: amount)
              self.response = DriveWealth::Base::Response.new(
                raw: raw,
                payload: payload,
                messages: Array('success'),
                status: 200
              )

              # Cache the Order details for the Order Execute Call
              DriveWealth.cache.set("#{DriveWealth::CACHE_PREFIX}_#{token}", response.to_h.to_json, 60)
            end

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
            code: resp.code,
            description: result['message'],
            messages: result['message']
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
