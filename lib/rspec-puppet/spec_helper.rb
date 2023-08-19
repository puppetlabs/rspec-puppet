# frozen_string_literal: true

require 'rspec-puppet'

RSpec.configure do |c|
  c.module_path     = File.join(__dir__, 'fixtures', 'modules')
  c.environmentpath = __dir__
end
