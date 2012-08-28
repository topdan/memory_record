module MemoryRecord
  
  module Order
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection unless included_modules.include?(Collection)
    end
    
    module ClassMethods
      
      def order field_and_direction
        if field_and_direction.is_a?(Array)
          field = field_and_direction.first
          direction = field_and_direction.last
          
        else
          field = field_and_direction
          direction = :asc
        end
        
        arr = to_a.sort do |a, b|
          a1 = a.send field
          b1 = b.send field
          
          if a1.nil? && b1.nil?
            0
          elsif a1.nil?
            direction == :desc ? 1 : -1
          elsif b1.nil?
            direction == :desc ? -1 : 1
          elsif direction == :desc
            b1 <=> a1
          else
            a1 <=> b1
          end
        end
        
        spawn_child arr
      end
      
    end
    
  end
  
end
