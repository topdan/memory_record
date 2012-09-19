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
            write_attribute :id, generate_id
            self.class.records << self
          else
            record = self.class.records.detect {|record| record.id == read_attribute(:id) }
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
    
    def update_attributes attributes = {}
      transaction do
        self.attributes = attributes
        save
      end
    end
    
    def update_attributes! attributes = {}
      transaction do
        self.attributes = attributes
        save!
      end
    end
    
    module ClassMethods
      
      def create attributes = {}
        if respond_to? :build
          record = build
        else
          record = new
        end
        
        record.transaction do
          record.attributes = attributes
          record.save
          record.clone
        end
      end
      
      def create! attributes = {}
        if respond_to? :build
          record = build
        else
          record = new
        end

        record.transaction do
          record.attributes = attributes
          record.save!
          record.clone
        end
      end
      
    end
    
  end
  
end
