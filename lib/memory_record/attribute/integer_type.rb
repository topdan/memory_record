module MemoryRecord
  module Attribute
    
    class IntegerType < Base
      
      def parse(value)
        value.to_i unless value.nil?
      end
      
    end
    
  end
end
