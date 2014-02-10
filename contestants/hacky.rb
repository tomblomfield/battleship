class HackyPlayer

  def name
    # Uniquely identify your player
    "Jeff"
  end

  def new_game
    # return an array of 5 arrays containing
    # [x,y, length, orientation]
    # e.g.

    @hunt = true

    [
      [0, 0, 5, :down],
      [4, 4, 4, :across],
      [9, 3, 3, :down],
      [2, 2, 3, :across],
      [9, 7, 2, :down]
    ]
  end


  def take_turn(state, ships_remaining)
    @state = state
    # state is the known state of opponents fleet

    # ships_remaining is an array of the remaining opponents ships

    @hunt = false if check_state(@guess[0], @guess[1]) == :hit

    if @hunt
      @guess = hunt_guess
    else
      @guess = seek_guess
    end
    @guess
  end


  private

  def hunt_guess
    begin
      x = rand(10)

      if x.even?
        y = rand(5) * 2
      else
        y = (rand(5) * 2) + 1
      end
      guess = [x, y]
    end while check_state(guess[0], guess[1]) != :unknown

    guess
  end

  def seek_guess
  end

  def check_state(x, y)
    return :outside unless (0..9).cover? x
    return :outside unless (0..9).cover? y
    @state[y][x]
  end

end

