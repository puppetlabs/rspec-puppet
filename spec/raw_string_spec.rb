# frozen_string_literal: true

require 'puppetlabs/rspec-puppet/raw_string'

describe Puppetlabs::RSpecPuppet::RawString do
  describe '#inspect' do
    it 'returns the raw string when doing an inspect' do
      expect(described_class.new('my_raw_string').inspect).to eq('my_raw_string')
    end
  end
end
