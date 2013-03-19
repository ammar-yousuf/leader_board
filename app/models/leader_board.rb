require "logger"

class LeaderBoard < ActiveRecord::Base
  attr_accessible :date, :description, :game
  has_and_belongs_to_many :fans
  has_many :scores
  default_scope order('game ASC')
 
  def top_10_scores
    log = Logger.new(STDOUT)

    #  Get the top 10 elements from the sorted set, from highest to lowest
    top_10_score_ids = $redis.zrevrange(self.redis_key('scores'), 0, 10)
    
    log.info("*"*100)
    log.info("Top 10 Scores from Redis: #{top_10_score_ids.inspect}")

    sorted_scores = Score.find(top_10_score_ids).sort_by {|score| top_10_score_ids.index(score.id.to_s)}

    ap sorted_scores
    sorted_scores
  end

  # helper method to generate redis keys
  def redis_key(str)
    "leader_board:#{self.id}:#{str}"
  end
end