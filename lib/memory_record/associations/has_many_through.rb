module MemoryRecord
  module Associations
    module HasManyThrough
      
      def has_many_through name, options = {}
        through = options[:through]
        source = options[:source] || name.to_s.singularize.underscore.to_sym
        
        through_association = find_association(through)
        raise "has_many through not found: #{through.inspect}" unless through_association
        
        association = Association.new(name, through_association, source)
        self.associations.push(association)
        
        define_method name do
          ids = send(association.ids_method)
          
          relation = Relation.new(association, self)
          association.klass.collection_class.new relation, proc {|records|
            records.keep_if {|rec| ids.include?(rec.id) }
          }
        end
        
        define_method association.ids_method do
          set = Set.new
          
          records = send(through).send(:raw_all).each do |record| 
            id = record.send("#{source}_id")
            set.add(id) if id
          end

          set.to_a
        end
        
      end
      
      class Association < MemoryRecord::Association

        attr_reader :name, :through, :source

        def initialize name, through, source
          @type = type
          @name = name
          @through = through
          @source = source
        end

        def source_association
          @source_association ||= through.klass.find_association(source)
        end

        def class_name
          source_association.class_name
        end

        def klass
          source_association.klass
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
          join = through.klass.new
          join.send through.foreign_key_writer, parent
          join.send association.source_association.name_writer, record
          join.save!
        end

        def raw_all
          ids = parent.send(association.ids_method)

          records = Array.new(klass.records)
          records.keep_if {|record| ids.include?(record.id) }
          records
        end

      end

    end
  end
end
