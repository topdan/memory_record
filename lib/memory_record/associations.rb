module MemoryRecord
  
  class Association
    
    attr_reader :name, :class_name, :klass, :name_writer
    
    def initialize name, class_name
      @name = name
      @class_name = class_name
      
      @name_writer = "#{@name}="
    end
    
    def klass
      @klass ||= class_name.constantize
    end
    
  end
  
  class BelongsToAssociation < Association
    
    def type
      :belongs_to
    end
    
  end
  
  class HasManyAssociation < Association
    
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
  
  class HasManyThroughAssociation < Association
    
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
  
  module Associations
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def associations
        @associations ||= []
      end
      
      def find_association name
        associations.detect {|a| a.name == name }
      end
      
      def belongs_to name, options = {}
        class_name = options[:class_name] || name.to_s.camelize
        association = BelongsToAssociation.new(name, class_name)
        self.associations.push(association)
        
        id_method = "#{name}_id"
        
        field id_method, type: Integer
        
        define_method name do
          association.klass.where(:id => send(id_method)).first
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
        association = HasManyAssociation.new(name, class_name, foreign_key)
        self.associations.push(association)
        
        define_method name do
          records = []
          relation = Collection::Relation.new(association, self)
          
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
      
      def has_many_through name, options = {}
        through = options[:through]
        source = options[:source] || name.to_s.singularize.underscore.to_sym
        
        through_association = find_association(through)
        raise "has_many through not found: #{through.inspect}" unless through_association
        
        association = HasManyThroughAssociation.new(name, through_association, source)
        self.associations.push(association)
        
        define_method name do
          ids = send(association.ids_method)
          
          relation = Collection::ThroughRelation.new(association, self)
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
      
    end
    
  end
  
end
