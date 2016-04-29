module DriveWealth
  module Positions
    class Get < DriveWealth::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :page, Integer, default: 0
      end

      def call

        blotter = DriveWealth::User::Account.new(token: token, account_number: account_number).call.response
        positions = []
        blotter.raw['equity']['equityPositions'].each do |p|
          position = DriveWealth::Base::Position.new(
            quantity: p['openQty'].to_f,
            cost_basis: p['costBasis'].to_f,
            ticker: p['symbol'].downcase,
            instrument_class: 'EQUITY_OR_ETF'.downcase,
            change: p['unrealizedPL'].to_f,
            holding: 'LONG'.downcase
          ).to_h
          positions.push position
        end

        self.response = DriveWealth::Base::Response.new(raw: blotter.raw,
                                               status: 200,
                                               payload: {
                                                 positions: positions,
                                                 pages: 1,
                                                 page: 0,
                                                 token: token
                                               },
                                               messages: ['success'])

        # pp response.to_h
        DriveWealth.logger.info response.to_h
        self
      end
    end
  end
end
