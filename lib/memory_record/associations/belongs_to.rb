module MemoryRecord
  module Associations
    
    module BelongsTo
      
      def belongs_to name, options = {}
        class_name = options[:class_name] || name.to_s.camelize
        association = BelongsToAssociation.new(name, class_name)
        self.associations.push(association)

        id_method = "#{name}_id"

        field id_method, type: Integer

        define_method name do
          association.klass.where(:id => send(id_method)).first
        end

        define_method "#{name}=" do |record|
          send("#{id_method}=", record ? record.id : nil)
          record
        end
      end

    end
  end
  
  
  class BelongsToAssociation < Association
    
    def type
      :belongs_to
    end
    
  end
  
end
