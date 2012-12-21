require 'helper'

class ValidatesUniquenessTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      attribute.integer :id, auto: true
      attribute.string  :title
      
      validates_uniqueness_of :title
      
    end
    
  )
  
  test 'validation' do
    @post1 = Post.create!(title: 'Foo')
    @post2 = Post.create!(title: 'Bar')
    
    @post3 = Post.create(title: 'Foo')
    assert_equal ["Title has already been taken"], @post3.errors.full_messages
  end
  
end
