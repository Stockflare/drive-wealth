require 'spec_helper'

describe DriveWealth::User::Link do
  let(:username) { 'dummy' }
  let(:password) { 'pass' }
  let(:broker) { :dummy }

  subject do
    DriveWealth::User::Link.new(
      username: username,
      password: password,
      broker: broker
    ).call.response
  end

  describe 'good credentials' do
    it 'returns token' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.user_token).not_to be_empty
      expect(subject.payload.user_id).not_to be_empty
    end
  end

  describe 'bad credentials' do
    let(:username) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(DriveWealth::Errors::LoginException)
    end
  end
end
