module MemoryRecord
  module Associations
    module HasMany
      
      def has_many name, options = {}
        if options[:through]
          has_many_through(name, options)
          return
        end
        
        is_uniq = options[:uniq]
        
        class_name = options[:class_name] || name.to_s.singularize.camelize
        association = Association.new(self, name, class_name, options)
        self.associations.push(association)
        
        define_method name do
          relation = Relation.new(association, self)
          relation.all
        end
        
        define_method association.ids_method do
          relation = Relation.new(association, self)
          relation.all_ids
        end
        
        define_method "#{name}=" do |records|
          relation = Relation.new(association, self)
          relation.all = records
        end
        
        define_method "#{association.ids_method}=" do |ids|
          relation = Relation.new(association, self)
          relation.all_ids = ids
        end
        
      end
      
      class Association < Association

        attr_reader :foreign_key, :foreign_key_writer

        def initialize klass, name, class_name, options = {}
          super klass, name, class_name

          foreign_key = options[:foreign_key] || klass.name.to_s.foreign_key
          foreign_key = $` if foreign_key =~ /_id$/ # remove the _id since inactive records don't rely on IDs

          @foreign_key = foreign_key
          @foreign_key_writer = "#{@foreign_key}="
        end

        def type
          :has_many
        end

        def ids_method
          @ids_method ||= name.to_s.singularize + "_ids"
        end

      end

      class Relation < Associations::Relation

        def foreign_key
          @association.foreign_key
        end

        def build attributes = {}
          association.foreign_klass.new attributes.merge(foreign_key => parent)
        end

        def << record
          record.send "#{foreign_key}=", parent
          record.save!
        end

        def all
          association.foreign_klass.collection_class.new self, []
        end

        def all_ids
          parent.send(name).send(:raw_all).map(&:id)
        end

        def all= records
          existing_records = parent.send(name).send(:raw_all)
          
          missing_records = existing_records - records
          new_records = records - existing_records
          
          missing_records.each {|record| record.destroy }
          new_records.each {|record| record.send(association.foreign_key_writer, parent) ; record.save! }
          records
        end

        def all_ids= ids
          records = ids.collect {|id| association.foreign_klass.find(id) }
          parent.send association.name_writer, records
          ids
        end

        def raw_all
          records = Array.new(association.foreign_klass.records)
          records.keep_if {|record| record.send(foreign_key) == parent}
          records
        end

      end

    end
  end
end
