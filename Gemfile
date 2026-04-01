# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

def location_for(place_or_version, fake_version = nil)
  git_url_regex = /\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?/
  file_url_regex = %r{\Afile://(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

group :development do
  gem 'fuubar'
  gem 'pry'
  gem 'pry-stack_explorer'
end

group :test do
  # rubocop:disable Bundler/DuplicatedGem
  if ENV['PUPPET_GEM_VERSION']&.match?(/\A[~> ]*9\./)
    gem 'facter', git: 'https://github.com/puppetlabs/facter-private', tag: '4.18.0', require: false
    gem 'puppet', git: 'https://github.com/puppetlabs/puppet-private', branch: 'main', require: false
    gem 'syslog', require: false
    gem 'win32ole', require: false, platforms: %i[mingw x64_mingw mswin]
  else
    gem 'facter', *location_for(ENV.fetch('FACTER_GEM_VERSION', nil))
    source 'https://rubygems-puppetcore.puppet.com' do
      gem 'puppet', '~> 8.0', require: false
    end
  end
  # rubocop:enable Bundler/DuplicatedGem

  gem 'json_pure'
  gem 'sync'

  gem 'rake', require: false

  gem 'rspec', '~> 3.0', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false

  gem 'win32-taskscheduler', platforms: %i[mingw x64_mingw mswin]
end
