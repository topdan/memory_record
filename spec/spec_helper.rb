require 'rubygems'
require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'rspec'
require 'memory_record'

require 'will_paginate/collection'
require 'memory_record/will_paginate' # optional

RSpec.configure do |config|
  
end