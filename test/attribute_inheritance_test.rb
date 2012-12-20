require 'helper'

class AttributeInheritanceTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      attribute.string :title
    end
    
    class SpecialPost < Post
      attribute.string :special_person
    end
    
  )
  
  def test_inheritance
    assert_equal 2, SpecialPost.attributes.length
    assert_equal 'title', SpecialPost.attributes.first.name
    assert_equal 'special_person', SpecialPost.attributes.last.name
  end
  
end