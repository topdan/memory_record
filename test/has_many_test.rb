require 'helper'

class HasManyTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      has_many :comments
    end
    
    class Comment < MemoryRecord::Base
      belongs_to :post
    end
    
  )
  
  test '=' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    @comment3 = Comment.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    assert_equal [@comment1.id, @comment2.id], @post.comment_ids
    
    @post.comments = [@comment3]
    assert_equal [@comment3], @post.comments.all
  end
  
  test 'ids=' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    @comment3 = Comment.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    assert_equal [@comment1.id, @comment2.id], @post.comment_ids
    
    @post.comment_ids = [@comment3.id]
    assert_equal [@comment3], @post.comments.all
  end
  
  test '<<' do
    @post = Post.create!
    @comment1 = Comment.create!
    @comment2 = Comment.create!
    
    @post.comments << @comment1
    @post.comments << @comment2
    
    assert_equal @post, @comment1.post
    assert_equal @post, @comment2.post
    
    assert_equal [@comment1, @comment2], @post.comments.all
  end
  
  test '#delete_all' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    
    @post.comments.delete_all
    assert_equal [], @post.comments.all
  end
  
  test '#delete' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    
    @post.comments.delete(@comment1)
    assert_equal [@comment2], @post.comments.all
  end
  
  test '#exists?' do
    @post = Post.create!
    assert_false @post.comments.exists?
    
    @comment1 = @post.comments.create!
    assert_true @post.comments.exists?
  end
  
end