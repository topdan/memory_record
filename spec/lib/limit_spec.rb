require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Limit do
  
  before do
    Object.class_eval do
      class Post
        include MemoryRecord::Limit
        attr_accessor :title
        
        def initialize title
          @title = title
        end
      end
      
    end
    
    @foo = Post.new "foo"
    @bar = Post.new "bar"
    @baz = Post.new "baz"
    
    Post.all << @foo
    Post.all << @bar
    Post.all << @baz
    
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should limit the number of records returned" do
    Post.limit(1).should == [@foo]
  end
  
  it "should return an instance of the collection class" do
    Post.limit(1).class.should == Post::Collection
  end
  
end
