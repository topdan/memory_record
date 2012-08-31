module MemoryRecord
  
  class Association
    
    attr_reader :name, :class_name, :klass, :name_writer
    
    def initialize name, class_name
      @name = name
      @class_name = class_name
      
      @name_writer = "#{@name}="
    end
    
    def klass
      @klass ||= class_name.constantize
    end
    
  end
  
  module Associations
    
    def self.included base
      base.extend ClassMethods
      base.extend BelongsTo
      base.extend HasMany
      base.extend HasManyThrough
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
