require 'drive_wealth/version'

require 'multi_json'
require 'yajl/json_gem'
require 'virtus'
require 'httparty'

module DriveWealth
  autoload :Base, 'drive_wealth/base'
  autoload :User, 'drive_wealth/user'
  autoload :Errors, 'drive_wealth/errors'
  autoload :Positions, 'drive_wealth/positions'
  autoload :Order, 'drive_wealth/order'

  class << self
    attr_writer :logger, :api_uri, :api_key

    # Helper to configure .
    #
    # @yield [Odin] Yields the {DriveWealth} module.
    def configure
      yield self
    end

    # DriveWealth order statuses
    def order_statuses
      {
        'PENDING' => :pending,
        'OPEN' => :open,
        'FILLED' => :filled,
        'PART_FILLED' => :part_filled,
        'CANCELED' => :cancelled,
        'REJECTED' => :rejected,
        'NOT_FOUND' => :not_found,
        'PENDING_CANCEL' => :pending_cancel,
        'EXPIRED' => :expired
      }
    end

    # DriveWealth brokers as symbols
    def brokers
      {
        td: 'TD',
        etrade: 'Etrade',
        scottrade: 'Scottrade',
        fidelity: 'Fidelity',
        schwab: 'Schwab',
        trade_station: 'TradeStation',
        robinhood: 'Robinhood',
        options_house: 'OptionsHouse',
        tradier: 'Tradier',
        trade_king: 'TradeKing',
        dummy: 'Dummy'
      }
    end

    # DriveWealth order actions
    def order_actions
      {
        buy: 'buy',
        sell: 'sell',
        buy_to_cover: 'buyToCover',
        sell_short: 'sellShort'
      }
    end

    def preview_order_actions
      {
        buy: 'Buy',
        sell: 'Sell',
        buy_to_cover: 'Buy to Cover',
        sell_short: 'Sell Short'
      }
    end

    def order_status_actions
      {
        'BUY' => :buy,
        'BUY_OPEN' => :buy_open,
        'BUY_CLOSE' => :buy_close,
        'BUY_TO_COVER' => :buy_to_cover,
        'SELL' => :sell,
        'SELL_OPEN' => :sell_open,
        'SELL_CLOSE' => :sell_close,
        'SELL_SHORT' => :sell_short,
        'UNKNOWN' => :unknown
      }
    end

    def place_order_actions
      {
        buy: 'Buy',
        sell: 'Sell',
        buy_to_cover: 'BuyToCover',
        sell_short: 'SellShort'
      }
    end

    # DriveWealth price types
    def price_types
      {
        market: 'market',
        limit: 'limit',
        stop_market: 'stopMarket',
        stop_limit: 'stopLimit'
      }
    end

    # DriveWealth order expirations
    def order_expirations
      {
        day: 'day',
        gtc: 'gtc'
      }
    end

    def order_status_expirations
      {
        'DAY' => :day,
        'GTC' => :gtc,
        'GOOD_TROUGH_DATE' => :gtd,
        'UNKNOWN' => :unknown
      }
    end

    def preview_order_expirations
      {
        day: 'Day',
        gtc: 'Good Till Cancelled'
      }
    end

    def api_uri
      if @api_uri
        return @api_uri
      else
        raise DriveWealth::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'api_uri missing',
          messages: ['api_uri configuration variable has not been set']
        )
      end
    end

    def api_key
      if @api_key
        return @api_key
      else
        raise DriveWealth::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'api_key missing',
          messages: ['api_key configuration variable has not been set']
        )
      end
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end
end
