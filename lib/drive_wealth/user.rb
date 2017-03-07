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
    autoload :Subscriptions, 'drive_wealth/user/subscriptions'

    class << self
      #
      # Parse a DriveWealth Login or Verify response into our format
      #
      def parse_result(result, resp)
        if resp.code == '200'
          #
          # User logged in without any security questions
          #
          accounts = []
          if result['accounts']
            accounts = result['accounts'].map do |a|
              DriveWealth::Base::Account.new(
                account_number: a['accountNo'],
                name: a['nickname']
              ).to_h
            end
          end
          response = DriveWealth::Base::Response.new(raw: result,
                                                     status: 200,
                                                     payload: {
                                                       type: 'success',
                                                       token: result['sessionKey'],
                                                       accounts: accounts
                                                     },
                                                     messages: ['success'])

        else
          #
          # Login failed
          #
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: result['message'],
            messages: result['message']
          )
        end

        # pp(response.to_h)
        response
      end

      #
      # Get a User and Account Details from a session token
      #
      def get_user_from_token(token)
        # Heartbeat the session in order to get the user id
        result = DriveWealth::User::Refresh.new(
          token: token
        ).call.response
        user_id = result.raw['userID']

        if user_id
          return result
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: '403',
            description: 'User could not be found',
            messages: 'User could not be found'
          )
        end
      end

      #
      # Get an account from an account_number and token
      #
      def get_account(token, account_number)
        result = get_user_from_token(token)
        user_id = result.raw['userID']

        # Find the correct account
        accounts = result.raw['accounts'].select do |account|
          account['accountNo'] == account_number
        end

        if accounts.count > 0
          # Get the details of the account
          account = accounts[0]

          return {
            user_id: user_id,
            account: account
          }
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: '403',
            description: 'Account could not be found',
            messages: ['Account could not be found']
          )
        end
      end

      #
      # Get All Account Details for a user
      #
      def get_accounts(token)
        result = get_user_from_token(token)
        user_id = result.raw['userID']

        # Find the correct account
        accounts = result.raw['accounts'].select do |account|
          account['accountNo'] == account_number
        end

        if accounts.count > 0
          return {
            user_id: user_id,
            accounts: result.raw['accounts']
          }
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: '403',
            description: 'Accounts could not be found',
            messages: ['Accounts could not be found']
          )
        end
      end
    end
  end
end
