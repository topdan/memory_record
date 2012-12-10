module MemoryRecord
  module Timestamps
    
    def self.included(base)
      base.class_eval do
        before_create :autoset_created_at
        before_save   :autoset_updated_at
      end
      
      base.extend(ClassMethods)
    end
    
    protected
    
    def autoset_created_at
      self.created_at = Time.now if respond_to?(:created_at=)
    end
    
    def autoset_updated_at
      self.updated_at = Time.now if respond_to?(:updated_at=)
    end
    
    module ClassMethods
      
      def timestamps
        field(:created_at, :type => DateTime)
        field(:updated_at, :type => DateTime)
      end
      
    end
    
  end
end
