module MemoryRecord
  module Attribute
    
    class FloatType < Base
      
      def parse(value)
        # TODO precision
        value.to_f unless value.nil?
      end
      
    end
    
  end
end
