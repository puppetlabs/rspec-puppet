# frozen_string_literal: true

module RSpec::Puppet
  # This module provides support for custom facts
  module FactExampleGroup
    include RSpec::Puppet::FactMatchers

    def subject
      setup_facter
      Facter.fact(self.class.top_level_description)
    end

    def rspec_puppet_cleanup
      Facter.clear
      # TODO: clean LOAD_PATH again?
    end

    private

    # TODO: duplicates adapter
    def modulepath
      if (rspec_modulepath = RSpec.configuration.module_path)
        rspec_modulepath.split(File::PATH_SEPARATOR)
      else
        Puppet[:environmentpath].split(File::PATH_SEPARATOR).map do |path|
          File.join(path, 'fixtures', 'modules')
        end
      end
    end

    def setup_facter
      # TODO: duplicates RSpec::Puppet::Support.setup_puppet
      modulepath.map do |d|
        Dir["#{d}/*/lib/facter"].entries.each do |entry|
          $LOAD_PATH << File.expand_path(File.dirname(entry))
        end
      end

      Facter.clear

      return unless respond_to?(:facts)

      allow(Facter).to receive(:value).and_call_original

      facts.each do |fact, value|
        # TODO: Facter.fact(fact).value?
        allow(Facter).to receive(:value).with(fact.to_sym).and_return(value)
      end
    end
  end
end
