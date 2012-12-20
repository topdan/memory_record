require 'helper'

class AttributeTest < Test::Unit::TestCase
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      
      attribute :title,          :type => String
      attribute :comments_count, :type => Integer
      attribute :ratio,          :type => Float
      attribute :is_published,   :type => "Boolean", :default => false
      attribute :published_at,   :type => DateTime
      attribute :published_date, :type => Date
      attribute :published_time, :type => Time
      attribute :unknown
    end
    
  )
  
  def test_attributes
    @post = Post.new(title: 'Hi')
    assert_equal 'Hi', @post.title
    
    @post.attributes = {title: 'Foo'}
    assert_equal 'Foo', @post.title
    
    assert_equal({"title" => 'Foo', "comments_count" => nil, "ratio" => nil, "is_published" => false, "published_at" => nil,
      "published_date" => nil, "published_time" => nil, "unknown" => nil}, @post.attributes)
  end
  
  def test_string
    @post = Post.new
    
    @post.title = 'Hi!'
    assert_equal 'Hi!', @post.title
    
    @post.title = 1
    assert_equal '1', @post.title
  end
  
  def test_integer
    @post = Post.new
    
    @post.comments_count = 1
    assert_equal 1, @post.comments_count
    
    @post.comments_count = '2'
    assert_equal 2, @post.comments_count
  end
  
  def test_float
    @post = Post.new
    
    @post.ratio = 1.4
    assert_equal 1.4, @post.ratio
    
    @post.ratio = '1.5'
    assert_equal 1.5, @post.ratio
  end
  
  def test_boolean
    @post = Post.new
    
    assert_equal false, @post.is_published
    assert_equal false, @post.is_published?
    
    @post.is_published = true
    assert_equal true, @post.is_published
    
    [0, "0", false, "false"].each do |false_value|
      @post.is_published = false_value
      assert_equal false, @post.is_published
    end
    
    [1, "1", true, "true"].each do |true_value|
      @post.is_published = true_value
      assert_equal true, @post.is_published
    end
    
    @post.is_published = nil
    assert_nil @post.is_published
  end
  
  def test_datetime
    @post = Post.new
    
    @datetime_now = DateTime.now
    @time_now = Time.now
    @today = Date.today
    
    @post.published_at = @datetime_now
    assert_equal DateTime, @post.published_at.class
    assert_equal @datetime_now, @post.published_at
    
    @post.published_at = @time_now
    assert_equal DateTime, @post.published_at.class
    
    @post.published_at = @today
    assert_equal DateTime, @post.published_at.class
    
    @post.published_at = nil
    assert_equal nil, @post.published_at
    
    @post.published_at = '2012-08-29 12:00am EST'
    assert_equal DateTime, @post.published_at.class
    
    @post.published_at = {
      'year' => 2010,
      'month' => 4,
      'day' => 26,
      'hour' => 4,
      'min' => 45,
      'sec' => 30
    }
    assert_equal 2010, @post.published_at.year
    assert_equal 4, @post.published_at.month
    assert_equal 26, @post.published_at.day
    assert_equal 4, @post.published_at.hour
    assert_equal 45, @post.published_at.min
    assert_equal 30, @post.published_at.sec
    
    @post.published_at = {
      'year' => 2010,
      'month' => 4,
      'day' => 26,
      'hour' => 4,
      'min' => 45
    }
    assert_equal 2010, @post.published_at.year
    assert_equal 4, @post.published_at.month
    assert_equal 26, @post.published_at.day
    assert_equal 4, @post.published_at.hour
    assert_equal 45, @post.published_at.min
    assert_equal 0, @post.published_at.sec
    
    @post.published_at = {
      'year' => 2010,
      'month' => 4,
      'day' => 26
    }
    assert_equal 2010, @post.published_at.year
    assert_equal 4, @post.published_at.month
    assert_equal 26, @post.published_at.day
    assert_equal 0, @post.published_at.hour
    assert_equal 0, @post.published_at.min
    assert_equal 0, @post.published_at.sec
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_at = {'year' => 2010}
    end
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_at = 'foo'
    end
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_at = 1
    end
  end
  
  def test_datetime_multiparameter
    @post = Post.new
    
    @post.attributes = {
      'published_at(1i)' => '2010',
      'published_at(2i)' => '4',
      'published_at(3i)' => '26',
      'published_at(4i)' => '4',
      'published_at(5i)' => '45',
      'published_at(6i)' => '30',
    }
    
    assert_equal 2010, @post.published_at.year
    assert_equal 4, @post.published_at.month
    assert_equal 26, @post.published_at.day
    assert_equal 4, @post.published_at.hour
    assert_equal 45, @post.published_at.min
    assert_equal 30, @post.published_at.sec
  end
  
  # FIXME this is a lazy way to avoid bad parameters, it should
  # be reported in the model errors.
  def test_datetime_multiparameter_invalid
    @post = Post.new
    
    @post.attributes = {
      # 'published_at(1i)' => '2010',
      'published_at(2i)' => '4',
      'published_at(3i)' => '26',
      'published_at(4i)' => '4',
      'published_at(5i)' => '45',
      'published_at(6i)' => '30',
    }
    
    assert_nil @post.published_at
  end
  
  def test_date
    @post = Post.new
    
    @today = Date.today
    
    @post.published_date = @today
    assert_equal @today, @post.published_date
    
    @post.published_date = '2012-08-29'
    assert_equal Date.parse('2012-08-29'), @post.published_date
    
    @post.published_date = nil
    assert_equal nil, @post.published_date
    
    @post.published_date = {
      'year' => 2010,
      'month' => 4,
      'day' => 26
    }
    assert_equal 2010, @post.published_date.year
    assert_equal 4, @post.published_date.month
    assert_equal 26, @post.published_date.day
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_date = {'year' => 2010}
    end
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_date = 'foo'
    end
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_date = 1
    end
    
  end
  
  def test_time
    @post = Post.new
    
    @time = Time.now
    
    @post.published_time = @time
    assert_equal @time, @post.published_time
    
    @post.published_time = nil
    assert_equal nil, @post.published_time
    
    @post.published_time = '1:05am'
    assert_equal 1, @post.published_time.hour
    assert_equal 5, @post.published_time.min
    
    @post.published_time = {
      'hour' => 5,
      'min' => 45,
      'sec' => 30
    }
    assert_equal 5, @post.published_time.hour
    assert_equal 45, @post.published_time.min
    assert_equal 30, @post.published_time.sec
    
    @post.published_time = {
      'hour' => 5,
      'min' => 45
    }
    assert_equal 5, @post.published_time.hour
    assert_equal 45, @post.published_time.min
    assert_equal 0, @post.published_time.sec
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_date = {'hour' => 2010}
    end
    
    assert_raise MemoryRecord::Attribute::InvalidValueError do
      @post.published_time = 5
    end
    
  end
  
  def test_unspecified
    @post = Post.new
    @post.unknown = 1
    assert_equal 1, @post.unknown
    
    @post.unknown = 'hi'
    assert_equal 'hi', @post.unknown
  end
  
end
