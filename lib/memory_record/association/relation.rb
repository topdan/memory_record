module MemoryRecord
  module Association
    
    class Relation
      
      attr_reader :association, :parent
      
      def initialize association, parent
        @association = association
        @parent = parent
      end
      
      def foreign_klass
        @association.foreign_klass
      end
      
      def name
        @association.name
      end
      
      def build attributes = {}
        raise NotImplementedError.new('subclass must implement')
      end
      
      def << record
        raise NotImplementedError.new('subclass must implement')
      end
      
      def raw_all
        raise NotImplementedError.new('subclass must implement')
      end
      
    end
    
  end
end
