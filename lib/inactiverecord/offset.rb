module InactiveRecord
  
  module Offset
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection unless included_modules.include?(Collection)
    end
    
    module ClassMethods
      
      def offset count
        spawn_child self[count..-1]
      end
      
    end
    
  end
  
end
