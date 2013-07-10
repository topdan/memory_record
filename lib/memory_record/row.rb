module MemoryRecord
  
  class Row < Hash
    
    attr_accessor :primary_key
    
    def primary_id
      self[@primary_key] if @primary_key
    end
    
    # must be the exact object to be equal
    def ==(obj)
      obj.object_id == self.object_id
    end
    
    def <=>(obj)
      if obj.is_a?(self.class)
        self.primary_id <=> obj.primary_id
      else
        -1
      end
    end
    
  end
  
end
