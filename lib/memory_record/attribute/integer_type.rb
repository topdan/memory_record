module MemoryRecord
  module Attribute
    
    class IntegerType < Base
      
      def initialize_auto(table)
        max = nil
        table.rows.each do |row|
          value = row[name]
          max = value if max.nil? || value > max
        end
        
        max || 0
      end
      
      def next_auto(table)
        previous_auto(table) + 1
      end
      
      def parse(value)
        value.to_i unless value.nil?
      end
      
    end
    
  end
end
