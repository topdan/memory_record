require 'helper'

class WillPaginateTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      auto_id
      attribute :title,          :type => String
    end
    
  )
  
  def test_pagination
    @foo = Post.create!(title: 'Foo')
    @bar = Post.create!(title: 'Bar')
    
    @page = Post.page(1).per_page(10)
    assert_equal [@foo, @bar], @page
    assert_equal 1, @page.current_page
    assert_equal 10, @page.per_page
    
    @page = Post.page(1).per_page(1)
    assert_equal [@foo], @page
    
    @page = Post.page(2).per_page(1)
    assert_equal [@bar], @page
  end
  
end
