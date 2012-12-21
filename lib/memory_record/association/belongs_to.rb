module MemoryRecord
  module Association
    module BelongsTo
      
      def belongs_to name, options = {}
        association = Association.new(self, name, options)
        self.associations.push(association)

        # TODO should the _id attribute have a specified type?

        if association.polymorphic?
          
          # DRY: define the attributes
          attribute.string(association.polymorphic_type_attribute)
          attribute.generic(association.id_attribute)
          
          define_method(association.name) do
            class_name = send(association.polymorphic_type_attribute)
            if class_name
              klass = class_name.constantize
              klass.where(id: send(association.id_attribute)).first
            end
          end

          define_method(association.name_writer) do |record|
            record_type = record ? record.class.name : nil
            record_id = record ? record.id : nil
            
            send(association.polymorphic_type_attribute_writer, record_type)
            send(association.id_attribute_writer, record_id)
            
            record
          end
          
        else
          # DRY: define the attribute
          attribute.generic(association.id_attribute)
          
          define_method(association.name) do
            association.foreign_klass.where(id: send(association.id_attribute)).first
          end

          define_method(association.name_writer) do |record|
            send(association.id_attribute_writer, record ? record.id : nil)
            record
          end
        end
      end

      class Association < MemoryRecord::Association::Base

        attr_reader :id_attribute, :id_attribute_writer, :polymorphic_type_attribute, :polymorphic_type_attribute_writer

        def initialize(klass, name, options = {})
          @polymorphic = options[:polymorphic] == true
          if @polymorphic
            @polymorphic_type_attribute = "#{name}_type"
            @polymorphic_type_attribute_writer = "#{@polymorphic_type_attribute}="
          end
          
          @id_attribute = "#{name}_id"
          @id_attribute_writer = "#{@id_attribute}="
          
          class_name = options[:class_name] || name.to_s.camelize unless polymorphic?
          super(klass, name, class_name)
        end

        def type
          :belongs_to
        end

        def polymorphic?
          @polymorphic == true
        end

      end

    end
  end
end
