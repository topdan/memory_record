# InactiveRecord

ActiveModel (used by ActiveRecord) API without database persistence. Useful when you have all the data hardcoded into your project but want to access it using the ActiveModel API.

[![Build Status](https://secure.travis-ci.org/topdan/inactiverecord.png)](https://secure.travis-ci.org/topdan/inactiverecord.png)

# When NOT to use this

Do not use this library when the data is not hardcoded into your project. Use SQLite instead: it's a low-impact persistent database library to use with ActiveRecord.

# Documentation

Here's some sample blog model definitions:

    class Post < InactiveRecord::Base
      field :title, :type => String
      field :published_at, :type => DateTime
      field :body, :type => String
      
      has_many :comments
      belongs_to :author
      
      validates_presence_of :title
    end
    
    class Comment < InactiveRecord::Base
      field :body, :type => String
      
      belongs_to :post
      
      validates_presence_of :post, :body
    end
    
## Fields

Fields used the Mongoid API. The possible types are: String, Integer, Float, DateTime, Date, Time.

    @post = Post.create!(:title => "Hello World!", :published_at => "2012-03-11 21:00:00 -0400")
    @post.attributes
      => {:title => "Hello World!", :published_at => #<DateTime:...>, :body => nil}

## Reading
    
    Post.all
    Post.first
    Post.last
    Post.where(:title => "Hello World!").order([:title, :asc]).offset(1).limit(3).first
    
## Create, Update, Delete

    @post = Post.create!
      => InactiveRecord::RecordInvalidError
    
    @post = Post.create!(:title => "Hello World!")
    @post.update_attributes!(:title => "Goodbye World")
    @post.destroy
    
    @post = Post.create
    @post.errors[:title]
      => ["can't be blank"]

## Associations
    
    @post = Post.create!(:title => "Hello World!")
    @thanks = @post.comments.create!(:body => "This is easy!")
    
    @thanks.post
      => @post
    
    @post.comments.count
      => 1
    Comment.count
      => 1
    
    @post.comments.destroy_all
    Comment.count
      => 0

## Validations and Callbacks

  All validations and callbacks work just like ActiveRecord, thanks to ActiveModel.