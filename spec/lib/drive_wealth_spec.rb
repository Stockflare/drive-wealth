require 'spec_helper'

describe DriveWealth do
  it 'has a version number' do
    expect(DriveWealth::VERSION).not_to be nil
  end

  it 'returns brokers' do
    expect(DriveWealth.brokers[:drive_wealth]).to eq('DriveWealth')
  end

  describe '#api_uri' do
    it 'returns ENV - DRIVE_WEALTH_BASE_URI' do
      expect(DriveWealth.api_uri).to eql ENV['DRIVE_WEALTH_BASE_URI']
    end
    it 'raises error when not configured' do
      DriveWealth.configure do |config|
        config.api_uri = nil
      end
      expect { DriveWealth.api_uri }.to raise_error(Trading::Errors::ConfigException)
    end
  end
  describe '#referral_code' do
    it 'returns ENV - DriveWealth_BASE_URI' do
      expect(DriveWealth.referral_code).to eql ENV['DRIVE_WEALTH_REFERRAL_CODE']
    end
    it 'raises error when not configured' do
      DriveWealth.configure do |config|
        config.referral_code = nil
      end
      expect { DriveWealth.referral_code }.to raise_error(Trading::Errors::ConfigException)
    end
  end
  describe '#language' do
    it 'returns ENV - DRIVE_WEALTH_LANGUAGE' do
      expect(DriveWealth.language).to eql ENV['DRIVE_WEALTH_LANGUAGE']
    end
    it 'raises error when not configured' do
      DriveWealth.configure do |config|
        config.language = nil
      end
      expect { DriveWealth.language }.to raise_error(Trading::Errors::ConfigException)
    end
  end

  # describe '#cache' do
  #   it 'returns An instance of Memcached' do
  #     expect(DriveWealth.cache).to eql an_instance_of(Memcached)
  #   end
  #   it 'raises error when not configured' do
  #     DriveWealth.configure do |config|
  #       config.cache = nil
  #     end
  #     expect { DriveWealth.cache }.to raise_error(Trading::Errors::ConfigException)
  #   end
  # end
end
