module MemoryRecord
  module Attribute
    
    class StringType < Base
      
      def parse(value)
        value.to_s unless value.nil?
      end
      
    end
    
  end
end
