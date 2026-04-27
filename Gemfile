# frozen_string_literal: true

# For puppetcore, set GEM_SOURCE_PUPPETCORE = 'https://rubygems-puppetcore.puppet.com'
gemsource_default = ENV['GEM_SOURCE'] || 'https://rubygems.org'
gemsource_puppetcore = if ENV['PUPPET_FORGE_TOKEN']
  'https://rubygems-puppetcore.puppet.com'
else
  ENV['GEM_SOURCE_PUPPETCORE'] || gemsource_default
end
source gemsource_default

gemspec

def location_for(place_or_version, fake_version = nil, opts = {})
  git_url_regex = /\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?/
  file_url_regex = %r{\Afile://(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }.merge(opts)]
  end
end

group :development do
  gem 'fuubar'
  gem 'pry'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'facter', *location_for(ENV.fetch('FACTER_GEM_VERSION', nil), nil, { source: gemsource_puppetcore })
  gem 'puppet', *location_for(ENV.fetch('PUPPET_GEM_VERSION', nil), nil, { source: gemsource_puppetcore })

  gem 'json_pure'
  gem 'sync'

  gem 'rake', require: false

  gem 'rspec', '~> 3.0', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false

  gem 'win32-taskscheduler', platforms: %i[mingw x64_mingw mswin]
end
