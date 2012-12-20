require 'helper'

class WillPaginateTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      attribute.integer :id, auto: true
      attribute.string  :title
    end
    
  )
  
  test 'pagination' do
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
  
  # FIXME per_page returns a WillPaginate::Collection class
  # which breaks the scope chaining, but it was the easiest
  # way to implement all this.
  test 'pretty bad API here' do
    assert_raises(NoMethodError) do
      Post.page(2).per_page(1).where(title: 'Foo')
    end
  end
  
end
