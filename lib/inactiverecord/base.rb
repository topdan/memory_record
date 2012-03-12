module InactiveRecord
  
  class Base
    include Associations
    include Collection
    include Crud
    include Field
    include Limit
    include Offset
    include Order
    include Scope
    include Where
    
    def initialize attributes = {}
      self.attributes = attributes
    end
    
    class << self
      
      def create attributes = {}
        record = new attributes
        record.save
        record
      end
      
      def create! attributes = {}
        record = new attributes
        record.save!
        record
      end
      
    end
    
  end
  
end
