module MemoryRecord
  module Validations
    
    # based off of ActiveRecord's UniquenessValidator
    class UniquenessValidator < ActiveModel::EachValidator
      
      def initialize(options)
        super(options.reverse_merge(:case_sensitive => true))
      end

      # Unfortunately, we have to tie Uniqueness validators to a class.
      def setup(klass)
        @klass = klass
      end
      
      def validate_each(record, attribute, value)
        query = @klass.where(attribute => record.send(attribute))
        
        unless record.new_record?
          query = query.remove_if {|r| r == record }
        end
        
        unless query.empty?
          record.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(:value => value))
        end
      end
      
    end
    
    module ClassMethods
      
      def validates_uniqueness_of(*attr_names)
        validates_with UniquenessValidator, _merge_attributes(attr_names)
      end
      
    end
    
  end
end
