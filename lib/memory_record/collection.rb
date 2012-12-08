module MemoryRecord
  
  module Collection
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def records
        return @records if defined? @records
        
        @records = []
        auto_seed!
        @records
      end
      
      def collection
        @collection ||= collection_class.new(self, [])
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
    
    class Instance
      
      include Crud::ClassMethods
      include Scope::ClassMethods
      
      attr_reader :klass, :relation
      
      def initialize klass, filters, options = {}
        if klass.is_a? Class
          @relation = nil
          @klass = klass
        elsif klass.is_a? Associations::Relation
          @relation = klass
          @klass = @relation.foreign_klass
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
      
      def empty?
        raw_all.empty?
      end
      
      def delete_all
        raw_all.each do |record|
          record.delete
        end
      end
      
      def destroy_all
        raw_all.each do |record|
          record.destroy
        end
      end
      
      def collect &block
        all.collect(&block)
      end
      
      def each &block
        all.each(&block)
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
        
        @filters.each {|filter| filter[records] }
        
        records
      end
      
      def spawn_child filter
        filters = @filters + [filter]
        self.class.new(@relation || @klass, filters, @options)
      end
      
    end
    
  end
  
end
