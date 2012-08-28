module MemoryRecord
  
  module Collection
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def inactive_records
        @inactive_records ||= []
      end
      
      def all
        @all ||= inactive_record_collection_class.new self, inactive_records
      end
      
      def inactive_record_collection_class
        return @inactive_record_collection_class if defined? @inactive_record_collection_class
        
        @inactive_record_collection_class = eval %(
          class ::#{self.name}::Collection < ::MemoryRecord::Collection::Instance
            self
          end
        )
      end
      
      def method_missing name, *args
        if all.respond_to? name
          all.send name, *args
        else
          super
        end
      end
      
    end
    
    class Relation
      
      attr_reader :klass, :name, :parent
      
      def initialize klass, name, parent
        @klass = klass
        @name = name
        @parent = parent
      end
      
      def build attributes = {}
        @klass.new attributes.merge(name => parent)
      end
      
    end
    
    class Instance < Array
      
      include Crud::ClassMethods
      include Limit::ClassMethods
      include Offset::ClassMethods
      include Order::ClassMethods
      include Where::ClassMethods
      
      attr_reader :klass, :relation
      
      def initialize klass, contents
        super contents || []
        if klass.is_a? Class
          @klass = klass
        elsif klass.is_a? Relation
          @relation = klass
        end
      end
      
      def all
        self
      end
      
      def << record
        if @klass
          super record
        else
          record.send "#{@relation.name}=", @relation.parent
          record.save! unless record.persisted?
          super record
        end
      end
      
      def build attributes = {}
        if @klass
          @klass.new attributes
        elsif @relation
          @relation.build attributes
        end
      end
      
      def delete_all
        self.clone.each {|record| record.delete }
      end
      
      def destroy_all
        self.clone.each {|record| record.destroy }
      end
      
      def delete_if &block
        self.class.new @klass, Array.new(self).delete_if(&block)
      end
      
      def keep_if &block
        self.class.new @klass, Array.new(self).keep_if(&block)
      end
      
      protected
      
      def spawn_child contents
        self.class.new @klass, contents
      end
      
    end
    
  end
  
end
