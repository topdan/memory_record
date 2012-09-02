require 'helper'

class ValidationsTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      field :title,          :type => String
      field :comments_count, :type => Integer
      
      validates_presence_of :title
      
      has_many :comments
      
      has_many :posts_tags
      has_many :tags, through: :posts_tags
      
    end
    
    class Comment < MemoryRecord::Base
      belongs_to :post
    end
    
    class Tag < MemoryRecord::Base
      has_many :posts_tags
      has_many :posts, through: :posts_tags
    end
    
    class PostsTag < MemoryRecord::Base
      belongs_to :post
      belongs_to :tag
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
  
  test 'has_many during an invalid save' do
    @post = Post.create!(title: 'foo')
    @comment = @post.comments.create!
    
    assert_false @post.update_attributes(title: nil, comment_ids: [])
    
    assert_equal nil, @post.comments.first
    assert_equal [], @post.comment_ids
    
    @post.reload
    assert_equal 1, @post.comments.count
    assert_equal @comment, @post.comments.first
  end
  
  test 'has_many through during an invalid save' do
    @post = Post.create!(title: 'foo')
    @tag = @post.tags.create!
    
    assert_false @post.update_attributes(title: nil, tag_ids: [])
    
    assert_equal nil, @post.tags.first
    assert_equal [], @post.tag_ids
    
    @post.reload
    assert_equal 1, @post.tags.count
    assert_equal @tag, @post.tags.first
  end
  
end
