module MemoryRecord
  class Collection
    
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
        records = @klass.table.rows.collect {|row| klass.new(row) }
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
    
    def any?
      all.any?
    end
    
    def update_all(attributes)
      count = 0
      all.each do |record|
        record.update_attributes(attributes)
        count += 1
      end
      count
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
    
    def map &block
      all.map(&block)
    end
    
    def find id
      record = where(id: id).first
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
    
    def remove_if &block
      filter = lambda {|records| records.delete_if(&block) }
      spawn_child filter
    end
    
    def keep_if &block
      filter = lambda {|records| records.keep_if(&block) }
      spawn_child filter
    end
    
    def where conditions = {}
      filter = lambda do |records|
        if conditions.keys.length == 1
          key = conditions.keys.first.to_s
          value = conditions.values.first
          
          attribute = klass.find_attribute(key)
          if attribute
            records.keep_if {|r| attribute.where?(r.send(key), value) }
          else
            records.keep_if {|r| r.send(key) == value }
          end
          
        else
          # find the attribute if available (not inside the #keep_if loop)
          attributes = {}
          conditions.each do |k, v|
            attribute = klass.find_attribute(k)
            if attribute
              attributes[attribute] = v
            else
              attributes[k.to_s] = v
            end
          end
          
          records.keep_if do |record|
            success = true
            
            # for each condition in the where hash
            attributes.each do |k, v|
              
              # use the attribute to determine where?
              if k.is_a?(Attribute::Base)
                s = k.where?(record.send(k.name), v)
                
              # straight == check
              else
                s = record.send(k) == v
              end
              
              unless s
                success = false
                break # short-curcuit
              end
            end
            
            success
          end
        end
      end
      
      spawn_child filter
    end
    
    def order attribute_and_direction
      if attribute_and_direction.is_a?(Array)
        attribute = attribute_and_direction.first
        direction = attribute_and_direction.last
        
      else
        attribute = attribute_and_direction
        direction = :asc
      end
      
      direction = direction.to_sym if direction.is_a?(String)
      
      filter = lambda do |records|
        records.sort! do |a, b|
          a1 = a.send attribute
          b1 = b.send attribute
          
          if a1.nil? && b1.nil?
            0
          elsif a1.nil?
            direction == :desc ? 1 : -1
          elsif b1.nil?
            direction == :desc ? -1 : 1
          elsif direction == :desc
            b1 <=> a1
          else
            a1 <=> b1
          end
        end
      end
      
      spawn_child filter
    end
    
    def limit count
      filter = lambda {|records| records.slice!(count..-1) }
      spawn_child filter
    end
    
    def offset count
      filter = lambda {|records| records.slice!(0..count-1) }
      spawn_child filter
    end
    
    def table
      klass.table
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
