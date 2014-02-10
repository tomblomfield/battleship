class JeffPlayer
  def name
    # Uniquely identify your player
    "Jeff"
  end

  def new_game
    # return an array of 5 arrays containing
    # [x,y, length, orientation]
    # e.g.
    [
      [0, 0, 5, :down],
      [4, 4, 4, :across],
      [9, 3, 3, :down],
      [2, 2, 3, :across],
      [9, 7, 2, :down]
    ]
  end

  def take_turn(state, ships_remaining)
    # state is the known state of opponents fleet
    # ships_remaining is an array of the remaining opponents ships


    @x ||= -1
    @y ||= 0

    until @y == 10
      until @x == 9
        @x += 1
        return [@x,@y] # your next shot co-ordinates
      end
      @x =-1
      @y += 1
    end
  end

  # you're free to create your own methods to figure out what to do next
end
