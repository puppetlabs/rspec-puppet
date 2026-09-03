# frozen_string_literal: true

require 'spec_helper_unit'

describe RSpec::Puppet::ManifestMatchers do
  let(:test_class) { Class.new { include RSpec::Puppet::ManifestMatchers } }
  subject(:instance) { test_class.new }

  describe '#method_missing' do
    context 'with a contain_ prefixed method' do
      it 'returns a CreateGeneric matcher' do
        expect(instance.contain_file('/tmp/foo')).to be_a(RSpec::Puppet::ManifestMatchers::CreateGeneric)
      end
    end

    context 'with a create_ prefixed method' do
      it 'returns a CreateGeneric matcher' do
        expect(instance.create_exec('some command')).to be_a(RSpec::Puppet::ManifestMatchers::CreateGeneric)
      end
    end

    context 'with a have_.*_count method' do
      it 'returns a CountGeneric matcher for a specific type' do
        expect(instance.have_file_resource_count(3)).to be_a(RSpec::Puppet::ManifestMatchers::CountGeneric)
      end

      it 'returns a CountGeneric matcher for classes' do
        expect(instance.have_class_count(2)).to be_a(RSpec::Puppet::ManifestMatchers::CountGeneric)
      end
    end

    context 'with :compile' do
      it 'returns a Compile matcher' do
        expect(instance.compile).to be_a(RSpec::Puppet::ManifestMatchers::Compile)
      end
    end

    context 'with an unrecognised method' do
      it 'raises NoMethodError' do
        expect { instance.some_unknown_method }.to raise_error(NoMethodError)
      end
    end
  end
end

describe RSpec::Puppet::FunctionMatchers do
  let(:test_class) { Class.new { include RSpec::Puppet::FunctionMatchers } }
  subject(:instance) { test_class.new }

  describe '#method_missing' do
    context 'with :run' do
      it 'returns a Run matcher' do
        expect(instance.run).to be_a(RSpec::Puppet::FunctionMatchers::Run)
      end
    end

    context 'with an unrecognised method' do
      it 'raises NoMethodError' do
        expect { instance.some_unknown_method }.to raise_error(NoMethodError)
      end
    end
  end
end

describe RSpec::Puppet::TypeMatchers do
  let(:test_class) { Class.new { include RSpec::Puppet::TypeMatchers } }
  subject(:instance) { test_class.new }

  describe '#method_missing' do
    context 'with :be_valid_type' do
      it 'returns a TypeMatchers::CreateGeneric matcher' do
        expect(instance.be_valid_type).to be_a(RSpec::Puppet::TypeMatchers::CreateGeneric)
      end
    end

    context 'with an unrecognised method' do
      it 'raises NoMethodError' do
        expect { instance.some_unknown_method }.to raise_error(NoMethodError)
      end
    end
  end
end
