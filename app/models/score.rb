class Score < ActiveRecord::Base
  belongs_to :leader_board
  attr_accessible :leader_board_id, :player, :points
  
  # After each score is created we automatically add it to the leaderboard.
  after_create :add_to_leaderboard

  def add_to_leaderboard
    # Add the score to a sorted set with a unique redis_key
    $redis.zadd self.leader_board.redis_key(:scores), self.points, self.id

    # Publish the new score to the leader_boards channel
    # This will then push the message to the websocket that will update the scores 
    # list on the page.
    $redis.publish 'leader_boards:channel', "{\"leader_board_id\" : #{self.leader_board.id}}"
  end
  
  # helper method to generate redis keys
  def redis_key(str)
    "score:#{self.id}:#{str}"
  end
end
