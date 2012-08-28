module MemoryRecord
  
  module Identifier
    
    def self.included base
      base.extend ClassMethods
      base.instance_variable_set :@current_id, 0
      
      base.class_eval do
        attr_accessor :id
      end
    end
    
    def to_key
      [id] if persisted?
    end
    
    def to_param
      id
    end
    
    def new_record?
      id.nil?
    end
    
    def persisted?
      id != nil
    end
    
    module ClassMethods
      
      def current_id
        @current_id
      end
      
      def pop_id
        @current_id += 1
      end
      
    end
    
  end
end
