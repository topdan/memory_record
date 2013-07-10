require 'helper'

class TableTest < Test::Unit::TestCase

  test 'ordering rows' do
    @id = MemoryRecord::Attribute::StringType.new(:id)
    @table = MemoryRecord::Table.new(:posts, [@id], primary_key: 'id')

    @table.insert('id' => 'foo')
    @table.insert('id' => 'bar')

    assert_equal [{'id' => 'bar'}, {'id' => 'foo'}], @table.rows.to_a
  end

end
