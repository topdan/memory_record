module MemoryRecord
  
  module Associations
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Where unless included_modules.include?(Where)
      base.send :include, Collection unless included_modules.include?(Collection)
    end
    
    module ClassMethods
      
      def belongs_to name, options = {}
        # TODO type checking
        attr_accessor name
      end
      
      def has_one name, options = {}
        instance_variable = "@#{name}"
        
        foreign_key = options[:foreign_key] || self.name.foreign_key
        foreign_key = $` if foreign_key =~ /_id$/ # remove the _id since inactive records don't rely on IDs
        foreign_key_writer = "#{foreign_key}="
        
        class_name = options[:class_name] || name.to_s.camelize
        klass = nil
        
        define_method name do
          var = instance_variable_get instance_variable
          return nil if var == :nil
          return var if var
          
          klass ||= class_name.constantize
          record = klass.where(foreign_key => self).first || :nil
          instance_variable_set instance_variable, record
          nil
        end
        
        define_method "#{name}=" do |value|
          # TODO type checking
          value.send foreign_key_writer, self
          instance_variable_set instance_variable, value
        end
        
      end
      
      def has_many name, options = {}
        instance_variable = "@#{name}"
        
        foreign_key = options[:foreign_key] || self.name.foreign_key
        foreign_key = $` if foreign_key =~ /_id$/ # remove the _id since inactive records don't rely on IDs
        
        is_uniq = options[:uniq]
        
        class_name = options[:class_name] || name.to_s.singularize.camelize
        klass = nil
        
        define_method name do
          records = []
          klass ||= class_name.constantize
          relation = Collection::Relation.new(klass, foreign_key, self)
          
          records = klass.where(foreign_key => self).all
          records.uniq! if is_uniq
          
          records = klass.inactive_record_collection_class.new relation, records
          instance_variable_set instance_variable, records
        end
      end
      
    end
    
  end
  
end
