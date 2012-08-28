module MemoryRecord
  
  module Finders
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def find id
        record = where(:id => id).first
        raise RecordNotFound.new("id=#{id}") unless record
        record
      end
      
      def first!
        record = first
        raise RecordNotFound.new unless record
        record
      end
      
      def last!
        record = last
        raise RecordNotFound.new unless record
        record
      end
      
    end
    
  end
  
end

