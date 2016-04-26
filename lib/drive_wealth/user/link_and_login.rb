module DriveWealth
  module User
    class LinkAndLogin < DriveWealth::Base
      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        link = DriveWealth::User::Link.new(
          broker: broker,
          username: username,
          password: password
        ).call.response

        self.response = DriveWealth::User::Login.new(
          user_id: link.payload[:user_id],
          user_token: link.payload[:user_token]
        ).call.response

        self
      end
    end
  end
end
