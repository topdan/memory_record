module MemoryRecord
  module Attribute
    
    class StringType < Base
      
      def initialize(name, options = {})
        super(name, options)
        
        @prevent_blank = options[:prevent_blank] == true
      end
      
      def prevent_blank?
        @prevent_blank == @prevent_blank
      end
      
      def parse(value)
        return nil if value.nil?
        
        value = value.to_s
        
        if prevent_blank? && value.blank?
          nil
        else
          value
        end
      end
      
    end
    
  end
end
