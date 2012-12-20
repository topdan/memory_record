module MemoryRecord
  class Collection
    
    include Scope::ClassMethods
    
    attr_reader :klass, :relation
    
    def initialize klass, filters, options = {}
      if klass.is_a? Class
        @relation = nil
        @klass = klass
      elsif klass.is_a? Association::Relation
        @relation = klass
        @klass = @relation.foreign_klass
      end
      
      @filters = filters
      @filters = [@filters] unless @filters.is_a?(Array)
      @options = {}
    end
    
    def length
      all.length
    end
    alias count length
    alias size length
    
    def all
      if @relation
        records = @relation.rows.collect {|row| klass.new(row) }
      else
        records = @klass.rows.collect {|row| klass.new(row) }
      end
      
      @filters.each {|filter| filter[records] }
      
      records
    end
    
    def [] *args
      all[*args]
    end
    
    def << record
      if @relation
        @relation << record
        
      elsif record.new_record?
        record.save!
      end
    end
    
    def build attributes = {}
      if @relation
        @relation.build attributes
      else
        @klass.new attributes
      end
    end
    
    def delete record
      if all.include?(record)
        record.destroy
        [record]
      else
        []
      end
    end
    
    def exists?
      all.any?
    end
    
    def empty?
      all.empty?
    end
    
    def delete_all
      all.each do |record|
        record.delete
      end
    end
    
    def destroy_all
      all.each do |record|
        record.destroy
      end
    end
    
    def collect &block
      all.collect(&block)
    end
    
    def each &block
      all.each(&block)
    end
    
    def find id
      record = where(:id => id).first
      raise RecordNotFound.new("id=#{id.inspect}") unless record
      record
    end
    
    def first
      all.first
    end
    
    def first!
      record = first
      raise RecordNotFound.new unless record
      record
    end
    
    def last
      all.last
    end
    
    def last!
      record = last
      raise RecordNotFound.new unless record
      record
    end
    
    def create attributes = {}
      record = build(attributes)
      record.save
      record
    end
    
    def create! attributes = {}
      record = build(attributes)
      record.save!
      record
    end
    
    def table
      klass.table
    end
    
    def inspect
      all.inspect
    end
    
    protected
    
    def spawn_child filter
      filters = @filters + [filter]
      self.class.new(@relation || @klass, filters, @options)
    end
    
  end
  
end
