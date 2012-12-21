require 'helper'

class BelongsToPolymorphicTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      attribute.integer :id, auto: true
      
      has_many :comments, as: :parent
    end
    
    class Page < MemoryRecord::Base
      attribute.integer :id, auto: true
      
      has_many :comments, as: :parent
    end
    
    class Comment < MemoryRecord::Base
      attribute.integer :id, auto: true
      
      belongs_to :parent, polymorphic: true
    end
    
  )
  
  test 'blank values' do
    @post = Post.create!
    @comment = Comment.create!
    
    assert_equal [], @post.comments.all
    assert_equal nil, @comment.parent
  end
  
  test 'creation from has_many' do
    @post = Post.create!
    @comment = @post.comments.create!
    
    assert_equal @post, @comment.parent
    assert_equal @post, Comment.first.parent
    assert_equal [@comment], @post.comments.all
  end
  
  test 'reassignment' do
    @post = Post.create!
    @page = Page.create!
    
    @comment = @post.comments.create!
    @comment.parent = @page
    @comment.save!
    
    assert_equal @page, @comment.parent
    assert_equal @page, Comment.first.parent
    
    assert_equal [], @post.comments.all
    assert_equal [@comment], @page.comments.all
  end
  
end
