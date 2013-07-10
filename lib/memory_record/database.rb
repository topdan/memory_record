module MemoryRecord
  
  class Database
    
    def initialize
      @tables_by_name = {}
    end
    
    def tables
      @tables_by_name.values
    end
    
    def find_table(name)
      @tables_by_name[name.to_s]
    end
    
    def find_table!(name, attributes, options = {})
      table = @tables_by_name[name]
      
      if table.nil?
        table = Table.new(name, attributes, options)
        @tables_by_name[table.name] = table
      end
      
      table
    end
    
    def reset!
      @tables_by_name = {}
    end
    
  end
  
end
