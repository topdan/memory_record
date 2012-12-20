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
        path = auto_seed_path
        if path && File.exists?(path)
          seed!(path)
        end
      end
      
      def update_seeds!
        path = auto_seed_path
        if path
          FileUtils.mkdir_p(File.dirname(path))
          File.open(path, 'w') {|f| f.write(to_json) }
        end
      end
      
      def to_hash
        all.collect do |record|
          attributes = record.attributes.clone
          attributes.keep_if {|key, value| value != find_attribute!(key).default_value }
          attributes
        end
      end
      
      def to_json
        JSON.pretty_generate(to_hash)
      end
      
      protected
      
      def auto_seed_path
        path = MemoryRecord.seed_path
        if path
          filename = "#{name.underscore.pluralize}.json"
          File.join(path, filename)
        end
      end
      
    end
    
  end
  
end
