require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Collection do
  
  before do
    Object.class_eval do
      class Post
        include MemoryRecord::Collection
        
        def initialize attributes = {}
          
        end
        
      end
      
    end
    
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should expose #all" do
    Post.all.should == []
  end
  
  it "should generate a collection class" do
    Post.all.class.should == Post::Collection
    Post::Collection.superclass.should == MemoryRecord::Collection::Instance
  end
  
  it "should build from all" do
    Post.all.build.should_not be_nil
  end
  
  it "should allow adding records to the collection" do
    @post = Post.new
    
    @all = Post.all
    @all << @post
    @all.should == [@post]
  end
  
end
