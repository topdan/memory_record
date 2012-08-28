module MemoryRecord
  
  module Scope
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection unless included_modules.include?(Collection)
    end
    
    module ClassMethods
      
      def scope name, lambda_proc
        if lambda_proc.is_a? Proc
          memory_record_collection_class.class_eval do
            define_method name, &lambda_proc
          end
          
        elsif lambda_proc.is_a?(Collection::Instance)
          memory_record_collection_class.class_eval do
            define_method name, lambda { lambda_proc }
          end
          
        else
          raise "unknown scope type: #{name.inspect}"
        end
      end
      
    end
    
  end
  
end