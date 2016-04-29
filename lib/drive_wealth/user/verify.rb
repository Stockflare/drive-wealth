module DriveWealth
  module User
    class Verify < DriveWealth::Base
      values do
        attribute :token, String
        attribute :answer, String
      end
      # DriveWealth does not support this interraction, we will simply get an return the current session

      def call
        self.response = DriveWealth::User::Login.new(
          user_id: '',
          user_token: token
        ).call.response

        self
      end
    end
  end
end
