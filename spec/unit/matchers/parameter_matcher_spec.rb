# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Puppet::ManifestMatchers::ParameterMatcher do
  describe '#matches?' do
    context 'with [1] expected' do
      subject do
        described_class.new(:foo_parameter, [1], :should)
      end

      it 'matches [1]' do
        expect(subject.matches?(foo_parameter: [1])).to be(true)
      end

      it 'does not match []' do
        expect(subject.matches?(foo_parameter: [])).to be(false)
      end

      it 'does not match [1,2,3]' do
        expect(subject.matches?(foo_parameter: [1, 2, 3])).to be(false)
      end

      it 'does not match nil' do
        expect(subject.matches?(foo_parameter: nil)).to be(false)
      end
    end

    context 'with [1,2,3] expected' do
      subject do
        described_class.new(:foo_parameter, [1, 2, 3], :should)
      end

      it 'matches [1,2,3]' do
        expect(subject.matches?(foo_parameter: [1, 2, 3])).to be(true)
      end

      it 'does not match []' do
        expect(subject.matches?(foo_parameter: [])).to be(false)
      end

      it 'does not match nil' do
        expect(subject.matches?(foo_parameter: nil)).to be(false)
      end
    end

    context 'with {"foo" => "bar"} expected' do
      subject do
        described_class.new(:foo_parameter, { 'foo' => 'bar' }, :should)
      end

      it 'matches {"foo" => "bar"}' do
        expect(subject.matches?(foo_parameter: { 'foo' => 'bar' })).to be(true)
      end

      it 'does not match nil' do
        expect(subject.matches?(foo_parameter: nil)).to be(false)
      end

      it 'does not match {}' do
        expect(subject.matches?(foo_parameter: {})).to be(false)
      end

      it 'does not match {"foo" => "baz"}' do
        expect(subject.matches?(foo_parameter: { 'foo' => 'baz' })).to be(false)
      end
    end

    context 'with lambda(){"foo"} expected' do
      subject do
        block = ->(actual) { actual == 'foo' }
        described_class.new(:foo_parameter, block, :should)
      end

      it 'matches "foo"' do
        expect(subject.matches?(foo_parameter: 'foo')).to be(true)
      end

      it 'does not match nil' do
        expect(subject.matches?(foo_parameter: nil)).to be(false)
      end
    end

    context 'with /foo/ expected' do
      subject do
        described_class.new(:foo_parameter, /foo/, :should)
      end

      it 'matches "foo"' do
        expect(subject.matches?(foo_parameter: 'foo')).to be(true)
      end

      it 'does not match nil' do
        expect(subject.matches?(foo_parameter: nil)).to be(false)
      end
    end

    context 'with "foo" expected' do
      subject do
        described_class.new(:foo_parameter, 'foo', :should)
      end

      it 'matches "foo"' do
        expect(subject.matches?(foo_parameter: 'foo')).to be(true)
      end

      it 'does not match nil' do
        expect(subject.matches?(foo_parameter: nil)).to be(false)
      end
    end

    context 'with sensitive("foo") expected' do
      subject do
        described_class.new(:foo_parameter, RSpec::Puppet::Sensitive.new('foo'), :should)
      end

      it 'matches sensitive("foo")' do
        expect(subject.matches?(foo_parameter: RSpec::Puppet::Sensitive.new('foo'))).to be(true)
        expect(subject.errors.size).to eq(0)
      end

      it 'does not match sensitive("bar")' do
        expect(subject.matches?(foo_parameter: RSpec::Puppet::Sensitive.new('bar'))).to be(false)
        expect(subject.errors.size).to eq(1)
        expect(subject.errors[0].message).to eq('foo_parameter set to Sensitive("foo") but it is set to Sensitive("bar")')
      end

      it 'does not matches "foo"' do
        expect(subject.matches?(foo_parameter: 'foo')).to be(false)
        expect(subject.errors.size).to eq(1)
        expect(subject.errors[0].message).to eq('foo_parameter set to Sensitive("foo") but it is set to "foo"')
      end

      it 'does not matches "Sensitive [value redacted]"' do
        expect(subject.matches?(foo_parameter: 'Sensitive [value redacted]')).to be(false)
        expect(subject.errors.size).to eq(1)
        expect(subject.errors[0].message).to eq('foo_parameter set to Sensitive("foo") but it is set to "Sensitive [value redacted]"')
      end
    end
  end
end
