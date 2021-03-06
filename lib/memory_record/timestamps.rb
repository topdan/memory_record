module MemoryRecord
  module Timestamps
    
    def self.included(base)
      base.class_eval do
        before_create :autoset_timestamps_for_create
        before_update :autoset_timestamps_for_update
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
      self.updated_at = Time.now if respond_to?(:updated_at=) && changed?
    end
    
    module ClassMethods
      
      def timestamps
        attribute.datetime(:created_at)
        attribute.datetime(:updated_at)
      end
      
    end
    
  end
end
