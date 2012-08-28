module MemoryRecord
  
  module Field
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection
    end
    
    class InvalidValueError < Exception ; end
    
    def attributes
      self.class.column_names.inject({}) {|hash, name| hash[name] = send(name) ; hash }
    end
    
    def attributes= attrs
      attrs.each do |key, value|
        send "#{key}=", value
      end
    end
    
    module ClassMethods
      
      # TODO inheritance
      def column_names
        @column_names ||= []
      end
      
      def field name, options = {}
        field_accessor name, options
        field_finder name, options
      end
      
      protected
      
      def field_finder name, options
        finder = "find_by_#{name}"
        
        memory_record_collection_class.class_eval do
          define_method finder do |value|
            where(name => value).first
          end
        end
      end
      
      def field_accessor name, options
        column_names.push name
        
        instance_variable = "@#{name}"
        
        getter_name = name.to_s
        setter_name = "#{name}="
        
        type = options[:type]
        
        case type.to_s
        when "String"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            value = value.to_s unless value.nil?
            instance_variable_set instance_variable, value
          end
          
        when "Integer"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            value = value.to_i unless value.nil?
            instance_variable_set instance_variable, value
          end
          
        when "Float"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            # TODO precision
            value = value.to_f unless value.nil?
            instance_variable_set instance_variable, value
          end
          
        when "Boolean"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method "#{getter_name}?" do
            instance_variable_get instance_variable
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
            
            instance_variable_set instance_variable, value
          end
          
        when "DateTime"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            if value.is_a?(DateTime) || value.is_a?(Time) || value.is_a?(Date)
              # all good
              
            elsif value.nil?
              value = nil
              
            elsif value.is_a? String
              begin
                value = DateTime.parse(value)
              rescue ArgumentError
                raise MemoryRecord::Field::InvalidValueError.new("Unknown format for #{setter_name} (DateTime): #{value.inspect}")
              end
              
            else
              raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (DateTime): #{value.inspect} #{value.class.name}")
            end
            
            instance_variable_set instance_variable, value
          end
            
        when "Date"
          define_method getter_name do
            instance_variable_get instance_variable
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
              
            else
              raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (Date): #{value.inspect}")
            end
            
            instance_variable_set instance_variable, value
          end
            
        when "Time"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            if value.is_a? Time
              # all good
              
            elsif value.nil?
              value = nil
              
            elsif value.is_a? String
              value = Time.parse(value)
              
            else
              raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (Time): #{value.inspect}")
            end
            
            instance_variable_set instance_variable, value
          end
          
        else
          raise "unknown field type: #{type.inspect}"
        end
      end
      
    end
    
  end
  
end
