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
  
  test 'inheritance of introspection' do
    assert_equal 2, SpecialPost.attributes.length
    assert_equal 'title', SpecialPost.attributes.first.name
    assert_equal 'special_person', SpecialPost.attributes.last.name
  end
  
  # TODO
  # test 'single table inheritance' do
  #   @post = Post.create!
  #   @special = SpecialPost.create!
  #   
  #   assert_equal(Post, Post.base_class)
  #   assert_equal(Post, SpecialPost.base_class)
  #   
  #   assert_equal({'type' => 'SpecialPost', 'title' => nil, 'special_person' => nil}, SpecialPost.table.rows.first)
  #   
  #   assert_equal [@post, @special], Post.all
  #   assert_equal [@special], SpecialPost.all
  # end
  
end