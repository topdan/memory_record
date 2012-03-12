module InactiveRecord
  
  module Scope
    
    def self.included base
      base.extend ClassMethods
      base.send :include, Collection unless included_modules.include?(Collection)
    end
    
    module ClassMethods
      
      def scope name, lambda_proc
        if lambda_proc.is_a? Proc
          inactive_record_collection_class.class_eval do
            define_method name do |*args|
              lambda_proc[*args]
            end
          end
          
        else
          raise "unknown scope type: #{lambda_or_scope.inspect}"
        end
      end
      
    end
    
  end
  
end
