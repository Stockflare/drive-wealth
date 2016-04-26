# User based actions fro the DriveWealth API
#
#
module DriveWealth
  module User
    autoload :Link, 'drive_wealth/user/link'
    autoload :Login, 'drive_wealth/user/login'
    autoload :LinkAndLogin, 'drive_wealth/user/link_and_login'
    autoload :Verify, 'drive_wealth/user/verify'
    autoload :Logout, 'drive_wealth/user/logout'
    autoload :Refresh, 'drive_wealth/user/refresh'
    autoload :Account, 'drive_wealth/user/account'

    class << self
      #
      # Parse a DriveWealth Login or Verify response into our format
      #
      def parse_result(result)
        if result['status'] == 'SUCCESS'
          #
          # User logged in without any security questions
          #
          accounts = []
          if result['accounts']
            accounts = result['accounts'].map do |a|
              DriveWealth::Base::Account.new(
                account_number: a['accountNumber'],
                name: a['name']
              ).to_h
            end
          end
          response = DriveWealth::Base::Response.new(raw: result,
                                                 status: 200,
                                                 payload: {
                                                   type: 'success',
                                                   token: result['token'],
                                                   accounts: accounts
                                                 },
                                                 messages: [result['shortMessage']].compact)
        elsif result['status'] == 'INFORMATION_NEEDED'
          #
          # User Asked for security question
          #
          if result['challengeImage']
            data = {
              encoded: result['challengeImage']
            }
          else
            data = {
              question: result['securityQuestion'],
              answers: result['securityQuestionOptions']
            }
          end
          response = DriveWealth::Base::Response.new(raw: result,
                                                 status: 200,
                                                 payload: {
                                                   type: 'verify',
                                                   challenge: result['challengeImage'] ? 'image' : 'question',
                                                   token: result['token'],
                                                   data: data
                                                 },
                                                 messages: [result['shortMessage']].compact)
        else
          #
          # Login failed
          #
          raise DriveWealth::Errors::LoginException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end

        # pp(response.to_h)
        response
      end
    end
  end
end
