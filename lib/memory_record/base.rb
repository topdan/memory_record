module MemoryRecord
  
  class Base
    include Associations
    include Collection
    include Crud
    include Field
    include Scope
    include Transactions
    include AutoId
    include Seed
    include Timestamps
    
    attr_reader :raw, :attributes, :changes
    
    def initialize attributes = {}
      @changes = {}
      run_callbacks(:initialize) do
        self.attributes = attributes
      end
    end
    
    def changed?
      !changes.empty?
    end
    
    def changed
      changes.keys
    end
    
    def attributes= hash
      @attributes ||= {}
      
      if hash.is_a?(Hash)
        multi_parameter_attributes = {}
        
        hash.each do |key, value|
          if key.to_s =~ /^(.*)\(([1-9])i\)/
            multi_parameter_attributes[$1] ||= []
            multi_parameter_attributes[$1].insert($2.to_i, value.to_i)
          else
            send("#{key}=", value)
          end
        end
        
        multi_parameter_attributes.each do |key, pieces|
          # zero index isn't used
          pieces = pieces[1..-1]


          # TODO support other datatypes?
          unless pieces.include?(nil)
            value = DateTime.new(*pieces)
            send("#{key}=", value)
          end
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
      raw == nil
    end
    
    def persisted?
      raw != nil
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
      %(#<#{self.class.name} id=#{id.inspect} attributes=#{attributes.inspect}>)
    end
    
    def clone
      record = self.class.new(self.attributes.clone)
      record.id = self.id
      record.changes.clear
      record.send(:raw=, self.raw || self)
      record
    end
    
    protected
    
    attr_writer :raw
    
    def write_attribute key, value
      key = key.to_s
      
      attr_changes = self.changes[key]
      old_value = attr_changes ? attr_changes.first : read_attribute(key)
      
      self.attributes[key] = value
      
      new_value = read_attribute(key)
      if new_value == old_value
        changes.delete(key)
      elsif attr_changes
        attr_changes[1] = new_value
      else
        changes[key] = [old_value, new_value]
      end
      
      new_value
    end
    
    def read_attribute key
      self.attributes[key.to_s]
    end
    
  end
  
end
