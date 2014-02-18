class HackyPlayer

  def name
    # Uniquely identify your player
    "Hacky the Old and Grizzled Hackbot"
  end

  def new_game
    # return an array of 5 arrays containing
    # [x,y, length, orientation]
    # e.g.

    @hunt = true

    [
      [
        [4, 0, 5, :across],
        [0, 6, 4, :down],
        [2, 7, 3, :across],
        [5, 2, 3, :across],
        [9, 7, 2, :down]
      ],
      [
        [9, 4, 5, :down],
        [0, 6, 4, :down],
        [2, 7, 3, :across],
        [0, 1, 3, :across],
        [7, 9, 2, :across]
      ]
    ].sample
  end


  def take_turn(state, ships_remaining)
    @state = state
    @ships_remaining = ships_remaining

    map = weight_probability
    # puts map

    highest_hit_coords = nil
    highest_hit_prob = 0.0
    map.each do |coords, prob|
      if highest_hit_prob < prob
        highest_hit_prob = prob
        highest_hit_coords = coords
      end
    end

    @guess = highest_hit_coords
    highest_hit_coords
  end


  private

  def check_for_loners
  end

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

  def each_square
    10.times do |x|
      10.times do |y|
        yield x, y
      end
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


  def check_state(x, y = nil)

    if x.is_a?(Array)
      y = x[1]
      x = x[0]
    end

    return :outside unless (0..9).cover? x
    return :outside unless (0..9).cover? y
    @state[y][x]
  end

  def weight_probability()
    weight_prob_map = {}

    each_square do |x, y|
      @ships_remaining.each do |ship_length|
        [:across, :down].each do |ship_direction|
          poss = true
          hits = 0
          ship_squares([x,y], ship_length, ship_direction).each do |square|
            poss = false if [:miss, :outside].include?(check_state(square))
            hits += 2 if check_state(square) == :hit
            hits += 10 if check_loner(square)
          end
          if poss == true
            ship_squares([x,y], ship_length, ship_direction).each do |square|
              weight_prob_map[square] ||= 0
              weight_prob_map[square] += 1 + hits
            end
          end
        end
      end
    end

    weight_prob_map.reject! do |cell|
      check_state(cell[0],cell[1]) == :hit
    end

    # puts weight_prob_map
    return weight_prob_map
  end

  def check_loner(coord)
    return false if check_state(coord) != :hit
    adjacent_states(coord).each do |adj|
      return false if check_state(adj) == :hit
    end
    true
  end

  def ship_squares(coord, ship_length, ship_direction)
    ship_squares = []

    ship_length.times do |offset|
      if ship_direction == :across
        ship_squares << [(coord[0] + offset), coord[1]]
      elsif ship_direction == :down
        ship_squares << [coord[0], (coord[1] + offset)]
      end
    end

    return ship_squares
  end

end
