module MemoryRecord
  
  module Limit
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection unless included_modules.include?(Collection)
    end
    
    module ClassMethods
      
      def limit count
        spawn_child self[0..count-1]
      end
      
    end
    
  end
  
end
