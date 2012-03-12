require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InactiveRecord::Order do
  
  before do
    Object.class_eval do
      class Post
        include InactiveRecord::Order
        attr_accessor :title, :author
        
        def initialize title, author
          @title = title
          @author = author
        end
      end
      
    end
    
    @foo = Post.new "foo", "Dan"
    @bar = Post.new "bar", "Dan"
    @baz = Post.new "baz", "Sue"
    
    Post.all << @foo
    Post.all << @bar
    Post.all << @baz
    
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should order asc by default" do
    Post.order(:title).should == [@bar, @baz, @foo]
  end
  
  it "should order by desc" do
    Post.order([:title, :desc]).should == [@foo, @baz, @bar]
  end
  
  it "should order by asc" do
    Post.order([:title, :asc]).should == [@bar, @baz, @foo]
  end
  
  it "should return a collection instance" do
    Post.order(:title).class.should == Post::Collection
  end
  
  it "should not support multiple order statements yet" do
    # Post.order(:author, :title).should == [@bar, @foo, @baz]
    lambda { Post.order(:author, :title) }.should raise_error
  end
  
  it "should not mind nil values" do
    @blank1 = Post.new(nil, nil)
    @blank2 = Post.new(nil, nil)
    Post.all << @blank1
    Post.all << @blank2
    Post.order(:title).should == [@blank2, @blank1, @bar, @baz, @foo]
  end
  
end
