module DriveWealth
  module Positions
    class Get < DriveWealth::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :page, Integer, default: 0
      end

      def call
        uri =  URI.join(DriveWealth.api_uri, 'v1/position/getPositions').to_s

        body = {
          token: token,
          accountNumber: account_number,
          page: page,
          apiKey: DriveWealth.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        self.response = DriveWealth::Positions.parse_result(result)

        DriveWealth.logger.info response.to_h
        self
      end
    end
  end
end
