# frozen_string_literal: true
module Puppetlabs
  module RSpecPuppet
    module TypeAliasExampleGroup
      include Puppetlabs::RSpecPuppet::TypeAliasMatchers
      include Puppetlabs::RSpecPuppet::Support

      def catalogue(test_value)
        load_catalogue(:type_alias, false, test_value: test_value)
      end

      def subject
        ->(test_value) { catalogue(test_value) }
      end
    end
  end
end
