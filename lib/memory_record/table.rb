module MemoryRecord
  
  class Table
    
    class UnknownColumn < Exception ; end
    
    attr_reader :name, :attributes, :rows, :autos, :seed_path
    
    def initialize(name, attributes)
      @name = name
      @attributes = attributes
      @seed_path = generate_seed_path
      @autos = {}
      
      reload
    end
    
    def reload
      if @seed_path && File.exists?(@seed_path)
        @rows = read_rows_from_file(@seed_path)
      else
        @rows = []
      end
    end
    
    def clear!
      log { "CLEAR #{@name.inspect}" }
      
      @rows = []
      @autos = {}
    end
    
    def insert(record)
      hash = Row.new
      hash.merge!(record)
      
      log { "INSERT INTO #{@name.inspect} VALUE #{hash.inspect}" }
      @rows << hash
      hash
    end
    
    def delete(record)
      log { "DELETE FROM #{@name.inspect} WHERE id=#{record["id"].inspect}" }
      @rows.delete(record)
    end
    
    def update(record, attributes)
      log { "UPDATE #{@name.inspect} WHERE id=#{record["id"].inspect} WITH #{attributes.inspect}" }
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
        hash = Hash.new
        
        row.each do |key, value|
          attribute = attributes_by_name[key]
          
          # FIXME? not sure if it's a good idea leaving off
          # default attribute values (in case the code changes)
          # but it sure makes my JSON files nice and readable
          unless attribute.nil? || attribute.default_value == value
            hash[key] = value
          end
        end
        
        hash
      end
    end
    
    def to_json
      JSON.pretty_generate(to_hash)
    end
    
    protected
    
    def log
      # TODO a more general way of logging
      Rails.logger.info(yield) if defined?(Rails)
    end
    
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
          raise UnknownColumn.new("unknown column: #{key.inspect}") unless attribute
          row[key] = attribute.parse(value)
        end
        
        row
      end
    end
    
  end
  
end
