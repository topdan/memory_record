module ClassHelper
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  def setup
    define_classes
  end
  
  def teardown
    undefine_classes
  end
  
  def undefine_classes
    return unless @defined_classes
    @defined_classes.each do |klass|
      Object.send(:remove_const, klass) rescue nil
    end
  end
  
  module ClassMethods
    
    def define_classes code
      define_method :define_classes do
        existing_constants = Object.constants
        Object.class_eval(code)
        new_constants = Object.constants - existing_constants
        
        @defined_classes = new_constants
      end
      
    end
    
  end
  
end
