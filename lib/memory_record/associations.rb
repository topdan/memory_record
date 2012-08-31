module MemoryRecord
  
  class Association
    
    attr_reader :name, :foreign_class_name, :klass, :foreign_klass, :name_writer
    
    def initialize klass, name, class_name
      @klass = klass
      @name = name
      @foreign_class_name = class_name
      
      @name_writer = "#{@name}="
    end
    
    def foreign_klass
      @foreign_klass ||= foreign_class_name.constantize
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
      
      def foreign_klass
        @association.foreign_klass
      end
      
      def name
        @association.name
      end
      
      def build attributes = {}
        raise NotImplementedError.new('subclass must implement')
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
