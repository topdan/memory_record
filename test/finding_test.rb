require 'helper'

class FindingTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      
      field :title,  :type => String
      field :author, :type => String
      
      scope :with_title, lambda {|title| where(:title => title) }
      scope :with_author, lambda {|author| where(:author => author) }
      
      scope :untitled, where(:title => nil)
      
    end
    
  )
  
  test 'all, first, last' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    
    assert_equal [@foo, @bar], Post.all
    assert_equal @foo, Post.first
    assert_equal @bar, Post.last
    
    assert_raise MemoryRecord::RecordNotFound do
      Post.where(title: 'hi').first!
    end
    
    assert_raise MemoryRecord::RecordNotFound do
      Post.where(title: 'hi').last!
    end
  end
  
  test 'ordering' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    
    assert_equal [@bar, @foo], Post.order(:title).all
    assert_equal [@foo, @bar], Post.order([:title, :desc]).all
    assert_equal [@bar, @foo], Post.order([:title, :asc]).all
  end
  
  test 'offset and limit' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    
    assert_equal [@bar], Post.offset(1).all
    assert_equal [@foo], Post.limit(1).all
  end
  
  test 'delete_if and keep_if' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    @untitled = Post.create!
    
    @posts = Post.remove_if {|post| post.title =~ /f/ }
    assert_equal [@bar, @untitled], @posts.all
    
    @posts = Post.keep_if {|post| post.title =~ /f/ }
    assert_equal [@foo], @posts.all
  end
  
  test 'named scopes' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    @untitled = Post.create!
    
    assert_equal @foo, Post.with_title('foo').first
    assert_equal @untitled, Post.untitled.first
    
    assert_equal @foo, Post.where(title: 'foo', author: nil).first
  end
  
end
