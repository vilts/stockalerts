class Stocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.string :ticker, :limit => 4
    end
  end

  def self.down
    drop_table :stocks
  end
end
