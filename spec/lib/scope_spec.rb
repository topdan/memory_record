require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InactiveRecord::Scope do
  
  before do
    Object.class_eval do
      class Post
        include InactiveRecord::Scope
        include InactiveRecord::Where
        attr_accessor :title, :author
        
        scope :with_title, lambda {|title| where(:title => title) }
        scope :with_author, lambda {|author| where(:author => author) }
        
        def initialize title, author
          @title = title
          @author = author
        end
        
      end
      
    end
    
    @foo = Post.new "foo", "Dan"
    @bar = Post.new "bar", "Dan"
    @baz = Post.new "baz", "Jim"
    
    Post.all << @foo
    Post.all << @bar
    Post.all << @baz
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should support lambda scopes" do
    Post.with_title("bar").should == [@bar]
  end
  
  it "should support scope chaining" do
    Post.with_title("bar").with_author("Dan").should == [@bar]
    Post.with_title("nuts").with_author("Dan").should == []
  end
  
  it "should not support static yet scopes" do
    lambda { Post.scope :foo, where(:title => "foo") }.should raise_error
  end
  
  it "should error when an unknown type is given" do
    lambda { Post.scope :bar, 4 }.should raise_error
  end
  
end
