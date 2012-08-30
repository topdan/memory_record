module MemoryRecord
  
  module Associations
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def belongs_to name, options = {}
        klass = nil
        class_name = options[:class_name] || name.to_s.camelize
        
        id_method = "#{name}_id"
        
        field id_method, type: Integer
        
        define_method name do
          klass ||= class_name.constantize
          klass.where(:id => send(id_method)).first
        end
        
        define_method "#{name}=" do |record|
          send("#{id_method}=", record ? record.id : nil)
          record
        end
      end
      
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
        klass = nil
        
        define_method name do
          records = []
          klass ||= class_name.constantize
          relation = Collection::Relation.new(klass, foreign_key, self)
          
          klass.collection_class.new relation, []
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
          klass ||= class_name.constantize
          records = ids.collect {|id| klass.find(id) }
          send "#{name}=", records
          ids
        end
        
      end
      
      def has_many_through name, options = {}
        through = options[:through]
        source = options[:source] || name.to_s.singularize.underscore
        ids_name = name.to_s.singularize + "_ids"
        
        class_name = options[:class_name] || source.to_s.camelize # TODO reflection on the source association
        klass = nil
        
        define_method name do
          ids = send(ids_name)
          
          klass ||= class_name.constantize
          klass.collection_class.new klass, [], proc {|records|
            records.keep_if {|rec| ids.include?(rec.id) }
          }
        end
        
        define_method ids_name do
          set = Set.new

          records = send(through).send(:raw_all).each do |record| 
            id = record.send("#{source}_id")
            set.add(id) if id
          end

          set.to_a
        end
        
      end
      
    end
    
  end
  
end
