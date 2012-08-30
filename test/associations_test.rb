require 'helper'

class AssociationsTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      has_many :comments
      has_many :commenters, through: :comments, source: :user
    end
    
    class Comment < MemoryRecord::Base
      belongs_to :post
      belongs_to :user
    end
    
    class User < MemoryRecord::Base
      has_many :comments
    end
    
  )
  
  test 'belongs_to' do
    @post = Post.create!
    @comment = Comment.create!(post: @post)
    
    assert_equal @post, @comment.post
    assert_equal @post.id, @comment.post_id
    
    @foo = Post.create!
    @comment.post = @foo
    assert_equal @foo, @comment.post
    
    @comment.post_id = @post.id
    assert_equal @post, @comment.post
  end
  
  test 'has_many assignment' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    @comment3 = Comment.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    assert_equal [@comment1.id, @comment2.id], @post.comment_ids
    
    @post.comments = [@comment3]
    assert_equal [@comment3], @post.comments.all
  end
  
  test 'has_many ids assigment' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    @comment3 = Comment.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    assert_equal [@comment1.id, @comment2.id], @post.comment_ids
    
    @post.comment_ids = [@comment3.id]
    assert_equal [@comment3], @post.comments.all
  end
  
  test 'has_many through' do
    @user1 = User.create!
    @user2 = User.create!
    @post = Post.create!
    
    @comment1 = @post.comments.create!(user: @user1)
    @comment2 = @post.comments.create!(user: @user2)
    @comment3 = @post.comments.create!(user: @user1)
    
    assert_equal [@user1, @user2], @post.commenters.all
    assert_equal [@user1.id, @user2.id], @post.commenter_ids
  end
  
  test 'has_many through concat' do
    @post = Post.create!
    @user = User.create!
    
    @post.commenters << @user
    
    assert_equal [@user], @post.commenters.all
    assert_equal [@user.comments.first], @post.comments.all
  end
  
  test 'has_many concat' do
    @post = Post.create!
    @comment1 = Comment.create!
    @comment2 = Comment.create!
    
    @post.comments << @comment1
    @post.comments << @comment2
    
    assert_equal @post, @comment1.post
    assert_equal @post, @comment2.post
    
    assert_equal [@comment1, @comment2], @post.comments.all
  end
  
  test 'has_many #delete_all' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    
    @post.comments.delete_all
    assert_equal [], @post.comments.all
  end
  
  test 'has_many #delete' do
    @post = Post.create!
    @comment1 = @post.comments.create!
    @comment2 = @post.comments.create!
    
    assert_equal [@comment1, @comment2], @post.comments.all
    
    @post.comments.delete(@comment1)
    assert_equal [@comment2], @post.comments.all
  end
  
  test 'has_many #exists?' do
    @post = Post.create!
    assert_false @post.comments.exists?
    
    @comment1 = @post.comments.create!
    assert_true @post.comments.exists?
  end
  
end
