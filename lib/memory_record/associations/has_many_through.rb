module MemoryRecord
  module Associations
    module HasManyThrough
      
      class Association < MemoryRecord::Association

        attr_reader :name, :through, :source

        def initialize klass, name, options = {}
          through = options[:through]
          source = options[:source] || name.to_s.singularize.underscore.to_sym

          through_association = klass.find_association(through)
          raise "has_many through not found: #{through.inspect}" unless through_association
          
          @type = type
          @name = name
          @through = through_association
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

        def relation_for parent
          Relation.new(self, parent)
        end

      end

      class Relation < Associations::Relation

        def build attributes = {}
          through = association.through
          
          record = association.source_association.foreign_klass.new(attributes)
          
          join = through.foreign_klass.new
          join.send through.foreign_key_writer, parent
          
          record._after_creates.push proc {
            join.send association.source_association.name_writer, record
            join.save!
          }
          
          record
        end

        def << record
          through = association.through

          # create the join record
          join = through.foreign_klass.new
          join.send through.foreign_key_writer, parent
          join.send association.source_association.name_writer, record
          join.save!
          
          record
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
        
        def all= records
          through = association.through
          
          existing_joins = through.foreign_klass.where(through.foreign_key => parent).send(:raw_all)
          
          existing_ids = Set.new
          existing_joins.each do |join|
            record = join.send(association.source_association.name)
            
            if records.include?(record)
              existing_ids.add(record.id)
            else
              join.destroy
            end
          end
          
          records.each do |record|
            self << record if record.new_record? || !existing_ids.include?(record.id)
          end
          
          records
        end

        def all_ids= ids
          self.all = ids.collect {|id| association.foreign_klass.find(id) }
          ids
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
