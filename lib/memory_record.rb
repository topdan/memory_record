require 'active_model'
require 'json'

require "memory_record/version"

require "memory_record/associations"
require "memory_record/association/relation"
require "memory_record/association/base"
require 'memory_record/association/belongs_to'
require 'memory_record/association/has_many'
require 'memory_record/association/has_many_through'

require 'memory_record/attribute/base'
require 'memory_record/attribute/boolean_type'
require 'memory_record/attribute/date_type'
require 'memory_record/attribute/date_time_type'
require 'memory_record/attribute/float_type'
require 'memory_record/attribute/integer_type'
require 'memory_record/attribute/string_type'
require 'memory_record/attribute/time_type'
require "memory_record/attribute/generator"

require "memory_record/database"
require "memory_record/table"
require "memory_record/row"

require "memory_record/error"
require "memory_record/attribute"
require "memory_record/collection"
require "memory_record/transactions"
require "memory_record/timestamps"
require "memory_record/base"

require 'memory_record/will_paginate' if defined?(WillPaginate)

module MemoryRecord
  
  class << self
    
    attr_accessor :seed_path, :database
    
  end
  
end

possible_seed_paths = [File.join('db', 'memory_record')]
possible_seed_paths.each do |path|
  if File.exists?(path)
    MemoryRecord.seed_path = path
    break
  end
end

MemoryRecord.database = MemoryRecord::Database.new
