require 'helper'

class HasManyThroughTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      has_many :posts_tags
      has_many :tags, through: :posts_tags
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
  
  test 'all' do
    @tag1 = Tag.create!
    @tag2 = Tag.create!
    @post = Post.create!
    
    @post_tag1 = @post.posts_tags.create!(tag: @tag1)
    @post_tag2 = @post.posts_tags.create!(tag: @tag2)
    @post_tag3 = @post.posts_tags.create!(tag: @tag1)
    
    assert_equal [@tag1, @tag2], @post.tags.all
    assert_equal [@tag1.id, @tag2.id], @post.tag_ids
  end
  
  test '<<' do
    @post = Post.create!
    @tag = Tag.create!
    
    @post.tags << @tag
    
    assert_equal [@tag], @post.tags.all
    assert_equal 1, PostsTag.count
    assert_equal [@tag.posts_tags.first], @post.posts_tags.all
  end
  
  test '=' do
    @post = Post.create!
    @tag1 = Tag.create!
    @tag2 = Tag.create!
    
    @post.tags = [@tag1, @tag2]
    
    assert_equal [@tag1, @tag2], @post.tags.all
    assert_equal 2, @post.tags.count
    
    @post.tags = [@tag1]
    
    assert_equal [@tag1], @post.tags.all
    assert_equal 1, @post.tags.count # destroy the join model
    assert_equal 2, Tag.count # do not destroy the tag model
  end
  
  test 'ids=' do
    @post = Post.create!
    @tag1 = Tag.create!
    @tag2 = Tag.create!
    
    @post.tag_ids = [@tag1.id, @tag2.id]
    
    assert_equal [@tag1, @tag2], @post.tags.all
    assert_equal 2, @post.tags.count
  end
  
  test 'build' do
    @post = Post.create!
    
    @tag = @post.tags.build
    
    assert_equal 0, Tag.count
    assert_equal 0, @post.tags.count
    assert_equal 0, PostsTag.count
    
    @tag.save!
    assert_equal 1, Tag.count
    assert_equal 1, @post.tags.count
    assert_equal 1, @post.posts_tags.count
  end
  
end
