class Quotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.date :date
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.integer :volume
      t.float :adj_close
    end
  end

  def self.down
    drop_table :quotes
  end
end
