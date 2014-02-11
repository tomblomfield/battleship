class HackyPlayer

  def name
    # Uniquely identify your player
    "Hacky"
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

    if @guess && check_state(@guess[0], @guess[1]) == :hit
      @hunt = false
      @current_hit = @guess
    end

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
    adjacents = adjacent_states(@current_hit)

    adjacents.select! do |cell|
      check_state(cell[0],cell[1]) == :unknown
    end

    if !adjacents.empty?
      adjacents.sample
    else
      @hunt = true
      hunt_guess
    end

  end


  def adjacent_states(coordinates)

    x = coordinates[0]
    y = coordinates[1]

    adjacents = []

    adjacents << [x + 1, y]
    adjacents << [x - 1, y]
    adjacents << [x, y + 1]
    adjacents << [x, y - 1]

    adjacents.reject! do |cell|
      check_state(cell[0],cell[1]) == :outside
    end
    adjacents
  end


  def check_state(x, y)
    return :outside unless (0..9).cover? x
    return :outside unless (0..9).cover? y
    @state[y][x]
  end

end
