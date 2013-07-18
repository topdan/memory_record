module MemoryRecord
  module Validations
    
    # based off of ActiveRecord's UniquenessValidator
    class UniquenessValidator < ActiveModel::EachValidator
      
      def initialize(options)
        super({:case_sensitive => true}.merge(options))
      end

      # Unfortunately, we have to tie Uniqueness validators to a class.
      def setup(klass)
        @klass = klass
        @primary_key = klass.table.primary_key
      end
      
      def validate_each(record, attribute, value)
        if attribute.to_s == @primary_key
          if record.new_record?
            is_taken = @klass.send("find_by_#{@primary_key}", value) != nil
          else
            is_taken = @klass.send("find_by_#{@primary_key}", value) != record
          end
        else
          query = @klass.where(attribute => record.send(attribute))

          unless record.new_record?
            query = query.remove_if {|r| r == record }
          end

          is_taken = !query.empty?
        end
        
        if is_taken
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
