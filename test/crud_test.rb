require 'helper'

class CrudTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      auto_id
      field :title,          :type => String
      field :comments_count, :type => Integer
    end
    
  )
  
  test 'only create when saved' do
    @post = Post.new(title: 'foo')
    
    assert_equal 0, Post.count
    @post.save
    assert_equal 1, Post.count
  end
  
  test 'only update when saved' do
    @post = Post.create!(title: 'foo')
    @post.title = 'hi'
    
    assert_equal 'foo', Post.first.title
    @post.save
    assert_equal 'hi', Post.first.title
  end
  
  test 'destroy' do
    @post = Post.create!
    
    assert_equal 1, Post.count
    @post.destroy
    assert_equal 0, Post.count
  end
  
  test 'delete' do
    @post = Post.create!
    
    assert_equal 1, Post.count
    @post.delete
    assert_equal 0, Post.count
  end
  
  test 'destroy_all' do
    @post1 = Post.create!
    @post2 = Post.create!
    
    assert_equal 2, Post.count
    Post.destroy_all
    assert_equal 0, Post.count
  end
  
  test 'delete_all' do
    @post1 = Post.create!
    @post2 = Post.create!
    
    assert_equal 2, Post.count
    Post.delete_all
    assert_equal 0, Post.count
  end
  
  test 'clone gives access to raw' do
    @post1 = Post.create!
    @post2 = Post.find(@post1.id)
    
    assert @post1.raw
    assert_equal @post1.raw.hash, @post2.raw.hash
    assert_not_equal @post1.hash, @post2.hash
  end
  
  test 'new, save, edit treats persisted data properly' do
    @post = Post.new(title: 'Bar')
    assert_false @post.persisted?
    
    @post.save!
    assert_true @post.persisted?
    
    @post.title = 'Foo'
    assert_equal 'Foo', @post.title
    assert_equal 'Bar', Post.find(@post.id).title
  end
  
end
