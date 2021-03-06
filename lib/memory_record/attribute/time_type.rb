module MemoryRecord
  module Attribute
    
    class TimeType < Base
      
      def parse(value)
        if value.is_a?(Time)
          return value
          
        elsif value.is_a?(DateTime)
          return value.to_time
          
        elsif value.nil?
          return nil
          
        elsif value.is_a?(String)
          return Time.parse(value)
          
        elsif value.is_a?(Hash)
          hour, min, sec = value['hour'], value['min'], value['sec']
          if hour && min && sec
            return Time.parse("#{hour.to_i}:#{min.to_i}:#{sec.to_i}")
          elsif hour && min
            return Time.parse("#{hour.to_i}:#{min.to_i}")
          else
            raise MemoryRecord::Attribute::InvalidValueError.new("Incomplete Time hash")
          end
          
        else
          raise MemoryRecord::Attribute::InvalidValueError.new("Unknown type for #{self.name} (expected: Time, got: #{value.class}): #{value.inspect}")
        end
      end
      
    end
    
  end
end
