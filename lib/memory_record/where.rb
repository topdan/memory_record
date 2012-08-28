module MemoryRecord
  
  module Where
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection
    end
    
    module ClassMethods
      
      def where conditions = {}
        if conditions.keys.length == 1
          key = conditions.keys.first
          value = conditions.values.first
          
          # OPTIMIZE could do better than O(n)
          rest = all.collect {|r| r if r.send(key) == value }
          rest.compact!
        else
          rest = []
          
          # OPTIMIZE could do better than O(n)
          to_a.each do |r|
            is_match = true
            conditions.each do |key, value|
              # OPTIMIZE short-curcuit when is_match turns to false
              is_match = false unless r.send(key) == value
            end
            rest.push r if is_match
          end
        end
        
        spawn_child rest
      end
      
    end
    
  end
  
end
