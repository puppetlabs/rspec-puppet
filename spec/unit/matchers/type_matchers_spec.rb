# frozen_string_literal: true

require 'spec_helper_unit'

describe RSpec::Puppet::TypeMatchers::CreateGeneric do
  subject(:matcher) { described_class.new }

  describe '#with_provider' do
    it 'sets the expected provider and returns self' do
      result = matcher.with_provider(:posix)
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@exp_provider)).to eq(:posix)
    end
  end

  describe '#with_properties' do
    it 'adds to expected properties and returns self' do
      result = matcher.with_properties([:ensure, :content])
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@exp_properties)).to contain_exactly(:ensure, :content)
    end

    it 'accepts a single value' do
      matcher.with_properties(:ensure)
      expect(matcher.instance_variable_get(:@exp_properties)).to include(:ensure)
    end

    it 'deduplicates on repeated calls' do
      matcher.with_properties(:ensure)
      matcher.with_properties(:ensure)
      expect(matcher.instance_variable_get(:@exp_properties).count(:ensure)).to eq(1)
    end
  end

  describe '#with_parameters' do
    it 'adds to expected parameters and returns self' do
      result = matcher.with_parameters([:name, :path])
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@exp_parameters)).to contain_exactly(:name, :path)
    end

    it 'accepts a single value' do
      matcher.with_parameters(:name)
      expect(matcher.instance_variable_get(:@exp_parameters)).to include(:name)
    end
  end

  describe '#with_features' do
    it 'adds to expected features and returns self' do
      result = matcher.with_features([:manages_symlinks])
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@exp_features)).to include(:manages_symlinks)
    end

    it 'accepts a single value' do
      matcher.with_features(:manages_symlinks)
      expect(matcher.instance_variable_get(:@exp_features)).to include(:manages_symlinks)
    end
  end

  describe '#with_set_attributes' do
    it 'merges params and returns self' do
      result = matcher.with_set_attributes(ensure: 'present', owner: 'root')
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@params_with_values)).to include(ensure: 'present', owner: 'root')
    end

    it 'accumulates across multiple calls' do
      matcher.with_set_attributes(ensure: 'present')
      matcher.with_set_attributes(owner: 'root')
      expect(matcher.instance_variable_get(:@params_with_values)).to include(ensure: 'present', owner: 'root')
    end
  end

  describe '#with_defaults' do
    it 'merges defaults and returns self' do
      result = matcher.with_defaults(provider: :posix)
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@exp_defaults)).to include(provider: :posix)
    end

    it 'accumulates across multiple calls' do
      matcher.with_defaults(provider: :posix)
      matcher.with_defaults(foo: :bar)
      expect(matcher.instance_variable_get(:@exp_defaults)).to include(provider: :posix, foo: :bar)
    end
  end

  describe '#description' do
    it { expect(matcher.description).to eq('be a valid type') }
  end

  describe '#failure_message' do
    it { expect(matcher.failure_message).to match(/Not a valid type/) }
  end

  describe '#match_default_provider' do
    context 'when no provider is expected' do
      it 'returns true' do
        resource = double('resource', :[] => nil)
        expect(matcher.match_default_provider(resource)).to be(true)
      end
    end

    context 'when the provider matches' do
      before { matcher.with_provider(:posix) }

      it 'returns true' do
        resource = double('resource', :[] => :posix)
        expect(matcher.match_default_provider(resource)).to be(true)
      end
    end

    context 'when the provider does not match' do
      before { matcher.with_provider(:posix) }

      it 'returns false and records an error' do
        resource = double('resource', :[] => :windows)
        result = matcher.match_default_provider(resource)
        expect(result).to be(false)
        expect(matcher.instance_variable_get(:@errors)).not_to be_empty
      end
    end
  end

  describe '#match_default_values' do
    it 'returns true (not yet implemented)' do
      expect(matcher.match_default_values(double)).to be(true)
    end
  end
end
