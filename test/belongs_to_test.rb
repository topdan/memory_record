require 'helper'

class BelongsToTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      auto_id
      has_many :comments
    end
    
    class Comment < MemoryRecord::Base
      auto_id
      belongs_to :post
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
  
end
