module MemoryRecord
  module Attribute
    
    class BooleanType < Base
      
      def parse(value)
        if [0, "0", false, "false"].include?(value)
          false
          
        elsif [1, "1", true, "true"].include?(value)
          true
          
        elsif value.nil?
          nil
          
        else
          raise MemoryRecord::Attribute::InvalidValueError.new("Unknown format for #{setter_name} (Boolean): #{value.inspect}")
        end
      end
      
      def define_reader(klass)
        super(klass)
        attribute = self
        
        klass.class_eval do
          define_method "#{attribute.reader_method}?" do
            read_attribute(attribute.name) == true
          end
        end
      end
      
    end
    
  end
end
