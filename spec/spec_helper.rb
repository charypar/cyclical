require 'rubygems'
require 'bundler/setup'

require 'cyclical'
include Cyclical

RSpec.configure do |config|
  config.mock_with :rspec
end

