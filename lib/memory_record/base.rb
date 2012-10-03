module MemoryRecord
  
  class Base
    include Associations
    include Collection
    include Crud
    include Field
    include Scope
    include Transactions
    include AutoId
    
    attr_reader :raw, :attributes
    
    def initialize attributes = {}
      self.attributes = attributes
    end
    
    def attributes= hash
      @attributes ||= {}
      
      if hash.is_a?(Hash)
        hash.each do |key, value|
          send("#{key}=", value)
        end
        
        # fill in the missing attributes
        self.class.column_names.each do |name|
          @attributes[name.to_s] ||= nil
        end
      end
      
      hash
    end
    
    def to_key
      [id] if persisted?
    end
    
    def to_param
      id
    end
    
    def new_record?
      id.nil?
    end
    
    def persisted?
      id != nil
    end
    
    def reload
      @relations = nil
      
      if persisted?
        existing = self.class.find(self.id)
        self.attributes = existing.attributes
      end
      
      self
    end
    
    def == obj
      obj.class == self.class && obj.id == self.id
    end
    
    def inspect
      %(#<#{self.class.name} id=#{id} attributes=#{attributes.inspect}>)
    end
    
    def clone
      record = self.class.new(self.attributes.clone)
      record.id = self.id
      record.send(:raw=, self.raw || self)
      record
    end
    
    protected
    
    attr_writer :raw
    
    def write_attribute key, value
      self.attributes[key.to_s] = value
    end
    
    def read_attribute key
      self.attributes[key.to_s]
    end
    
  end
  
end
