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
