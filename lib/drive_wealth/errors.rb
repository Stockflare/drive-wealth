module DriveWealth
  module Errors
    class DriveWealthException < Exception
      include Virtus.value_object

      values do
        attribute :type, Symbol
        attribute :code, Integer
        attribute :description, String
        attribute :messages, Array[String]
      end

      def initialize(*args)
        super
        log
      end

      def log
        DriveWealth.logger.error to_h
      end
    end

    class LoginException < DriveWealthException
    end

    class ConfigException < DriveWealthException
    end

    class ConfigException < DriveWealthException
    end

    class PositionException < DriveWealthException
    end

    class OrderException < DriveWealthException
    end
  end
end
