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
    
    class Relation
      
      attr_reader :association, :parent
      
      def initialize association, parent
        @association = association
        @parent = parent
      end
      
      def klass
        @association.klass
      end
      
      def name
        @association.name
      end
      
      def foreign_key
        @association.foreign_key
      end
      
      def build attributes = {}
        klass.new attributes.merge(foreign_key => parent)
      end
      
      def << record
        raise NotImplementedError.new('subclass must implement')
      end
      
      def raw_all
        raise NotImplementedError.new('subclass must implement')
      end
      
    end
    
  end
  
end
