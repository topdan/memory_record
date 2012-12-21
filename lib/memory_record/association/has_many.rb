module MemoryRecord
  module Association
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
        
        association.define_dependent(options[:dependent])
      end
      
      class Association < MemoryRecord::Association::Base

        attr_reader :foreign_key, :foreign_key_writer, :as, :as_writer

        def initialize klass, name, options = {}
          class_name = options[:class_name] || name.to_s.singularize.camelize
          super klass, name, class_name

          @foreign_key = options[:foreign_key] || klass.name.to_s.foreign_key
          @foreign_key_writer = "#{@foreign_key}="
          
          @as = options[:as] || klass.name.underscore.demodulize
          @as_writer = "#{@as}="
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

        def belongs_to_association
          return @belongs_to_association if defined?(@belongs_to_association)
          @belongs_to_association = foreign_klass.find_association(self.as)
        end

        def define_dependent type
          association = self
          method_name = "after_destroy_#{name}_dependent"
          
          klass.class_eval do
            case type.to_s
            when 'nullify'
              before_destroy method_name
              
              define_method method_name do
                send(association.name).all.each do |record|
                  record.send "#{association.foreign_key}=", nil
                  record.save!
                end
              end

            when 'delete_all'
              before_destroy method_name
              
              define_method method_name do
                send(association.name).delete_all
              end

            when 'destroy'
              before_destroy method_name
              
              define_method method_name do
                send(association.name).destroy_all
              end
            end
          end

        end
        
      end

      class Relation < MemoryRecord::Association::Relation

        def as
          @association.as
        end

        def foreign_key
          @association.foreign_key
        end

        def belongs_to_association
          @association.belongs_to_association
        end

        def build attributes = {}
          association.foreign_klass.new attributes.merge(as => parent)
        end

        def << record
          record.send @association.as_writer, parent
          record.save!
        end

        def all
          association.foreign_klass.collection_class.new self, []
        end

        def all_ids
          parent.send(name).all.map(&:id)
        end

        def all= records
          existing_records = parent.send(name).all
          @unsaved_all = records
          
          parent.after_save(transaction: true) do
            missing_records = existing_records - records
            new_records = records - existing_records
            
            missing_records.each {|record| record.destroy }
            new_records.each {|record| record.send(association.as_writer, parent) ; record.save! }
            @unsaved_all = nil
          end
          
          records
        end

        def all_ids= ids
          self.all = ids.collect {|id| association.foreign_klass.find(id) }
          ids
        end

        def rows
          return @unsaved_all if @unsaved_all
          
          parent_id = parent.id
          
          rows = association.foreign_klass.table.rows.clone
          
          if belongs_to_association && belongs_to_association.polymorphic?
            
            rows.keep_if do |row| 
              row[belongs_to_association.id_attribute] == parent_id && 
                row[belongs_to_association.polymorphic_type_attribute] == parent.class.name
            end
            
          else
            rows.keep_if {|row| row[foreign_key.to_s] == parent_id}
          end
          
          rows
        end

      end

    end
  end
end
