require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InactiveRecord::Limit do
  
  before do
    Object.class_eval do
      class Post
        include InactiveRecord::Crud
        
        attr_accessor :title
        
        validates_presence_of :title
        
        before_create :my_before_create
        after_create  :my_after_create
        
        before_update :my_before_update
        after_update  :my_after_update
        
        before_save :my_before_save
        after_save  :my_after_save
        
        before_destroy :my_before_destroy
        after_destroy  :my_after_destroy
        
        def initialize title
          @title = title
        end
        
        protected
        
        def my_before_create  ; end
        def my_after_create   ; end
        def my_before_update  ; end
        def my_after_update   ; end
        def my_before_save    ; end
        def my_after_save     ; end
        def my_before_destroy ; end
        def my_after_destroy  ; end
        
      end
      
    end
    
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
  end
  
  describe "InstanceMethods" do
    
    it "should #delete" do
      @post = Post.create! "foo"
      @post.should_not_receive :my_before_destroy
      @post.should_not_receive :my_after_destroy
      Post.count.should == 1
      
      @post.delete
      Post.count.should == 0
    end
    
    it "should #destroy" do
      @post = Post.create! "foo"
      @post.should_receive :my_before_destroy
      @post.should_receive :my_after_destroy
      Post.count.should == 1
      
      @post.destroy
      Post.count.should == 0
    end
    
    it "should fail gracefully during save" do
      @post = Post.new nil
      
      @post.save.should == false
      @post.errors[:title].should == ["can't be blank"]
      Post.count.should == 0
    end
    
    it "should save successfully" do
      @post = Post.new "foo"
      @post.should_receive(:my_before_create)
      @post.should_receive(:my_after_create)
      @post.should_receive(:my_before_save)
      @post.should_receive(:my_after_save)
      @post.should_not_receive(:my_before_update)
      @post.should_not_receive(:my_after_update)
      
      @post.save.should == true
      Post.count.should == 1
    end
    
    it "should raise an error when save! fails" do
      @post = Post.new nil
      
      lambda { @post.save! }.should raise_error(InactiveRecord::RecordInvalid)
    end
    
    it "should save! successfully" do
      @post = Post.new "foo"
      
      @post.save!
      Post.count.should == 1
    end
    
    it "should update_attribute" do
      @post = Post.create! "foo"
      
      @post.update_attribute(:title, "bar").should == true
      @post.title.should == "bar"
      
      @post.update_attribute(:title, nil).should == false
      @post.title.should == nil
    end
    
    it "should fail gracefully during update_attributes" do
      @post = Post.create! "foo"
      
      @post.should_not_receive(:my_before_create)
      @post.should_not_receive(:my_after_create)
      @post.should_receive(:my_before_save)
      @post.should_not_receive(:my_after_save)
      @post.should_receive(:my_before_update)
      @post.should_not_receive(:my_after_update)
      
      @post.update_attributes(:title => nil).should == false
      @post.title.should == nil
      @post.errors[:title].should == ["can't be blank"]
    end
    
    it "should update_attributes successfully" do
      @post = Post.create! "foo"
      
      @post.should_not_receive(:my_before_create)
      @post.should_not_receive(:my_after_create)
      @post.should_receive(:my_before_save)
      @post.should_receive(:my_after_save)
      @post.should_receive(:my_before_update)
      @post.should_receive(:my_after_update)
      
      @post.update_attributes(:title => "bar").should == true
      @post.title.should == "bar"
    end
    
    it "should raise an error when update_attributes! fails" do
      @post = Post.create! "foo"
      
      lambda { @post.update_attributes! :title => nil }.should raise_error(InactiveRecord::RecordInvalid)
    end
    
    it "should update_attributes! successfully" do
      @post = Post.create! "foo"
      
      @post.update_attributes! :title => "bar"
      @post.title.should == "bar"
    end
    
  end
  
  describe "ClassMethods" do
    
    it "should fail gracefully during create" do
      @post = Post.create(nil)
      @post.title.should == nil
      @post.errors[:title].should == ["can't be blank"]
      Post.all.should == []
    end
    
    it "should create successfully" do
      @post = Post.create "foo"
      @post.title.should == "foo"
      Post.all.should == [@post]
    end
    
    it "should raise an error during create!" do
      lambda { Post.create! nil }.should raise_error(InactiveRecord::RecordInvalid)
      Post.all.should == []
    end
    
    it "should create! successfully" do
      @post = Post.create! "foo"
      @post.title.should == "foo"
      Post.all.should == [@post]
    end
    
    it "should delete_all while invoking callbacks" do
      @post = Post.create! "foo"
      @post.should_not_receive :my_before_destroy
      @post.should_not_receive :my_after_destroy
      
      Post.delete_all
      Post.all.should == []
    end
    
    it "should destroy_all while invoking callbacks" do
      @post = Post.create! "foo"
      @post.should_receive :my_before_destroy
      @post.should_receive :my_after_destroy
      
      Post.destroy_all
      Post.all.should == []
    end
    
  end
  
end
