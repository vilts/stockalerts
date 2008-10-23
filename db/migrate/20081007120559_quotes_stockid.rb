class QuotesStockid < ActiveRecord::Migration
  def self.up
    add_column :quotes, :stock_id, :integer
  end

  def self.down
    remove_column :quotes, :stock_id
  end
end
