require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Where do
  
  before do
    Object.class_eval do
      class Post
        include MemoryRecord::Where
        attr_accessor :title, :author
        
        def initialize title, author
          @title, @author = title, author
        end
        
      end
      
    end
    
    @foo = Post.new("Foo", "Jim")
    @bar = Post.new("Bar", "Dan")
    @baz = Post.new("Baz", "Dan")
    
    Post.all << @foo
    Post.all << @bar
    Post.all << @baz
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  it "should add #where to the class" do
    Post.where(:title => "Foo").should == [@foo]
    Post.where(:author => "Dan").should == [@bar, @baz]
    Post.where(:title => "Bar", :author => "Dan").should == [@bar]
    
    Post.where(:title => "aaa").should == []
    Post.where(:title => nil).should == []
    Post.where(:title => nil).class.should == Post::Collection
    Post.where(:title => nil, :author => nil).class.should == Post::Collection
  end
  
end
