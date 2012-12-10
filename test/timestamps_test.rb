require 'helper'

class TimestampsTest < Test::Unit::TestCase
  
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      auto_id
      timestamps
    end
    
  )
  
  def test_created_at
    @created = Time.now
    Time.stubs(:now).returns(@created)
    
    @post = Post.new
    
    assert_nil @post.created_at
    assert_nil @post.updated_at
    
    @post.save!
    
    assert_equal @created.to_i, @post.created_at.to_time.to_i
    assert_equal @created.to_i, @post.updated_at.to_time.to_i
    
    @updated = Time.now + 4 # seconds
    Time.stubs(:now).returns(@updated)
    
    @post.save!
    
    assert_equal @created.to_i, @post.created_at.to_time.to_i
    assert_equal @updated.to_i, @post.updated_at.to_time.to_i
  end
  
end
