# frozen_string_literal: true

if ENV['COVERAGE']
  begin
    require 'simplecov'
    require 'simplecov-console'

    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console
    ]

    if ENV['CI'] == 'true'
      require 'codecov'
      SimpleCov.formatters << SimpleCov::Formatter::Codecov
    end

    SimpleCov.start do
      add_filter %r{^/spec/}
      add_filter %r{^/vendor/}

      add_filter '/docs'
      add_filter 'lib/rspec-puppet/version.rb'
    end
  rescue LoadError
    raise 'Add the simplecov, simplecov-console, codecov gems to Gemfile to enable this task'
  end
end

require 'rspec-puppet'
