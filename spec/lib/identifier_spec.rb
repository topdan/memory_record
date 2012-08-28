require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Identifier do
  
  before do
    Object.class_eval do
      class Post
        include MemoryRecord::Identifier
      end
      
    end
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should know when it's a new_record" do
    @post = Post.new
    @post.new_record?.should == true
    @post.persisted?.should == false
    
    @post.id = 1
    @post.new_record?.should == false
    @post.persisted?.should == true
  end
  
  it "should know to_key" do
    @post = Post.new
    @post.to_key.should == nil
    
    @post.id = 1
    
    @post.to_key.should == [1]
  end
  
  it "should know to_param" do
    @post = Post.new
    @post.to_param.should == nil
    
    @post.id = 1
    
    @post.to_param.should == 1
  end
  
end
