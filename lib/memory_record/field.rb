module MemoryRecord
  
  module Field
    
    def self.included base
      base.extend ClassMethods
    end
    
    class InvalidValueError < Exception ; end
    
    protected
    
    def default_value_for_field(name)
      self.class.default_value_for_field(name)
    end
    
    module ClassMethods
      
      # TODO inheritance
      def column_names
        @column_names ||= []
      end
      
      def field_default_values
        @field_default_values ||= {}
      end
      
      def field name, options = {}
        field_default_values[name.to_s] = options[:default]
        
        field_accessor name, options
        field_finder name, options
      end
      
      def default_value_for_field(name)
        field_default_values[name.to_s]
      end
      
      protected
      
      def field_finder name, options
        finder = "find_by_#{name}"
        
        collection_class.class_eval do
          define_method finder do |value|
            where(name => value).first
          end
        end
      end
      
      def field_accessor name, options
        column_names.push name
        
        getter_name = name.to_s
        setter_name = "#{name}="
        
        type = options[:type]
        
        if type
          field_class_name = "::MemoryRecord::Attribute::#{type}Type"
        else
          field_class_name = "::MemoryRecord::Attribute::Base"
        end
        
        field_class = field_class_name.constantize
        field = field_class.new(name, options)
        
        field.define_reader(self)
        field.define_writer(self)
      end
      
    end
    
  end
  
end
