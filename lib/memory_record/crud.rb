module MemoryRecord
  
  module Crud
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection
      base.send :include, Field
      base.send :include, ActiveModel::Validations
      
      base.extend ActiveModel::Callbacks
      base.define_model_callbacks :save, :create, :update, :destroy
    end
    
    def delete
      self.class.records.delete(self)
    end
    
    def destroy
      run_callbacks :destroy do
        delete
      end
    end
    
    def save
      callback_name = persisted? ? :update : :create
      run_callbacks :save do
        run_callbacks callback_name do
          return false unless valid?
          
          if new_record?
            @id = self.class.next_id
            self.class.records << self
          else
            record = self.class.records.detect {|record| record.id == @id }
            record.attributes = attributes
          end
          
          true
        end
      end
    end
    
    def save!
      unless save
        raise MemoryRecord::RecordInvalid.new("Validation failed: #{errors.full_messages.join(', ')}")
      end
      
      self
    end
    
    def update_attribute name, value
      update_attributes name => value
    end
    
    def update_attributes attributes = {}
      self.attributes = attributes
      save
    end
    
    def update_attributes! attributes = {}
      self.attributes = attributes
      save!
    end
    
    module ClassMethods
      
      def last_id
        @last_id
      end
      
      def next_id
        @last_id ||= 0
        @last_id += 1
      end
      
      def create attributes = {}
        if respond_to? :build
          record = build attributes
        else
          record = new attributes
        end
        record.save
        record.clone
      end
      
      def create! attributes = {}
        if respond_to? :build
          record = build attributes
        else
          record = new attributes
        end
        record.save!
        record.clone
      end
      
    end
    
  end
  
end
