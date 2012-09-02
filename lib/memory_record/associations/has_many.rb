module MemoryRecord
  module Associations
    module HasMany
      
      def has_many name, options = {}
        if options[:through]
          association = HasManyThrough::Association.new(self, name, options)
        else
          association = HasMany::Association.new(self, name, options)
        end
        
        self.associations.push(association)
        
        define_method association.name do
          relation = relation_for(association)
          relation.all
        end
        
        define_method association.ids_method do
          relation = relation_for(association)
          relation.all_ids
        end
        
        define_method "#{association.name}=" do |records|
          relation = relation_for(association)
          relation.all = records
        end
        
        define_method "#{association.ids_method}=" do |ids|
          relation = relation_for(association)
          relation.all_ids = ids
        end
        
      end
      
      class Association < Association

        attr_reader :foreign_key, :foreign_key_writer

        def initialize klass, name, options = {}
          class_name = options[:class_name] || name.to_s.singularize.camelize

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

        def relation_for parent
          Relation.new(self, parent)
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
          @unsaved_all = records
          
          parent.after_save(transaction: true) do
            missing_records = existing_records - records
            new_records = records - existing_records
            
            missing_records.each {|record| record.destroy }
            new_records.each {|record| record.send(association.foreign_key_writer, parent) ; record.save! }
            @unsaved_all = nil
          end
          
          records
        end

        def all_ids= ids
          self.all = ids.collect {|id| association.foreign_klass.find(id) }
          ids
        end

        def raw_all
          return @unsaved_all if @unsaved_all
          
          records = Array.new(association.foreign_klass.records)
          records.keep_if {|record| record.send(foreign_key) == parent}
          records
        end

      end

    end
  end
end
