require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Finders do
  
  before do
    Object.class_eval do
      class Post < MemoryRecord::Base
        field :title, :type => String
      end
      
    end
    
    @foo = Post.new :title => 'foo'
    @bar = Post.new :title => 'bar'
    @baz = Post.new :title => 'baz'
    
    Post.all << @foo
    Post.all << @bar
    Post.all << @baz
    
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should know how to find" do
    Post.find(@foo.id).should == @foo
    
    lambda { Post.find(30) }.should raise_error(MemoryRecord::RecordNotFound)
  end
  
  it "should know first" do
    Post.first.should == @foo
  end
  
  it "should know first!" do
    Post.first!.should == @foo
    Post.delete_all
    lambda { Post.first! }.should raise_error(MemoryRecord::RecordNotFound)
  end
  
  it "should know last" do
    Post.last.should == @baz
  end
  
  it "should know last!" do
    Post.last!.should == @baz
    Post.delete_all
    lambda { Post.last! }.should raise_error(MemoryRecord::RecordNotFound)
  end
  
end
