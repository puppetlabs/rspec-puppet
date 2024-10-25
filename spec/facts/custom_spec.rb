# frozen_string_literal: true

require 'spec_helper'

describe 'custom' do
  it { is_expected.not_to be_nil }
  it { is_expected.to have_value('bar') }

  context 'with overridden' do
    let(:facts) do
      {
        myfact: 'set'
      }
    end

    it { is_expected.to have_value('foo') }
  end

  context 'with unrelated fact overridden' do
    let(:facts) do
      {
        kernel: 'unix'
      }
    end

    it { is_expected.to have_value('bar') }
  end
end
