require 'active_model'
require 'json'

require "memory_record/version"
require "memory_record/associations"
require 'memory_record/associations/belongs_to'
require 'memory_record/associations/has_many'
require 'memory_record/associations/has_many_through'
require "memory_record/crud"
require "memory_record/error"
require "memory_record/field"
require "memory_record/scope"
require "memory_record/collection"
require "memory_record/transactions"
require "memory_record/auto_id"
require "memory_record/seed"
require "memory_record/base"

require 'memory_record/will_paginate' if defined?(WillPaginate)

module MemoryRecord
  
  class << self
    
    attr_accessor :seed_path
    
  end
  
end

possible_seed_paths = [File.join('db', 'memory_record')]
possible_seed_paths.each do |path|
  if File.exists?(path)
    MemoryRecord.seed_path = path
    break
  end
end
