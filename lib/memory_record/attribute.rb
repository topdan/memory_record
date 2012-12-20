module MemoryRecord
  
  module Attribute
    
    def self.included base
      base.extend ClassMethods
    end
    
    class InvalidValueError < Exception ; end
    
    protected
    
    def default_value_for_attribute(name)
      self.class.default_value_for_attribute(name)
    end
    
    module ClassMethods
      
      # TODO inheritance
      def column_names
        @column_names ||= []
      end
      
      def attribute_default_values
        @attribute_default_values ||= {}
      end
      
      def attribute name, options = {}
        attribute_default_values[name.to_s] = options[:default]
        
        attribute_accessor name, options
        attribute_finder name, options
      end
      
      def default_value_for_attribute(name)
        attribute_default_values[name.to_s]
      end
      
      protected
      
      def attribute_finder name, options
        finder = "find_by_#{name}"
        
        collection_class.class_eval do
          define_method finder do |value|
            where(name => value).first
          end
        end
      end
      
      def attribute_accessor name, options
        column_names.push name
        
        getter_name = name.to_s
        setter_name = "#{name}="
        
        type = options[:type]
        
        if type
          attribute_class_name = "::MemoryRecord::Attribute::#{type}Type"
        else
          attribute_class_name = "::MemoryRecord::Attribute::Base"
        end
        
        attribute_class = attribute_class_name.constantize
        attribute = attribute_class.new(name, options)
        
        attribute.define_reader(self)
        attribute.define_writer(self)
      end
      
    end
    
  end
  
end
