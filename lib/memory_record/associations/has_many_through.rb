module MemoryRecord
  module Associations
    module HasManyThrough
      
      def has_many_through name, options = {}
        through = options[:through]
        source = options[:source] || name.to_s.singularize.underscore.to_sym
        
        through_association = find_association(through)
        raise "has_many through not found: #{through.inspect}" unless through_association
        
        association = Association.new(self, name, through_association, source)
        self.associations.push(association)
        
        define_method name do
          relation = Relation.new(association, self)
          relation.all
        end
        
        define_method association.ids_method do
          relation = Relation.new(association, self)
          relation.all_ids
        end
        
      end
      
      class Association < MemoryRecord::Association

        attr_reader :name, :through, :source

        def initialize klass, name, through, source
          @type = type
          @name = name
          @through = through
          @source = source
        end

        def source_association
          @source_association ||= through.foreign_klass.find_association(source)
        end

        def foreign_class_name
          source_association.class_name
        end

        def foreign_klass
          source_association.foreign_klass
        end

        def ids_method
          @ids_method ||= name.to_s.singularize + "_ids"
        end

        def type
          :has_many
        end

      end

      class Relation < Associations::Relation

        def << record
          through = association.through

          # create the join record
          join = through.foreign_klass.new
          join.send through.foreign_key_writer, parent
          join.send association.source_association.name_writer, record
          join.save!
        end

        def all
          ids = parent.send(association.ids_method)
          
          association.foreign_klass.collection_class.new self, proc {|records|
            records.keep_if {|rec| ids.include?(rec.id) }
          }
        end

        def all_ids
          set = Set.new
          
          records = parent.send(association.through.name).send(:raw_all).each do |record| 
            id = record.send("#{association.source_association.name}_id")
            set.add(id) if id
          end

          set.to_a
        end

        def raw_all
          ids = parent.send(association.ids_method)

          records = Array.new(foreign_klass.records)
          records.keep_if {|record| ids.include?(record.id) }
          records
        end

      end

    end
  end
end
