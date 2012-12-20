module MemoryRecord
  
  module Attribute
    
    class InvalidValueError < Exception ; end
    class NotFoundError < Exception ; end
    
    # TODO inheritance
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
    
    def attribute(name, options = {})
      type = options[:type]
      
      if type
        attribute_class_name = "::MemoryRecord::Attribute::#{type}Type"
      else
        attribute_class_name = "::MemoryRecord::Attribute::Base"
      end
      
      attribute_class = attribute_class_name.constantize
      attribute = attribute_class.new(name, options)
      
      attribute.define_reader(self)
      attribute.define_writer(self)
      attribute.define_finder(self)
      
      self.attributes.push(attribute)
    end
    
  end
  
end
