require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Associations do
  
  before do
    Object.class_eval do
      class Post
        include MemoryRecord::Associations
        
        belongs_to :author
        has_many   :comments
        
      end
      
      class Comment
        include MemoryRecord::Associations
        
        belongs_to :post
        
      end
      
      class Author
        include MemoryRecord::Associations
        
        has_one :post # should really be has_many, but go with me
      end
    end
    
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
    Object.send(:remove_const, :Comment) rescue nil
    Object.send(:remove_const, :Author) rescue nil
  end
  
  describe "belongs_to" do
    
    before do
      @comment = Comment.new
      @post = Post.new
    end
    
    it "should create a public accessor" do
      @comment.post = @post
      @comment.post.should == @post
    end
    
  end
  
  describe "has_one" do
    
    before do
      @author = Author.new
      @post = Post.new
    end
    
    it "should create a public accessor" do
      @author.post = @post
      @author.post.should == @post
    end
    
    it "should be nil by default" do
      @author.post.should == nil
    end
    
    it "should set the foreign key when writing" do
      @author.post = @post
      @post.author.should == @author
    end
    
  end
  
  describe "has_many" do
    
    before do
      @post = Post.new
    end
    
    it "should create a reader" do
      @post.comments.should == []
    end
    
    it "should expose an MemoryRecord::Collection" do
      @post.comments.is_a?(MemoryRecord::Collection::Instance).should == true
    end
    
  end
  
end
