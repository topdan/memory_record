module MemoryRecord
  module Attribute
    
    class Base
      
      attr_reader :name, :finder_method, :reader_method, :writer_method, :default_value
      
      def initialize(name, options = {})
        @name = name.to_s
        @auto = options[:auto]
        
        @finder_method = options[:finder_method] || "find_by_#{@name}"
        @reader_method = options[:reader_method] || @name
        @writer_method = options[:writer_method] || "#{@name}="
        
        @default_value = parse(options[:default]) if options.key?(:default)
      end
      
      # support:
      #   attribute IN (?)
      #   attribute = ?
      def where?(value, param)
        if param.is_a?(Array)
          param = param.collect {|p| parse(p) }
          param.include?(value)
        else
          value == parse(param)
        end
      end
      
      def parse(value)
        value # subclasses should override this
      end
      
      def define_finder(klass)
        attribute = self
        
        klass.class_eval do
          # define a class method
          (class << self; self; end).instance_eval do
            define_method(attribute.finder_method) do |value|
              where(attribute.name => value).first
            end
          end
        end
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
      
      def auto?
        @auto == true
      end
      
      def initialize_auto(table)
        # subclasses should fill this in
      end
      
      def generate_auto(table)
        auto = next_auto(table)
        table.autos[name] = auto
        auto
      end
      
      def previous_auto(table)
        table.autos[name] || initialize_auto(table)
      end
      
      def next_auto(table)
        # subclasses should fill this in
      end
      
    end
    
  end
end
