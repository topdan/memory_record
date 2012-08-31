module MemoryRecord
  module Associations
    module HasMany
      
      def has_many name, options = {}
        if options[:through]
          has_many_through(name, options)
          return
        end
        
        foreign_key = options[:foreign_key] || self.name.foreign_key
        foreign_key = $` if foreign_key =~ /_id$/ # remove the _id since inactive records don't rely on IDs
        foreign_key_writer = "#{foreign_key}="
        
        is_uniq = options[:uniq]
        
        class_name = options[:class_name] || name.to_s.singularize.camelize
        association = Association.new(name, class_name, foreign_key)
        self.associations.push(association)
        
        define_method name do
          records = []
          relation = Relation.new(association, self)
          
          association.klass.collection_class.new relation, []
        end
        
        ids_name = name.to_s.singularize + "_ids"
        define_method ids_name do
          send(name).send(:raw_all).map(&:id)
        end
        
        define_method "#{name}=" do |records|
          existing_records = send(name).send(:raw_all)
          
          missing_records = existing_records - records
          new_records = records - existing_records
          
          missing_records.each {|record| record.destroy }
          new_records.each {|record| record.send(foreign_key_writer, self) ; record.save! }
          records
        end
        
        define_method "#{ids_name}=" do |ids|
          records = ids.collect {|id| association.klass.find(id) }
          send "#{name}=", records
          ids
        end
        
      end
      
      class Association < Association

        attr_reader :foreign_key, :foreign_key_writer

        def initialize name, class_name, foreign_key
          super name, class_name

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

        attr_reader :association, :parent

        def initialize association, parent
          @association = association
          @parent = parent
        end

        def klass
          @association.klass
        end

        def name
          @association.name
        end

        def foreign_key
          @association.foreign_key
        end

        def build attributes = {}
          klass.new attributes.merge(foreign_key => parent)
        end

        def << record
          record.send "#{foreign_key}=", parent
          record.save!
        end

        def raw_all
          records = Array.new(klass.records)
          records.keep_if {|record| record.send(foreign_key) == parent}
          records
        end

      end

    end
  end
end
