module MemoryRecord
  
  module Collection
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def records
        @records ||= []
      end
      
      def collection
        @collection ||= collection_class.new self, []
      end
      
      def collection_class
        return @collection_class if defined? @collection_class
        
        name = self.name || @name
        @collection_class = eval %(
          class ::#{name}::Collection < ::MemoryRecord::Collection::Instance
            self
          end
        )
      end
      
      def method_missing name, *args, &block
        if collection.respond_to? name
          collection.send name, *args, &block
        else
          super
        end
      end
      
    end
    
    class Relation
      
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
    
    class ThroughRelation < Relation
      
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
    
    class Instance
      
      include Crud::ClassMethods
      include Scope::ClassMethods
      
      attr_reader :klass, :relation
      
      def initialize klass, filters, options = {}
        if klass.is_a? Class
          @relation = nil
          @klass = klass
        elsif klass.is_a? Relation
          @relation = klass
          @klass = @relation.klass
        end
        
        @filters = filters
        @filters = [@filters] unless @filters.is_a?(Array)
        @options = {}
      end
      
      def length
        all.length
      end
      alias count length
      alias size length
      
      def all
        raw_all.collect {|record| record.clone }
      end
      
      def [] *args
        all[*args]
      end
      
      def << record
        if @relation
          @relation << record
          
        elsif record.new_record?
          record.save!
        end
      end
      
      def build attributes = {}
        if @relation
          @relation.build attributes
        else
          @klass.new attributes
        end
      end
      
      def delete record
        if raw_all.include?(record)
          record.destroy
          [record]
        else
          []
        end
      end
      
      def exists?
        raw_all.any?
      end
      
      def delete_all
        all.each do |record|
          record.delete
        end
      end
      
      def destroy_all
        all.each do |record|
          record.destroy
        end
      end
      
      def find id
        record = where(:id => id).first
        raise RecordNotFound.new("id=#{id}") unless record
        record
      end
      
      def first
        record = raw_all.first
        record.clone if record
      end
      
      def first!
        record = first
        raise RecordNotFound.new unless record
        record
      end
      
      def last
        record = raw_all.last
        record.clone if record
      end
      
      def last!
        record = last
        raise RecordNotFound.new unless record
        record
      end
      
      def inspect
        all.inspect
      end
      
      protected
      
      def raw_all
        if @relation
          records = @relation.raw_all
        else
          records = Array.new(@klass.records)
        end
        
        @filters.each {|filter| records = filter[records] }
        
        records
      end
      
      def spawn_child filter
        filters = @filters + [filter]
        self.class.new @klass, filters, @options
      end
      
    end
    
  end
  
end
