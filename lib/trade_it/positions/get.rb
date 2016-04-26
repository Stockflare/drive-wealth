module TradeIt
  module Positions
    class Get < TradeIt::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :page, Integer, default: 0
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/position/getPositions').to_s

        body = {
          token: token,
          accountNumber: account_number,
          page: page,
          apiKey: TradeIt.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        self.response = TradeIt::Positions.parse_result(result)

        TradeIt.logger.info response.to_h
        self
      end
    end
  end
end
