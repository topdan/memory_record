module MemoryRecord
  
  module Seed
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def seed!(filename)
        json = File.open(filename) {|f| f.read }
        hashes = JSON.parse(json)
        
        hashes.each do |hash|
          create!(hash)
        end
      end
      
      def auto_seed!
        path = MemoryRecord.seed_path
        if path
          filename = "#{name.underscore.pluralize}.json"
          fullpath = File.join(path, filename)
          seed!(fullpath) if File.exists?(fullpath)
        end
      end
      
      def backup!
        
      end
      
    end
    
  end
  
end
