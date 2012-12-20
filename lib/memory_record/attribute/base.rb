module MemoryRecord
  module Attribute
    
    class Base
      
      attr_reader :name, :reader_method, :writer_method
      
      def initialize(name, options = {})
        @name = name.to_s
        
        @reader_method = options[:reader_method] || @name
        @writer_method = options[:writer_method] || "#{@name}="
      end
      
      def define_reader(klass)
        attribute = self
        
        klass.class_eval do
          define_method(attribute.reader_method) do
            read_attribute(attribute.name)
          end
        end
      end
      
      def define_writer(klass)
        attribute = self
        
        klass.class_eval do
          define_method(attribute.writer_method) do |value|
            parsed_value = attribute.parse(value)
            write_attribute(attribute.name, parsed_value)
          end
        end
      end
      
      def parse(value)
        value
      end
      
    end
    
  end
end
