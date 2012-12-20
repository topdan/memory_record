module MemoryRecord
  module Association
    module BelongsTo
      
      def belongs_to name, options = {}
        class_name = options[:class_name] || name.to_s.camelize
        association = Association.new(self, name, class_name)
        self.associations.push(association)

        id_method = "#{name}_id"
        id_writer = "#{id_method}="

        # TODO determine type automatically?
        attribute.generic(id_method)

        define_method name do
          association.foreign_klass.where(:id => send(id_method)).first
        end

        define_method "#{name}=" do |record|
          send(id_writer, record ? record.id : nil)
          record
        end
      end

      class Association < MemoryRecord::Association::Base

        def type
          :belongs_to
        end

      end

    end
  end
end
