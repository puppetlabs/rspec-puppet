# frozen_string_literal: true

module RSpec::Puppet
  module HostExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

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
