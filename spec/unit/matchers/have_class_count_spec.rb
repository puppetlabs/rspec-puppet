# frozen_string_literal: true

require 'spec_helper'

describe 'Puppetlabs::RSpecPuppet::ManifestMatchers.have_class_count' do
  subject(:example_group) { Class.new { extend Puppetlabs::RSpecPuppet::ManifestMatchers } }

  let(:expected) { 123 }

  after do
    example_group.have_class_count(expected)
  end

  it 'initialises a CountGeneric matcher for Class resources' do
    expect(Puppetlabs::RSpecPuppet::ManifestMatchers::CountGeneric).to receive(:new).with('class', expected)
  end
end
