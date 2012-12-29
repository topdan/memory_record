module MemoryRecord
  
  class Base
    include ActiveModel::Validations
    extend ActiveModel::Callbacks
    
    define_model_callbacks :initialize, :save, :create, :update, :destroy, :reload
    
    after_reload :reload_relations
    after_reload :reload_attributes
    
    extend Attribute
    extend Validations::ClassMethods
    
    include Associations
    include Transactions
    include Timestamps
    
    attr_reader :changes
    
    def initialize(attributes = {})
      attributes ||= {}
      
      @changes = {}
      
      run_callbacks(:initialize) do
        if attributes.is_a?(Row)
          @row = attributes
          @attributes = Hash.new
          @attributes.merge!(@row)
        else
          @attributes = {}
          self.attributes = attributes
        end
      end
    end
    
    def new_record?
      row == nil
    end
    
    def persisted?
      row != nil
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
    
    def attributes
      @attributes.clone
    end
    
    def attributes= hash
      multi_parameter_attributes = {}
      
      hash.each do |key, value|
        key = key.to_s
        
        if key =~ /^(.*)\(([1-9])i\)/
          multi_parameter_attributes[$1] ||= []
          multi_parameter_attributes[$1][$2.to_i] = value.to_i
        else
          send("#{key}=", value)
        end
      end
      
      multi_parameter_attributes.each do |key, pieces|
        # zero index isn't used
        pieces = pieces[1..-1]

        # TODO support other datatypes?
        unless pieces.include?(nil)
          if Time.respond_to?(:zone) && Time.zone
            pieces = pieces.fill(0, pieces.length...6) if pieces.length < 6
            pieces.push(Time.zone.formatted_offset)
          end
          
          value = DateTime.new(*pieces)
          send("#{key}=", value)
        end
      end
      
      # FIXME this shouldn't be here
      # fill in the missing attributes
      self.class.attributes.each do |attribute|
        @attributes[attribute.name] ||= attribute.default_value
      end
      
      hash
    end
    
    def save
      callback_name = persisted? ? :update : :create
      run_callbacks :save do
        run_callbacks callback_name do
          return false unless valid?
          
          if new_record?
            generate_auto_attributes
            @row = self.table.insert(attributes)
          else
            self.table.update(self.row, @attributes)
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
      table.delete(row)
    end
    
    def reload
      run_callbacks(:reload) {}
      self
    end
    
    def table
      self.class.table
    end
    
    def == obj
      obj.class == self.class && obj.id == self.id
    end
    
    def [](key)
      read_attribute(key)
    end
    
    def []=(key, value)
      write_attribute(key, value)
    end
    
    def inspect
      %(#<#{self.class.name} id=#{id.inspect} attributes=#{@attributes.inspect}>)
    end
    
    protected
    
    attr_reader :row
    
    def write_attribute key, value
      key = key.to_s
      
      attr_changes = self.changes[key]
      old_value = attr_changes ? attr_changes.first : read_attribute(key)
      
      @attributes[key] = value
      
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
      @attributes[key.to_s]
    end
    
    def reload_relations
      @relations = nil
    end
    
    def reload_attributes
      if persisted?
        existing = self.class.find(self.id)
        @attributes = existing.attributes.clone
      end
    end
    
    def generate_auto_attributes
      self.class.attributes.each do |attribute|
        if attribute.auto? && read_attribute(attribute.name).nil?
          write_attribute(attribute.name, attribute.generate_auto(table))
        end
      end
    end
    
    class << self
      
      delegate :length,   to: :collection
      delegate :count,    to: :collection
      delegate :size,     to: :collection
      delegate :all,      to: :collection
      delegate :delete,   to: :collection
      
      delegate :exists?,  to: :collection
      delegate :empty?,   to: :collection
      delegate :any?,     to: :collection
      
      delegate :update_all,  to: :collection
      delegate :delete_all,  to: :collection
      delegate :destroy_all, to: :collection
      
      delegate :collect, to: :collection
      delegate :each,    to: :collection
      delegate :map,     to: :collection
      
      delegate :collect, to: :collection
      delegate :find,    to: :collection
      delegate :first,   to: :collection
      delegate :first!,  to: :collection
      delegate :last,    to: :collection
      delegate :last!,   to: :collection
      
      delegate :remove_if, to: :collection
      delegate :keep_if,   to: :collection
      
      delegate :where,  to: :collection
      delegate :order,  to: :collection
      delegate :limit,  to: :collection
      delegate :offset, to: :collection
      
      def table_name=(name)
        @table_name = name
      end
      
      def table_name
        @table_name ||= self.name.underscore.pluralize
      end
      
      def database
        MemoryRecord.database
      end
      
      def table
        database.find_table!(self.table_name, self.attributes)
      end
      
      def collection
        @collection ||= collection_class.new(self, [])
      end
      
      def collection_class
        @collection_class ||= begin
          name = self.name || @name
          eval %(
            class ::#{name}::Collection < ::MemoryRecord::Collection
              self
            end
          )
        end
      end
      
      def scope name, lambda_proc
        if lambda_proc.is_a?(Proc)
          collection_class.class_eval do
            define_method name, &lambda_proc
          end

          (class << self; self; end).instance_eval { define_method name, &lambda_proc }

        elsif lambda_proc.is_a?(Collection)
          collection_class.class_eval do
            define_method name, lambda { lambda_proc }
          end

          (class << self; self; end).instance_eval { define_method name, lambda { lambda_proc } }

        else
          raise "unknown scope type: #{name.inspect} (#{lambda_proc.class})"
        end
      end

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
