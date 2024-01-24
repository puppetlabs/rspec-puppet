# frozen_string_literal: true

if ENV['COVERAGE']
  begin
    require 'simplecov'
    require 'simplecov-console'

    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console
    ]

    SimpleCov.start do
      add_filter %r{^/spec/}
      add_filter %r{^/vendor/}

      add_filter '/docs'
      add_filter 'lib/rspec-puppet/version.rb'
    end
  rescue LoadError
    raise 'Add the simplecov & simplecov-console gems to Gemfile to enable this task'
  end
end

require 'rspec-puppet'

# TODO: drop?
def windows?
  return @windowsp unless @windowsp.nil?

  @windowsp = RSpec::Support::OS.windows?
end

def sensitive?
  defined?(Puppet::Pops::Types::PSensitiveType)
end

RSpec.configure do |c|
  c.module_path     = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'modules')
  c.environmentpath = File.join(Dir.pwd, 'spec')
  c.manifest        = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'manifests', 'site.pp')

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(0)
  end
end
