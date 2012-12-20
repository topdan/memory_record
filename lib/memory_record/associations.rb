module MemoryRecord
  module Associations
    
    def self.included base
      base.extend ClassMethods
      base.extend Association::BelongsTo
      base.extend Association::HasMany
      base.extend Association::HasManyThrough
    end
    
    def relation_for(association)
      @relations ||= {}
      relation = @relations[association.name]
      
      if relation.nil?
        relation =  association.relation_for(self)
        @relations[association.name] = relation
      end
      
      relation
    end
    
    module ClassMethods
      
      def associations
        @associations ||= []
      end
      
      def find_association name
        associations.detect {|a| a.name == name }
      end
      
    end
    
  end
end
