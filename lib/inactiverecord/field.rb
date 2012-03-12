module InactiveRecord
  
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
        
        inactive_record_collection_class.class_eval do
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
            instance_variable_set instance_variable, value.to_s
          end
          
        when "Integer"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            instance_variable_set instance_variable, value.to_i
          end
          
        when "Float"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            # TODO precision
            instance_variable_set instance_variable, value.to_f
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
              
            else
              raise InactiveRecord::Field::InvalidValueError.new("Unknown format for #{setter_name} (Boolean): #{value.inspect}")
            end
            
            instance_variable_set instance_variable, value
          end
          
        when "DateTime"
          define_method getter_name do
            instance_variable_get instance_variable
          end
          
          define_method setter_name do |value|
            if value.is_a? DateTime
              # all good
              
            elsif value.is_a? String
              begin
                value = DateTime.parse(value)
              rescue ArgumentError
                raise InactiveRecord::Field::InvalidValueError.new("Unknown format for #{setter_name} (DateTime): #{value.inspect}")
              end
              
            else
              raise InactiveRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (DateTime): #{value.inspect}")
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
              
            elsif value.is_a? String
              begin
                value = Date.parse(value)
              rescue ArgumentError
                raise InactiveRecord::Field::InvalidValueError.new("Unknown format for #{setter_name} (Date): #{value.inspect}")
              end
              
            else
              raise InactiveRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (Date): #{value.inspect}")
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
              
            elsif value.is_a? String
              value = Time.parse(value)
              
            else
              raise InactiveRecord::Field::InvalidValueError.new("Unknown type for #{setter_name} (Time): #{value.inspect}")
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
