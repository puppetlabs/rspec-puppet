# frozen_string_literal: true
module Puppetlabs
  module RSpecPuppet
    module DefineExampleGroup
      include Puppetlabs::RSpecPuppet::ManifestMatchers
      include Puppetlabs::RSpecPuppet::Support

      def catalogue
        @catalogue ||= load_catalogue(:define)
      end

      def exported_resources
        -> { load_catalogue(:define, true) }
      end

      def rspec_puppet_cleanup
        @catalogue = nil
      end
    end
  end
end
