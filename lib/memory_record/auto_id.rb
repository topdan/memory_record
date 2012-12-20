module MemoryRecord
  
  module AutoId
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def auto_id
        include ActsMethods
        
        attribute :id, type: Integer
      end
      
    end
    
    module ActsMethods
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      protected
      
      def generate_id
        self.class.next_id
      end
      
      module ClassMethods
        
        def last_id
          @last_id
        end
        
        def next_id
          @last_id ||= 0
          @last_id += 1
        end
        
      end
      
    end
    
  end
  
end
