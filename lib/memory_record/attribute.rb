module MemoryRecord
  
  module Attribute
    
    class InvalidValueError < Exception ; end
    class NotFoundError < Exception ; end
    
    def attributes
      @attributes ||= self.superclass.respond_to?(:attribute) ? self.superclass.attributes.clone : []
    end
    
    def find_attribute(name)
      @attributes_by_name ||= attributes.inject({}) do |hash, attribute|
        hash[attribute.name] = attribute
        hash
      end
      
      @attributes_by_name[name.to_s]
    end
    
    def find_attribute!(name)
      attribute = find_attribute(name)
      raise NotFoundError.new("#{name.inspect} available: #{attributes.map(&:name).inspect}") unless attribute
      attribute
    end
    
    def attribute
      Generator.new(self)
    end
    
  end
  
end
