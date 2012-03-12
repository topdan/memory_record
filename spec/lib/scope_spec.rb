require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InactiveRecord::Scope do
  
  before do
    Object.class_eval do
      class Post
        include InactiveRecord::Scope
        include InactiveRecord::Where
        attr_accessor :title
        
        scope :with_title, lambda {|title| where(:title => title) }
        
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
  
  it "should support lambda scopes" do
    Post.with_title("bar").should == [@bar]
  end
  
  it "should not support static yet scopes" do
    lambda { Post.scope :foo, where(:title => "foo") }.should raise_error
  end
  
  it "should error when an unknown type is given" do
    lambda { Post.scope :bar, 4 }.should raise_error
  end
  
end
