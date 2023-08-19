# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet/adapters'

def context_double(options = {})
  double({ environment: 'rp_puppet' }.merge(options))
end

describe RSpec::Puppet::Adapters::Base do
  describe '#setup_puppet' do
    it 'sets up all settings listed in the settings map' do
      context = context_double
      expected_settings = Hash[*subject.settings_map.map { |r| [r.first, anything] }.flatten]
      expect(Puppet.settings).to receive(:initialize_app_defaults).with(hash_including(expected_settings))
      subject.setup_puppet(context)
    end
  end

  describe 'default settings' do
    before do
      subject.setup_puppet(context_double)
    end

    null_path = windows? ? 'c:/nul/' : '/dev/null'

    %i[vardir codedir rundir logdir hiera_config confdir].each do |setting|
      it "sets #{setting} to #{null_path}" do
        expect(Puppet[setting]).to eq(File.expand_path(null_path))
      end
    end
  end

  it 'sets Puppet[:strict_variables] to false by default' do
    subject.setup_puppet(test_context)
    expect(Puppet[:strict_variables]).to be(false)
  end

  it 'reads the :strict_variables setting' do
    allow(test_context).to receive(:strict_variables).and_return(true)
    subject.setup_puppet(test_context)
    expect(Puppet[:strict_variables]).to be(true)
  end

  it 'overrides the environmentpath set by Puppet::Test::TestHelper' do
    allow(test_context).to receive(:environmentpath).and_return('/path/to/my/environments')
    subject.setup_puppet(test_context)
    expect(Puppet[:environmentpath]).to match(%r{(C:)?/path/to/my/environments})
  end

  describe '#set_setting' do
    describe 'with a context specific setting' do
      it 'sets the Puppet setting based on the example group setting' do
        context = context_double confdir: '/etc/fingerpuppet'
        subject.setup_puppet(context)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/fingerpuppet})
      end

      it 'does not persist settings between example groups' do
        context1 = context_double confdir: '/etc/fingerpuppet'
        context2 = context_double
        subject.setup_puppet(context1)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/fingerpuppet})
        subject.setup_puppet(context2)
        expect(Puppet[:confdir]).not_to match(%r{(C:)?/etc/fingerpuppet})
      end
    end

    describe 'with a global RSpec configuration setting' do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return('/etc/bunraku')
      end

      it 'sets the Puppet setting based on the global configuration value' do
        subject.setup_puppet(context_double)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/bunraku})
      end
    end

    describe 'with both a global RSpec configuration setting and a context specific setting' do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return('/etc/bunraku')
      end

      it 'prefers the context specific setting' do
        context = context_double confdir: '/etc/sockpuppet'
        subject.setup_puppet(context)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/sockpuppet})
      end
    end
  end

  describe '#cached_facter_impl' do
    subject { described_class.send(:cached_facter_impl) }

    before do
      Object.send(:remove_const, :FacterImpl) if defined? FacterImpl
    end

    after do
      Object.send(:remove_const, :FacterImpl) if defined? FacterImpl
    end

    it 'uses facter as default implementation' do
      is_expected.to be(Facter)
    end

    it 'uses the rspec implementation' do
      allow(RSpec.configuration).to receive(:facter_implementation).and_return(:rspec)
      is_expected.to be_a(RSpec::Puppet::FacterTestImpl)
    end

    it 'ensures consistency of FacterImpl in subsequent example groups' do
      allow(RSpec.configuration).to receive(:facter_implementation).and_return(:facter)
      is_expected.to be(Facter)

      allow(RSpec.configuration).to receive(:facter_implementation).and_return(:rspec)
      is_expected.to be(Facter)
    end
  end

  describe '#facter_impl' do
    subject { described_class.send(:facter_impl) }

    it 'supports facter' do
      allow(RSpec.configuration).to receive(:facter_implementation).and_return(:facter)
      is_expected.to be(Facter)
    end

    it 'supports rspec' do
      allow(RSpec.configuration).to receive(:facter_implementation).and_return(:rspec)
      is_expected.to be_a(RSpec::Puppet::FacterTestImpl)
    end

    it 'raises if given an unsupported option' do
      allow(RSpec.configuration).to receive(:facter_implementation).and_return(:salam)
      expect { subject }.to raise_error(RuntimeError, "Unsupported facter_implementation 'salam'")
    end
  end
end
