class Quote < ActiveRecord::Base
  belongs_to :stock
  validates_presence_of :close
  validates_numericality_of :open, :high, :low, :close, :volume, :adj_close, :message => "Not a number!"
end
