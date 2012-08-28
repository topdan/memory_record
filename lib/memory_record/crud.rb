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
      self.class.all.delete(self)
    end
    
    def destroy
      run_callbacks :destroy do
        self.class.all.delete(self)
      end
    end
    
    def save
      callback_name = persisted? ? :update : :create
      run_callbacks :save do
        run_callbacks callback_name do
          if valid?
            @is_persisted = true
            self.class.all << self
            true
          else
            false
          end
        end
      end
    end
    
    def persisted?
      @is_persisted == true
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
      
      def create attributes = {}
        if respond_to? :new
          record = new attributes
        else
          record = build attributes
        end
        record.save
        record
      end
      
      def create! attributes = {}
        if respond_to? :new
          record = new attributes
        else
          record = build attributes
        end
        record.save!
        record
      end
      
    end
    
  end
  
end
