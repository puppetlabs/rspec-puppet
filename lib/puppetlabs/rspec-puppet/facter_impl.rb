# frozen_string_literal: true
module Puppetlabs
  module RSpecPuppet
    # Implements a simple hash-based version of Facter to be used in module tests
    # that use rspec-puppet.
    class FacterTestImpl
      def initialize
        @facts = {}
      end

      def value(fact_name)
        @facts.dig(*fact_name.to_s.split('.'))
      rescue TypeError
        nil
      end

      def clear
        @facts.clear
      end

      def to_hash
        @facts
      end

      def add(name, _options = {}, &block)
        raise 'Facter.add expects a block' unless block

        @facts[name.to_s] = instance_eval(&block)
      end

      # noop methods
      def debugging(arg); end

      def reset; end

      def search(*paths); end

      def setup_logging; end

      private

      def setcode(string = nil, &block)
        if block
          yield
        else
          string
        end
      end
    end
  end
end