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
        
        case type.to_s
        when ""
          define_method getter_name do
            read_attribute name
          end
          
          define_method setter_name do |value|
            write_attribute name, value
          end
          
        when "String"
          define_method getter_name do
            read_attribute name
          end
          
          define_method setter_name do |value|
            value = value.to_s unless value.nil?
            write_attribute name, value
          end
          
        when "Integer"
          define_method getter_name do
            read_attribute name
          end
          
          define_method setter_name do |value|
            value = value.to_i unless value.nil?
            write_attribute name, value
          end
          
        when "Float"
          define_method getter_name do
            read_attribute name
          end
          
          define_method setter_name do |value|
            # TODO precision
            value = value.to_f unless value.nil?
            write_attribute name, value
          end
          
        when "Boolean"
          define_method getter_name do
            read_attribute name
          end
          
          define_method "#{getter_name}?" do
            read_attribute(name) == true
          end
          
          define_method setter_name do |value|
            if [0, "0", false, "false"].include?(value)
              value = false
              
            elsif [1, "1", true, "true"].include?(value)
              value = true
              
            elsif value.nil?
              value = nil
              
            else
              raise MemoryRecord::Field::InvalidValueError.new("Unknown format for #{setter_name} (Boolean): #{value.inspect}")
            end
            
            write_attribute name, value
          end
          
        when "DateTime"
          define_method getter_name do
            read_attribute name
          end
          
          define_method setter_name do |value|
            if value.is_a?(DateTime)
              # all good
              
            elsif value.is_a?(Time)
              value = DateTime.parse(value.to_s)
              
            elsif value.is_a?(Date)
              value = DateTime.parse(value.to_s)
              
            elsif value.nil?
              value = nil
              
            elsif value.is_a? String
              begin
                value = DateTime.parse(value)
              rescue ArgumentError
                raise MemoryRecord::Field::InvalidValueError.new("Unknown format for #{setter_name} (DateTime): #{value.inspect}")
              end
              
            elsif value.is_a?(Hash)
              year, month, day, hour, min, sec = value['year'], value['month'], value['day'], value['hour'], value['min'], value['sec']
              if year && month && day && hour && min && sec
                value = DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, min.to_i, sec.to_i)
              elsif year && month && day && hour && min
                value = DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, min.to_i)
              elsif year && month && day
                value = DateTime.new(year.to_i, month.to_i, day.to_i)
              else
                raise MemoryRecord::Field::InvalidValueError.new("Incomplete DateTime hash")
              end
              
            else
              raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (DateTime): #{value.inspect} #{value.class.name}")
            end
            
            write_attribute name, value
          end
            
        when "Date"
          define_method getter_name do
            read_attribute name
          end
          
          define_method setter_name do |value|
            if value.is_a? Date
              # all good
              
            elsif value.nil?
              value = nil
              
            elsif value.is_a? String
              begin
                value = Date.parse(value)
              rescue ArgumentError
                raise MemoryRecord::Field::InvalidValueError.new("Unknown format for #{setter_name} (Date): #{value.inspect}")
              end
              
            elsif value.is_a?(Hash)
              year, month, day = value['year'], value['month'], value['day']
              if year && month && day
                value = Date.new(year.to_i, month.to_i, day.to_i)
              else
                raise MemoryRecord::Field::InvalidValueError.new("Incomplete Date hash")
              end
              
            else
              raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (Date): #{value.inspect}")
            end
            
            write_attribute name, value
          end
            
        when "Time"
          define_method getter_name do
            read_attribute name
          end
          
          define_method setter_name do |value|
            if value.is_a? Time
              # all good
              
            elsif value.nil?
              value = nil
              
            elsif value.is_a? String
              value = Time.parse(value)
              
            elsif value.is_a?(Hash)
              hour, min, sec = value['hour'], value['min'], value['sec']
              if hour && min && sec
                value = Time.parse("#{hour.to_i}:#{min.to_i}:#{sec.to_i}")
              elsif hour && min
                value = Time.parse("#{hour.to_i}:#{min.to_i}")
              else
                raise MemoryRecord::Field::InvalidValueError.new("Incomplete Time hash")
              end
              
            else
              raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (Time): #{value.inspect}")
            end
            
            write_attribute name, value
          end
          
        else
          raise "unknown field type: #{type.inspect}"
        end
      end
      
    end
    
  end
  
end
