require 'helper'

class SeedTest < Test::Unit::TestCase
  
  include ClassHelper
  
  define_classes %(
    
    class Post < MemoryRecord::Base
      field :id,      :type => String
      field :title,   :type => String
      field :author,  :type => String
    end
    
  )
  
  def setup
    define_classes
    @seed_directory = File.join('test', 'seeds')
    MemoryRecord.seed_path = @seed_directory
  end
  
  def teardown
    undefine_classes
    FileUtils.rm_rf(@seed_directory)
    MemoryRecord.seed_path = nil
  end
  
  def write_seed_file(filename, array)
    @seed_file = File.join(@seed_directory, filename)
    
    FileUtils.mkdir_p(@seed_directory)
    File.open(@seed_file, 'w') do |f|
      f.write(array.to_json)
    end
  end
  
  def test_data_is_seeded_from_directory
    write_seed_file('posts.json', [{
      id: 'my-post',
      title: 'My Post',
      author: 'Dan'
    }, {
      id: 'another-post',
      title: 'Another Post',
      author: 'Sam'
    }])
    
    assert_equal 2, Post.count
    
    @post1 = Post.where(author: 'Dan').first
    @post2 = Post.where(author: 'Sam').first
    
    assert_equal 'My Post', @post1.title
    assert_equal 'Another Post', @post2.title
  end
  
  def test_outputing_seeds_back_into_directory
    write_seed_file('posts.json', [])
    
    @post = Post.create!(title: 'Some Post', author: 'Jill')
    
    Post.update_seeds!
    
    @content = File.open(@seed_file) {|f| f.read }
    assert @content.include?('Some Post')
    assert @content.include?('Jill')
  end
  
end
