class Fan < ActiveRecord::Base
  attr_accessible :hometown, :name
  has_and_belongs_to_many :leader_boards
  
  # follow a leader_board
  def follow!(leader_board)
    self.leader_boards << leader_board unless self.leader_boards.include? leader_board

    # In a multi-exec transaction block, add the leader_board id
    # to the fan's set and also update the set for the leader_board.
    $redis.multi do
      $redis.sadd self.redis_key(:following), leader_board.id
      $redis.sadd leader_board.redis_key(:followers), self.id
    end
  end

  # unfollow a leader_board
  def unfollow!(leader_board)
    self.leader_boards.delete leader_board

    # In a multi-exec transaction block, remove the leader_board id
    # from the fan's set and also update the set for the leader_board.
    # These commands are queued and then run at once, while all other
    # Redis client requests are not served.
    $redis.multi do
      $redis.srem self.redis_key(:following), leader_board.id
      $redis.srem leader_board.redis_key(:followers), self.id
    end
  end

  # Leader boards that this fan is following.
  def following
    # Get all the members of the set with the Redis key
    leader_board_ids = $redis.smembers(self.redis_key(:following))
    LeaderBoard.where(:id => leader_board_ids)
  end
  
  def follows?(leader_board)
    # Get all the leader_boards the user is following and then check to see
    # if the leader_board passed in is in the set
    $redis.smembers(self.redis_key(:following)).include? leader_board.id.to_s
  end
  
  # helper method to generate redis keys
  def redis_key(str)
    "fan:#{self.id}:#{str}"
  end
  
end
