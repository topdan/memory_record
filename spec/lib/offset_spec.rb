require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Offset do
  
  before do
    Object.class_eval do
      class Post
        include MemoryRecord::Offset
      end
      
    end
    
    @foo = Post.new
    @bar = Post.new
    @baz = Post.new
    
    Post.all << @foo
    Post.all << @bar
    Post.all << @baz
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should offset start of the records returned" do
    Post.offset(1).should == [@bar, @baz]
  end
  
  it "should return an instance of the collection class" do
    Post.offset(1).class.should == Post::Collection
  end
  
end
