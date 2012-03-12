require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InactiveRecord::Field do
  
  before do
    Object.class_eval do
      class Post
        include InactiveRecord::Field
        
        field :title,          :type => String
        field :comments_count, :type => Integer
        field :ratio,          :type => Float
        field :published_at,   :type => DateTime
        field :published_date, :type => Date
        field :published_time, :type => Time
        
      end
      
    end
    
    @post = Post.new
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  describe "String" do
    
    it "should create string accessors" do
      @post.title = "Foo"
      @post.title.should == "Foo"
    end
    
  end
  
  describe "Integer" do
    
    it "should create integer accessors" do
      @post.comments_count = 0
      @post.comments_count.should == 0
    end
    
  end
  
  describe "Float" do
    
    it "should create float accessors" do
      @post.ratio = 0.5
      @post.ratio.should == 0.5
    end
    
  end
  
  describe "DateTime" do
    
    it "should create datetime accessors" do
      datetime = DateTime.now
      
      @post.published_at = datetime
      @post.published_at.should == datetime
    end
    
    it "should parse a string" do
      datetime = DateTime.parse("2011-03-11 3:00 am")
      @post.published_at = "2011-03-11 3:00 am"
      @post.published_at.should == datetime
    end
    
    it "should raise an error when given a bad string" do
      lambda { @post.published_at = "foo" }.should raise_error(InactiveRecord::Field::InvalidValueError)
    end
    
    it "should raise an error when given an unknown class type" do
      lambda { @post.published_at = 5 }.should raise_error(InactiveRecord::Field::InvalidValueError)
    end
    
  end
  
  describe "Date" do
    
    it "should create date accessors" do
      date = Date.parse("2012-03-11")
      
      @post.published_date = date
      @post.published_date.should == date
    end
    
    it "should parse a string" do
      date = Date.parse("2012-03-11")
      @post.published_date = "2012-03-11"
      @post.published_date.should == date
    end
    
    it "should raise an error when given a bad string" do
      lambda { @post.published_date = "foo" }.should raise_error(InactiveRecord::Field::InvalidValueError)
    end
    
    it "should raise an error when given an unknown class type" do
      lambda { @post.published_date = 5 }.should raise_error(InactiveRecord::Field::InvalidValueError)
    end
    
  end
  
  describe "Time" do
    
    it "should create time accessors" do
      time = Time.parse("3:00 am")
      @post.published_time = time
      @post.published_time.should == time
    end
    
    it "should parse a string" do
      time = Time.parse("3:00 am")
      @post.published_time = "3:00 am"
      @post.published_time.should == time
    end
    
    # ActiveModel messes this up
    # it "should raise an error when given a bad string" do
    #   lambda { @post.published_time = "foo" }.should raise_error(InactiveRecord::Field::InvalidValueError)
    # end
    
    it "should raise an error when given an unknown class type" do
      lambda { @post.published_time = 5 }.should raise_error(InactiveRecord::Field::InvalidValueError)
    end
    
  end
  
  it "should error when given an unknown type" do
    lambda { Post.field :foo, :type => Post }.should raise_error
  end
  
end
