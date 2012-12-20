module MemoryRecord
  
  module Scope
    
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def remove_if &block
        filter = lambda {|records| records.delete_if(&block) }
        spawn_child filter
      end
      
      def keep_if &block
        filter = lambda {|records| records.keep_if(&block) }
        spawn_child filter
      end
      
      def scope name, lambda_proc
        if lambda_proc.is_a?(Proc)
          collection_class.class_eval do
            define_method name, &lambda_proc
          end
          
          (class << self; self; end).instance_eval { define_method name, &lambda_proc }
          
        elsif lambda_proc.is_a?(Collection::Instance)
          collection_class.class_eval do
            define_method name, lambda { lambda_proc }
          end
          
          (class << self; self; end).instance_eval { define_method name, lambda { lambda_proc } }
          
        else
          raise "unknown scope type: #{name.inspect} (#{lambda_proc.class})"
        end
      end
      
      def where conditions = {}
        filter = lambda do |records|
          if conditions.keys.length == 1
            key = conditions.keys.first.to_s
            value = conditions.values.first
            
            records.keep_if {|r| r.send(key) == value }
          else
            records.keep_if {|r| conditions.detect {|k, v| r.send(k) == v }}
          end
        end
        
        spawn_child filter
      end
      
      def order attribute_and_direction
        if attribute_and_direction.is_a?(Array)
          attribute = attribute_and_direction.first
          direction = attribute_and_direction.last
          
        else
          attribute = attribute_and_direction
          direction = :asc
        end
        
        direction = direction.to_sym if direction.is_a?(String)
        
        filter = lambda do |records|
          records.sort! do |a, b|
            a1 = a.send attribute
            b1 = b.send attribute
            
            if a1.nil? && b1.nil?
              0
            elsif a1.nil?
              direction == :desc ? 1 : -1
            elsif b1.nil?
              direction == :desc ? -1 : 1
            elsif direction == :desc
              b1 <=> a1
            else
              a1 <=> b1
            end
          end
        end
        
        spawn_child filter
      end
      
      def limit count
        filter = lambda {|records| records.slice!(count..-1) }
        spawn_child filter
      end
      
      def offset count
        filter = lambda {|records| records.slice!(0..count-1) }
        spawn_child filter
      end
      
    end
    
  end
  
end
