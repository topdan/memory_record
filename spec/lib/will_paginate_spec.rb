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
  
  it "should allow paginating" do
    @post = Post.new
    
    @all = Post.all
    @all << @post
    
    @page = @all.page(1).per_page(20)
    @page.should == [@post]
    @page.current_page.should == 1
    @page.per_page.should == 20
    @page.total_pages.should == 1
    
    @all.page(2).per_page(10).should == []
  end
  
end
