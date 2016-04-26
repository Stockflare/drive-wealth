require 'spec_helper'

describe DriveWealth do
  it 'has a version number' do
    expect(DriveWealth::VERSION).not_to be nil
  end

  it 'returns brokers' do
    expect(DriveWealth.brokers[:td]).to eq('TD')
  end

  describe '#api_uri' do
    it 'returns ENV - DriveWealth_BASE_URI' do
      expect(DriveWealth.api_uri).to eql ENV['DriveWealth_BASE_URI']
    end
    it 'raises error when not configured' do
      DriveWealth.configure do |config|
        config.api_uri = nil
      end
      expect { DriveWealth.api_uri }.to raise_error(DriveWealth::Errors::ConfigException)
    end
  end
  describe '#api_key' do
    it 'returns ENV - DriveWealth_API_KEY' do
      expect(DriveWealth.api_key).to eql ENV['DriveWealth_API_KEY']
    end
    it 'raises error with no key' do
      DriveWealth.configure do |config|
        config.api_key = nil
      end
      expect { DriveWealth.api_uri }.to raise_error(DriveWealth::Errors::ConfigException)
    end
  end
end
