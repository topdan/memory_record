module MemoryRecord
  
  class Table
    
    attr_reader :name, :attributes, :rows, :autos, :seed_path
    
    def initialize(name, attributes)
      @name = name
      @attributes = attributes
      @seed_path = generate_seed_path
      @autos = {}
      
      if @seed_path && File.exists?(@seed_path)
        @rows = read_rows_from_file(@seed_path)
      else
        @rows = []
      end
    end
    
    def clear!
      @rows = []
      @autos = {}
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
    
    def write_seeds!
      FileUtils.mkdir_p(File.dirname(@seed_path))
      File.open(@seed_path, 'w') {|f| f.write(to_json) }
    end
    
    def to_hash
      rows.collect do |row|
        row = row.clone
        
        row.delete_if do |key, value|
          attribute = attributes_by_name[key]
          value == attribute.default_value
        end
        
        row
      end
    end
    
    def to_json
      JSON.pretty_generate(to_hash)
    end
    
    protected
    
    def attributes_by_name
      @attributes_by_name ||= @attributes.inject({}) do |hash, attribute|
        hash[attribute.name] = attribute
        hash
      end
    end
    
    def generate_seed_path
      File.join(MemoryRecord.seed_path, "#{name}.json") if MemoryRecord.seed_path
    end
    
    def read_rows_from_file(path)
      json = File.open(@seed_path) {|f| f.read }
      hashes = JSON.parse(json)
      
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
