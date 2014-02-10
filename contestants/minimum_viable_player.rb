class JeffPlayer

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
    # state is the known state of opponents fleet
    # ships_remaining is an array of the remaining opponents ships


    # if @hunt

    #   @guess = [rand(5) * 2, rand(5) * 2]

    #   while  state[@guess[0]][@guess[1]] != :unknown
    #     @guess = [rand(5) * 2, rand(5) * 2]
    #   end

    # else

    # end


    hunt_guess

  end

  # you're free to create your own methods to figure out what to do next

  def hunt_guess
    x = rand(10)

    if x.even?
      y = rand(5) * 2
    else
      y = (rand(5) * 2) + 1
    end

    [x, y]
  end

end

