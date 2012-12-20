module MemoryRecord
  module Attribute
    
    class TimeType < Base
      
      def parse(value)
        if value.is_a? Time
          return value
          
        elsif value.nil?
          return nil
          
        elsif value.is_a? String
          return Time.parse(value)
          
        elsif value.is_a?(Hash)
          hour, min, sec = value['hour'], value['min'], value['sec']
          if hour && min && sec
            return Time.parse("#{hour.to_i}:#{min.to_i}:#{sec.to_i}")
          elsif hour && min
            return Time.parse("#{hour.to_i}:#{min.to_i}")
          else
            raise MemoryRecord::Field::InvalidValueError.new("Incomplete Time hash")
          end
          
        else
          raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{self.name} (Time): #{value.inspect}")
        end
      end
      
    end
    
  end
end
