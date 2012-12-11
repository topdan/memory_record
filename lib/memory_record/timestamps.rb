module MemoryRecord
  module Timestamps
    
    def self.included(base)
      base.class_eval do
        before_create :autoset_timestamps_for_create
        before_save   :autoset_timestamps_for_update
      end
      
      base.extend(ClassMethods)
    end
    
    protected
    
    def autoset_timestamps_for_create
      time = Time.now
      self.created_at ||= time if respond_to?(:created_at=)
      self.updated_at ||= time if respond_to?(:updated_at=)
    end
    
    def autoset_timestamps_for_update
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
