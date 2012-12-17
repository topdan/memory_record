module MemoryRecord
  
  class Base
    include ActiveModel::Validations
    extend ActiveModel::Callbacks
    
    define_model_callbacks :initialize, :save, :create, :update, :destroy, :reload
    
    after_reload :reload_relations
    after_reload :reload_attributes
    
    include Associations
    include Collection
    include Field
    include Scope
    include Transactions
    include AutoId
    include Seed
    include Timestamps
    
    attr_reader :raw, :attributes, :changes
    
    def initialize attributes = {}
      @changes = {}
      @attributes = {}
      run_callbacks(:initialize) do
        self.attributes = attributes
      end
    end
    
    def new_record?
      raw == nil
    end
    
    def persisted?
      raw != nil
    end
    
    def changed?
      !changes.empty?
    end
    
    def changed
      changes.keys
    end
    
    def to_key
      [id] if persisted?
    end
    
    def to_param
      id
    end
    
    def attributes= hash
      multi_parameter_attributes = {}
      
      hash.each do |key, value|
        key = key.to_s
        
        if key =~ /^(.*)\(([1-9])i\)/
          multi_parameter_attributes[$1] ||= []
          multi_parameter_attributes[$1].insert($2.to_i, value.to_i)
        else
          send("#{key}=", value)
        end
      end
      
      multi_parameter_attributes.each do |key, pieces|
        # zero index isn't used
        pieces = pieces[1..-1]

        # TODO support other datatypes?
        unless pieces.include?(nil)
          value = DateTime.new(*pieces)
          send("#{key}=", value)
        end
      end
      
      # fill in the missing attributes
      self.class.column_names.each do |name|
        @attributes[name.to_s] ||= nil
      end
      
      hash
    end
    
    def save
      callback_name = persisted? ? :update : :create
      run_callbacks :save do
        run_callbacks callback_name do
          return false unless valid?
          
          if new_record?
            write_attribute(:id, generate_id) if !read_attribute(:id) && respond_to?(:generate_id)
            
            # copy the attributes to a raw record and store it
            raw = self.class.new
            raw.send(:copy_attributes, attributes)
            self.class.records << raw
            self.raw = raw
          else
            # OPTIMIZE use a hash over detect
            record = self.raw || self.class.records.detect {|record| record.id == read_attribute(:id) }
            record.send(:copy_attributes, attributes)
          end
          
        end
      end
      
      @changes = {} # reset the changes
      true
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
    
    def destroy
      run_callbacks :destroy do
        delete
      end
    end
    
    def delete
      self.class.records.delete(self)
    end
    
    def reload
      run_callbacks(:reload) do
      end
      
      self
    end
    
    def == obj
      obj.class == self.class && obj.id == self.id
    end
    
    def inspect
      %(#<#{self.class.name} id=#{id.inspect} attributes=#{attributes.inspect}>)
    end
    
    def clone
      record = self.class.new
      record.send(:copy_attributes, self.attributes)
      record.send(:raw=, self.raw || self)
      record
    end
    
    protected
    
    attr_writer :raw
    
    def write_attribute key, value
      key = key.to_s
      
      attr_changes = self.changes[key]
      old_value = attr_changes ? attr_changes.first : read_attribute(key)
      
      self.attributes[key] = value
      
      new_value = read_attribute(key)
      if new_value == old_value
        changes.delete(key)
      elsif attr_changes
        attr_changes[1] = new_value
      else
        changes[key] = [old_value, new_value]
      end
      
      new_value
    end
    
    def read_attribute key
      self.attributes[key.to_s]
    end
    
    # internal function used to bypass the type-checking
    def copy_attributes(attributes)
      @changes = {}
      @attributes = attributes.clone
    end
    
    def reload_relations
      @relations = nil
    end
    
    def reload_attributes
      if persisted?
        existing = self.class.find(self.id)
        copy_attributes(existing.attributes)
      end
    end
    
    class << self
      
      def create attributes = {}
        record = new(attributes)
        
        record.transaction do
          record.save
          record
        end
      end
      
      def create! attributes = {}
        record = new(attributes)
        
        record.transaction do
          record.save!
          record
        end
      end
      
    end
    
  end
  
end
