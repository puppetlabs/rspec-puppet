# frozen_string_literal: true

require 'spec_helper_unit'

describe RSpec::Puppet::Errors::MatchError do
  describe 'attributes' do
    subject(:error) { described_class.new(:owner, 'root', 'user', true) }

    it { expect(error.param).to eq(:owner) }
    it { expect(error.expected).to eq('root') }
    it { expect(error.actual).to eq('user') }
    it { expect(error.negative).to be(true) }
  end

  describe '#to_s' do
    subject(:error) { described_class.new(:owner, 'root', 'user', false) }

    it 'delegates to #message' do
      expect(error.to_s).to eq(error.message)
    end
  end

  describe '#message' do
    context 'when param is content and expected is a String' do
      context 'and negative is false' do
        subject(:error) { described_class.new(:content, 'expected', 'actual', false) }

        it { expect(error.message).to eq('content set to supplied string') }
      end

      context 'and negative is true' do
        subject(:error) { described_class.new(:content, 'expected', 'actual', true) }

        it { expect(error.message).to eq('content not set to supplied string') }
      end
    end

    context 'when param is not content' do
      context 'and negative is false' do
        subject(:error) { described_class.new(:owner, 'root', 'user', false) }

        it { expect(error.message).to eq('owner set to "root" but it is set to "user"') }
      end

      context 'and negative is true' do
        subject(:error) { described_class.new(:owner, 'root', 'user', true) }

        it { expect(error.message).to eq('owner not set to "root" but it is set to "user"') }
      end
    end
  end
end

describe RSpec::Puppet::Errors::RegexpMatchError do
  describe '#message' do
    context 'when negative is false' do
      subject(:error) { described_class.new(:owner, /root/, 'user', false) }

      it { expect(error.message).to eq('owner matching /root/ but its value of "user" does not') }
    end

    context 'when negative is true' do
      subject(:error) { described_class.new(:owner, /root/, 'root', true) }

      it { expect(error.message).to eq('owner not matching /root/ but its value of "root" does') }
    end
  end
end

describe RSpec::Puppet::Errors::ProcMatchError do
  describe '#message' do
    context 'when negative is false' do
      subject(:error) { described_class.new(:owner, true, false, false) }

      it { expect(error.message).to eq('owner passed to the block would return `true` but it is `false`') }
    end

    context 'when negative is true' do
      subject(:error) { described_class.new(:owner, true, true, true) }

      it { expect(error.message).to eq('owner passed to the block would not return `true` but it did') }
    end
  end
end

describe RSpec::Puppet::Errors::BeforeRelationshipError do
  subject(:error) { described_class.new('File[/tmp/foo]', 'Exec[bar]') }

  it { expect(error.from).to eq('File[/tmp/foo]') }
  it { expect(error.to).to eq('Exec[bar]') }

  describe '#message' do
    it { expect(error.message).to eq('that comes before Exec[bar]') }
  end

  describe '#to_s' do
    it { expect(error.to_s).to eq('that comes before Exec[bar]') }
  end
end

describe RSpec::Puppet::Errors::RequireRelationshipError do
  subject(:error) { described_class.new('File[/tmp/foo]', 'Package[vim]') }

  describe '#message' do
    it { expect(error.message).to eq('that requires Package[vim]') }
  end
end

describe RSpec::Puppet::Errors::NotifyRelationshipError do
  subject(:error) { described_class.new('File[/tmp/foo]', 'Service[nginx]') }

  describe '#message' do
    it { expect(error.message).to eq('that notifies Service[nginx]') }
  end
end

describe RSpec::Puppet::Errors::SubscribeRelationshipError do
  subject(:error) { described_class.new('Service[nginx]', 'File[/etc/nginx.conf]') }

  describe '#message' do
    it { expect(error.message).to eq('that is subscribed to File[/etc/nginx.conf]') }
  end
end
