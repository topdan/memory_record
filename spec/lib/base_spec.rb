require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemoryRecord::Base do
  
  before do
    Object.class_eval do
      class Post < MemoryRecord::Base
        field :title, :type => String
        field :published_at, :type => DateTime
        field :body, :type => String
        
        has_many :comments
        belongs_to :author
        
        validates_presence_of :title, :body, :author
        
      end
      
      class Comment < MemoryRecord::Base
        field :body, :type => String
        
        belongs_to :post
        
        validates_presence_of :post, :body
        
      end
      
      class Author < MemoryRecord::Base
        field :name, :type => String
        
        has_many :posts
        
        validates_presence_of :name
      end
    end
  end
  
  after do
    Object.send(:remove_const, :Post) rescue nil
    Object.send(:remove_const, :Comment) rescue nil
    Object.send(:remove_const, :Author) rescue nil
  end
  
  it "should create/update/destroy records like active record" do
    @dan      = Author.create! :name => "Dan"
    @readme   = Post.create! :author => @dan, :title => "README", :body => "some details"
    @faq      = @dan.posts.create! :author => @dan, :title => "FAQ", :body => "questions"
    @thanks   = @readme.comments.create! :body => "Thanks, this was helpful!"
    @question = (@readme.comments << Comment.new(:body => "What does this do?")).last
    
    # failing
    Author.create
    @readme.comments.create
    
    Author.all.should == [@dan]
    Post.all.map(&:title).should == [@readme.title, @faq.title]
    Comment.all.map(&:body).should == [@thanks.body, @question.body]
    
    @readme.comments.count.should == 2
    @readme.comments.map(&:body).should == [@thanks.body, @question.body]
    
    @dan.attributes.should == {:name => "Dan"}
    @dan.update_attributes! :name => "Jim"
    @dan.name.should == "Jim"
    
    @readme.comments.class.should == Comment::Collection
    @dan.posts.class.should == Post::Collection
  end
  
  it "should allow chaining scopes" do
    Author.where(:title => "Hello").order(:title).limit(1).first.should == nil
  end
  
end
