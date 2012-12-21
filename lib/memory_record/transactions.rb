module MemoryRecord
  # not really transactions, but this keeps the saved changes from being written until
  # a valid save is processed, not during attribute assignment
  module Transactions
    
    def self.included(base)
      base.class_eval do
        after_create :run_after_creates
        after_save :run_after_saves
      end
    end
    
    def transaction
      @transaction = true
      yield
    ensure
      @transaction = false
    end
    
    def transaction?
      @transaction == true
    end
    
    def after_create options = {}, &block
      if options[:transaction] == true && !transaction?
        yield
      else
        _after_creates.push(block)
      end
    end
    
    def after_save options = {}, &block
      if options[:transaction] == true && !transaction?
        yield
      else
        _after_saves.push(block)
      end
    end
    
    protected
    
    def _after_creates
      @_after_creates ||= []
    end
    
    def _after_saves
      @_after_saves ||= []
    end
    
    def run_after_creates
      _after_creates.each do |proc|
        proc[self]
      end
      @_after_creates = nil
    end
    
    def run_after_saves
      _after_saves.each do |proc|
        proc[self]
      end
      @_after_saves = nil
    end
    
  end
end
