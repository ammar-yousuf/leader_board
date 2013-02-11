class LeaderBoard < ActiveRecord::Base
  attr_accessible :date, :description, :game
  has_and_belongs_to_many :fans
end
