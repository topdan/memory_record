module MemoryRecord
  
  class Row < Hash
    
    # must be the exact object to be equal
    def ==(obj)
      obj.object_id == self.object_id
    end
    
  end
  
end
