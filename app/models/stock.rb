class Stock < ActiveRecord::Base
  has_many :quotes, :dependent => :destroy
  validates_presence_of :ticker
end
