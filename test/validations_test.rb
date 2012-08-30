require 'helper'

class ValidationsTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      field :title,          :type => String
      field :comments_count, :type => Integer
      
      validates_presence_of :title
    end
    
  )
  
  test 'valid?' do
    @post = Post.new
    assert_false @post.valid?
    
    @post.title = 'Hi'
    assert_true @post.valid?
  end
  
  test 'invalid save' do
    @post = Post.new
    
    assert_false @post.save
    assert_raise MemoryRecord::RecordInvalid do
      @post.save!
    end
  end
  
  test 'invalid create' do
    @post = Post.create
    assert_false @post.persisted?
    
    assert_raise MemoryRecord::RecordInvalid do
      Post.create!
    end
  end
  
end
