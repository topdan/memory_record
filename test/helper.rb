require "rubygems"
require "bundler/setup"
require 'test/unit'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'memory_record'
require 'memory_record/will_paginate'
