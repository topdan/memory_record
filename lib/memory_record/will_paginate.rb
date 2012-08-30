require 'will_paginate/collection'

module MemoryRecord
  
  module WillPaginate
    
    def page page_number
      page_number = page_number.to_i
      page_number = 1 if page_number < 1
      @options[:page] = page_number
      
      self
    end
    
    def per_page records_count
      page = @options[:page] || 1
      
      records_count = records_count.to_i
      records_count = 10 if records_count == 0
      
      ::WillPaginate::Collection.create(page, records_count, length) do |pager|
        pager.replace self[pager.offset, pager.per_page].to_a
      end
    end
    
  end
  
end

MemoryRecord::Collection::Instance.send :include, MemoryRecord::WillPaginate