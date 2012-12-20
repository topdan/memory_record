module MemoryRecord
  module Attribute
    
    class Generator
      
      def initialize(klass)
        @klass = klass
      end
      
      def boolean(name, options = {})
        define_attribute(BooleanType.new(name, options))
      end
      
      def datetime(name, options = {})
        define_attribute(DateTimeType.new(name, options))
      end
      
      def date(name, options = {})
        define_attribute(DateType.new(name, options))
      end
      
      def float(name, options = {})
        define_attribute(FloatType.new(name, options))
      end
      
      def integer(name, options = {})
        define_attribute(IntegerType.new(name, options))
      end
      
      def string(name, options = {})
        define_attribute(StringType.new(name, options))
      end
      
      def time(name, options = {})
        define_attribute(TimeType.new(name, options))
      end
      
      def generic(name, options = {})
        define_attribute(Base.new(name, options))
      end
      
      protected
      
      def define_attribute(attribute)
        attribute.define_reader(@klass)
        attribute.define_writer(@klass)
        attribute.define_finder(@klass)

        @klass.attributes.push(attribute)
      end
      
    end
    
  end
end
