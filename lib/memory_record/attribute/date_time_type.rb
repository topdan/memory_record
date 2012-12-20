module MemoryRecord
  module Attribute
    
    class DateTimeType < Base
      
      def parse(value)
        if value.is_a?(DateTime)
          return value
          
        elsif value.is_a?(Time)
          return DateTime.parse(value.to_s)
          
        elsif value.is_a?(Date)
          return DateTime.parse(value.to_s)
          
        elsif value.nil?
          return nil
          
        elsif value.is_a? String
          begin
            return DateTime.parse(value)
          rescue ArgumentError
            raise MemoryRecord::Attribute::InvalidValueError.new("Unknown format for #{self.name} (DateTime): #{value.inspect}")
          end
          
        elsif value.is_a?(Hash)
          year, month, day, hour, min, sec = value['year'], value['month'], value['day'], value['hour'], value['min'], value['sec']
          
          if year && month && day && hour && min && sec
            return DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, min.to_i, sec.to_i)
          elsif year && month && day && hour && min
            return DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, min.to_i)
          elsif year && month && day
            return DateTime.new(year.to_i, month.to_i, day.to_i)
          else
            raise MemoryRecord::Attribute::InvalidValueError.new("Incomplete DateTime hash")
          end
          
        else
          raise MemoryRecord::Attribute::InvalidValueError.new("Unknown type for #{self.name} (DateTime): #{value.inspect} #{value.class.name}")
        end
      end
      
    end
    
  end
end
