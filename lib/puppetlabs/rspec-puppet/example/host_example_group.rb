# frozen_string_literal: true

module Puppetlabs
  module RSpecPuppet
    module HostExampleGroup
      include Puppetlabs::RSpecPuppet::ManifestMatchers
      include Puppetlabs::RSpecPuppet::Support

      def catalogue
        @catalogue ||= load_catalogue(:host)
      end

      def exported_resources
        -> { load_catalogue(:host, true) }
      end

      def rspec_puppet_cleanup
        @catalogue = nil
      end
    end
  end
end
