require 'helper'

class CustomIdTest < Test::Unit::TestCase
  include ClassHelper
  
  # these classes implement their record identifiers
  # For example: this generate_id makes id depend on the 
  # record's path, which is useful for file records.
  define_classes %(
    
    class Post < MemoryRecord::Base
      
      attribute :id, type: String
      attribute :path, type: String
      
      protected
      
      def generate_id
        path.gsub('/', '-')
      end
      
    end
    
  )
  
  test 'generate id' do
    @post = Post.create!(path: 'foo/bar')
    assert_equal 'foo-bar', @post.id
    
    @post = Post.create!(path: 'nuts')
    assert_equal 'nuts', @post.id
  end
  
end
