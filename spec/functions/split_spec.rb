# frozen_string_literal: true

require 'spec_helper'

describe 'split' do
  it { is_expected.to run.with_params('aoeu', 'o').and_return(%w[a eu]) }
  it { is_expected.not_to run.with_params('foo').and_raise_error(Puppet::DevError) }

  expected_error = ArgumentError
  expected_error_message = /expects \d+ arguments/

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error) }

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error, expected_error_message) }

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error_message) }

  it {
    expect do
      expect(subject).to run.with_params('foo').and_raise_error(/definitely no match/)
    end.to raise_error RSpec::Expectations::ExpectationNotMetError
  }

  context 'after including a class' do
    let(:pre_condition) { 'include ::sysctl::common' }

    it { is_expected.to run.with_params('aoeu', 'o').and_return(%w[a eu]) }
  end
end
