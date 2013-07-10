require 'helper'

class TableTest < Test::Unit::TestCase

  test 'ordering rows' do
    @id = MemoryRecord::Attribute::StringType.new(:id)
    @table = MemoryRecord::Table.new(:posts, [@id], primary_key: 'id')

    @table.insert('id' => 'foo')
    @table.insert('id' => 'bar')

    assert_equal [{'id' => 'bar'}, {'id' => 'foo'}], @table.rows.to_a
  end

  test 'ordering attributes' do
    @id = MemoryRecord::Attribute::StringType.new(:id)
    @name = MemoryRecord::Attribute::StringType.new(:name)
    @table = MemoryRecord::Table.new(:posts, [@id, @name])

    @table.insert('name' => 'John', 'id' => 'foo')
    @table.insert('name' => 'Jane', 'id' => 'bar')

    assert_equal [%w(id name), %w(id name)], @table.rows.collect {|row| row.keys }
  end

end
