require 'spec_helper'

describe DriveWealth::User::Subscriptions::Cancel do
  let(:username) { 'stockflare.ff' }
  let(:password) { 'passw0rd' }
  let(:broker) { :drive_wealth }
  let!(:user) do
    DriveWealth::User::LinkAndLogin.new(
      username: username,
      password: password,
      broker: broker
    ).call.response.payload
  end
  let(:token) { user[:token] }
  let(:account_number) { user.accounts[0].account_number }

  subject do
    DriveWealth::User::Subscriptions::Cancel.new(
      token: token,
      account_number: account_number
    ).call.response
  end

  describe 'good logout' do
    it 'returns token' do
    puts subject.payload
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.token).to eql token
    end
  end

  describe 'bad token' do
    let(:token) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(Trading::Errors::LoginException)
    end
  end
end
