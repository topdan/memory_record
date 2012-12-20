module MemoryRecord
  
  class Row < Hash
    
    # must be the exact object to be equal
    def ==(obj)
      obj.object_id == self.object_id
    end
    
  end
  
  class Table
    
    attr_reader :name, :attributes, :rows
    
    def initialize(name, attributes, options = {})
      @name = name
      @attributes = attributes
      @seed_path = options[:seed_path]
      
      if @seed_path
        @rows = read_rows_from_file(@seed_path)
      else
        @rows = []
      end
    end
    
    def insert(record)
      hash = Row.new
      hash.merge!(record)
      
      @rows << hash
      hash
    end
    
    def delete(record)
      @rows.delete(record)
    end
    
    def update(record, attributes)
      attributes.each do |key, value|
        record[key.to_s] = value
      end
    end
    
    protected
    
    def read_rows_from_file(path)
      json = File.open(@seed_path) {|f| f.read }
      hashes = JSON.parse(json)
      
      attributes_by_name = @attributes.inject({}) do |hash, attribute|
        hash[attribute.name] = attribute
        hash
      end
      
      hashes.collect do |hash|
        row = Row.new
        
        hash.each do |key, value|
          attribute = attributes_by_name[key]
          raise "unknown attribute: #{key.inspect}" unless attribute
          row[key] = attribute.parse(value)
        end
        
        row
      end
    end
    
  end
  
end
