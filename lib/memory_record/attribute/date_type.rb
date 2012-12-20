module MemoryRecord
  module Attribute
    
    class DateType < Base
      
      def parse(value)
        if value.is_a? Date
          return value
          
        elsif value.nil?
          return nil
          
        elsif value.is_a? String
          begin
            return Date.parse(value)
          rescue ArgumentError
            raise MemoryRecord::Field::InvalidValueError.new("Unknown format for #{self.name} (Date): #{value.inspect}")
          end
          
        elsif value.is_a?(Hash)
          year, month, day = value['year'], value['month'], value['day']
          if year && month && day
            return Date.new(year.to_i, month.to_i, day.to_i)
          else
            raise MemoryRecord::Field::InvalidValueError.new("Incomplete Date hash")
          end
          
        else
          raise MemoryRecord::Field::InvalidValueError.new("Unknown type for #{self.name} (Date): #{value.inspect}")
        end
      end
      
    end
    
  end
end
