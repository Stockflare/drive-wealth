# User based actions fro the DriveWealth API
#
#
module DriveWealth
  module Positions
    autoload :Get, 'drive_wealth/positions/get'

    class << self
      #
      # Parse a DriveWealth Login or Verify response into our format
      #
      def parse_result(result)
        if result['status'] == 'SUCCESS'
          #
          # User logged in without any security questions
          #
          positions = result['positions'].map do |p|
            DriveWealth::Base::Position.new(
              quantity: p['quantity'],
              cost_basis: p['costbasis'],
              ticker: p['symbol'],
              instrument_class: p['symbolClass'].downcase,
              change: p['totalGainLossDollar'],
              holding: p['holdingType'].downcase
            ).to_h
          end
          response = DriveWealth::Base::Response.new(raw: result,
                                                 status: 200,
                                                 payload: {
                                                   positions: positions,
                                                   pages: result['totalPages'],
                                                   page: result['currentPage'],
                                                   token: result['token']
                                                 },
                                                 messages: [result['shortMessage']].compact)
        else
          #
          # Login failed
          #
          raise Trading::Errors::PositionException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        response
      end
    end
  end
end
