# frozen_string_literal: true

require 'spec_helper_unit'

describe RSpec::Puppet::ManifestMatchers::CreateGeneric do
  subject(:matcher) { described_class.new(:contain_file, '/tmp/foo') }

  describe '#initialize' do
    it 'strips the contain_ prefix' do
      expect(matcher.instance_variable_get(:@exp_resource_type)).to eq('file')
    end

    context 'with a create_ prefix' do
      subject(:matcher) { described_class.new(:create_exec, 'some command') }

      it 'strips the create_ prefix' do
        expect(matcher.instance_variable_get(:@exp_resource_type)).to eq('exec')
      end
    end

    context 'with a namespaced type using __' do
      subject(:matcher) { described_class.new(:contain_foo__bar, 'title') }

      it 'converts __ to :: in the referenced type' do
        expect(matcher.instance_variable_get(:@referenced_type)).to eq('Foo::Bar')
      end
    end
  end

  describe '#with' do
    it 'adds parameters to expected params and returns self' do
      result = matcher.with(ensure: 'present', owner: 'root')
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@expected_params)).to include([:ensure, 'present'])
    end
  end

  describe '#only_with' do
    it 'sets the expected param count and returns self' do
      result = matcher.only_with(ensure: 'present', owner: 'root')
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@expected_params_count)).to eq(2)
    end

    it 'accumulates count across multiple calls' do
      matcher.only_with(ensure: 'present')
      matcher.only_with(owner: 'root')
      expect(matcher.instance_variable_get(:@expected_params_count)).to eq(2)
    end
  end

  describe '#without' do
    it 'adds parameters to expected undef params and returns self' do
      result = matcher.without(:owner)
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@expected_undef_params)).to include(:owner)
    end
  end

  describe '#that_notifies' do
    it 'adds the resource to notifies and returns self' do
      result = matcher.that_notifies('Service[nginx]')
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@notifies)).to include('Service[nginx]')
    end

    it 'accepts an array of resources' do
      matcher.that_notifies(['Service[nginx]', 'Service[apache]'])
      expect(matcher.instance_variable_get(:@notifies)).to contain_exactly('Service[nginx]', 'Service[apache]')
    end
  end

  describe '#that_subscribes_to' do
    it 'adds the resource to subscribes and returns self' do
      result = matcher.that_subscribes_to('File[/etc/nginx.conf]')
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@subscribes)).to include('File[/etc/nginx.conf]')
    end
  end

  describe '#that_requires' do
    it 'adds the resource to requires and returns self' do
      result = matcher.that_requires('Package[nginx]')
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@requires)).to include('Package[nginx]')
    end
  end

  describe '#that_comes_before' do
    it 'adds the resource to befores and returns self' do
      result = matcher.that_comes_before('Exec[reload]')
      expect(result).to be(matcher)
      expect(matcher.instance_variable_get(:@befores)).to include('Exec[reload]')
    end
  end

  describe '#method_missing' do
    context 'with a with_ prefixed method' do
      it 'adds the parameter to expected_params and returns self' do
        result = matcher.with_ensure('present')
        expect(result).to be(matcher)
        expect(matcher.instance_variable_get(:@expected_params)).to include(['ensure', 'present'])
      end
    end

    context 'with an only_with_ prefixed method' do
      it 'increments expected_params_count and returns self' do
        result = matcher.only_with_ensure('present')
        expect(result).to be(matcher)
        expect(matcher.instance_variable_get(:@expected_params_count)).to eq(1)
        expect(matcher.instance_variable_get(:@expected_params)).to include(['ensure', 'present'])
      end

      it 'accumulates count across multiple calls' do
        matcher.only_with_ensure('present')
        matcher.only_with_owner('root')
        expect(matcher.instance_variable_get(:@expected_params_count)).to eq(2)
      end
    end

    context 'with a without_ prefixed method' do
      it 'adds the parameter to expected_undef_params and returns self' do
        result = matcher.without_owner('nobody')
        expect(result).to be(matcher)
        expect(matcher.instance_variable_get(:@expected_undef_params)).to include(['owner', 'nobody'])
      end
    end

    context 'with an unrecognised method' do
      it 'raises NoMethodError' do
        expect { matcher.some_unknown_method }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#description' do
    context 'with no constraints' do
      it 'describes only the resource' do
        expect(matcher.description).to eq('contain File[/tmp/foo]')
      end
    end

    context 'with a with_ parameter' do
      before { matcher.with_ensure('present') }

      it 'includes the parameter' do
        expect(matcher.description).to include('ensure => "present"')
      end
    end

    context 'with a without_ parameter whose value is nil' do
      before { matcher.without_owner(nil) }

      it 'describes it as undefined' do
        expect(matcher.description).to include('owner undefined')
      end
    end

    context 'with an only_with parameter count' do
      before { matcher.only_with_ensure('present') }

      it 'includes the exact count' do
        expect(matcher.description).to include('exactly 1 parameters')
      end
    end

    context 'with a Regexp parameter value' do
      before { matcher.with_content(/hello/) }

      it 'uses ~ as the value separator' do
        expect(matcher.description).to include('content =~ /hello/')
      end
    end

    context 'with a string content parameter' do
      before { matcher.with_content('hello') }

      it 'describes it as a supplied string' do
        expect(matcher.description).to include('content  supplied string')
      end
    end

    context 'with a that_notifies relationship' do
      before { matcher.that_notifies('Service[nginx]') }

      it 'includes the relationship' do
        expect(matcher.description).to include('that notifies Service[nginx]')
      end
    end

    context 'with multiple that_notifies resources' do
      before { matcher.that_notifies(['Service[nginx]', 'Service[apache]']) }

      it 'joins them with "and"' do
        expect(matcher.description).to match(/Service\[nginx\].*and Service\[apache\]/)
      end
    end

    context 'with a that_subscribes_to relationship' do
      before { matcher.that_subscribes_to('File[/etc/nginx.conf]') }

      it 'includes the relationship' do
        expect(matcher.description).to include('that subscribes to File[/etc/nginx.conf]')
      end
    end

    context 'with a that_requires relationship' do
      before { matcher.that_requires('Package[nginx]') }

      it 'includes the relationship' do
        expect(matcher.description).to include('that requires Package[nginx]')
      end
    end

    context 'with a that_comes_before relationship' do
      before { matcher.that_comes_before('Exec[reload]') }

      it 'includes the relationship' do
        expect(matcher.description).to include('that comes before Exec[reload]')
      end
    end
  end

  describe '#failure_message' do
    it 'includes the resource type and title' do
      expect(matcher.failure_message).to include('File[/tmp/foo]')
    end

    it 'indicates the catalogue should contain the resource' do
      expect(matcher.failure_message).to include('would contain')
    end
  end

  describe '#failure_message_when_negated' do
    it 'includes the resource type and title' do
      expect(matcher.failure_message_when_negated).to include('File[/tmp/foo]')
    end

    it 'indicates the catalogue should not contain the resource' do
      expect(matcher.failure_message_when_negated).to include('would not contain')
    end
  end

  describe '#diffable?' do
    it { expect(matcher.diffable?).to be(true) }
  end

  describe '#supports_block_expectations' do
    it { expect(matcher.supports_block_expectations).to be(true) }
  end

  describe '#supports_value_expectations' do
    it { expect(matcher.supports_value_expectations).to be(true) }
  end

  describe '#expected and #actual' do
    it 'return empty strings when there are no errors' do
      expect(matcher.expected).to eq('')
      expect(matcher.actual).to eq('')
    end
  end
end
