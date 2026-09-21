# frozen_string_literal: true

module RSpec::Puppet
  module FactMatchers
    extend RSpec::Matchers::DSL

    matcher :have_value do |expected|
      match { |actual| actual.value == expected }
    end
  end
end
