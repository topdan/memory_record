require 'helper'

class FindingTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      
      attribute.integer :id, auto: true
      attribute.string  :title
      attribute.string  :author
      
      scope :with_title, lambda {|title| where(title: title) }
      scope :with_author, lambda {|author| where(author: author) }
      
      scope :untitled, where(title: nil)
      
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
  
  test 'subtraction from an array' do
    @foo = Post.create!(title: 'foo')
    @copy = Post.first
    
    assert_equal [], [@foo] - [@copy]
  end
  
  test 'find_by_*' do
    @foo = Post.create!(title: 'foo')
    
    assert_equal @foo, Post.find_by_title('foo')
  end
  
  test 'ordering' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    
    # ordering with symbols
    assert_equal [@bar, @foo], Post.order(:title).all
    assert_equal [@foo, @bar], Post.order([:title, :desc]).all
    assert_equal [@bar, @foo], Post.order([:title, :asc]).all
    
    # ordering with strings
    assert_equal [@foo, @bar], Post.order(['title', 'desc']).all
    assert_equal [@bar, @foo], Post.order(['title', 'asc']).all
  end
  
  test 'offset and limit' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    
    assert_equal [@bar], Post.offset(1).all
    assert_equal [@foo], Post.limit(1).all
  end
  
  test 'remove_if and keep_if' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    @untitled = Post.create!
    
    @posts = Post.remove_if {|post| post.title =~ /f/ }
    assert_equal [@bar, @untitled], @posts.all
    
    @posts = Post.keep_if {|post| post.title =~ /f/ }
    assert_equal [@foo], @posts.all
  end
  
  test 'named scopes' do
    @foo = Post.create!(title: 'foo', author: 'dan')
    @bar = Post.create!(title: 'bar', author: 'dave')
    @untitled = Post.create!
    
    assert_equal @foo, Post.with_title('foo').first
    assert_equal @untitled, Post.untitled.first
    
    assert_equal @foo, Post.where(title: 'foo').first
    
    assert_equal @foo, Post.with_title('foo').with_author('dan').first
  end
  
  test 'two values in a where clause' do
    @foo = Post.create!(title: 'foo')
    @bar = Post.create!(title: 'bar')
    
    assert_equal [@foo], Post.where(id: @foo.id, title: 'foo').all
    assert_equal [], Post.where(id: @foo.id, title: 'bar').all
  end
  
  test 'finding an integer by sending in a string' do
    @foo = Post.create!(title: 'Foo')
    @bar = Post.create!(title: 'Bar')
    
    assert_equal [@foo], Post.where(id: @foo.id.to_s).all
    assert_equal [@foo], Post.where(id: @foo.id.to_s, title: 'Foo').all
  end
  
  test 'finding in a list of possible values' do
    @foo = Post.create!
    
    assert_equal @foo, Post.where(id: [@foo.id, 5522]).first
  end
  
end
