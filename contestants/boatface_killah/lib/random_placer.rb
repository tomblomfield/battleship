require "board"

# Places ships randomly
class RandomPlacer
  attr_accessor :board, :placements
  def initialize(board)
    @board = board
    @placements = []
  end

  # Places all ships, stores them in @placements
  def place_all_ships
    Board::INITIAL_FLEET.inject(@board) do |board, length|
      place_ship(board, length, true)
    end
  end

  # Randomly places a ship, keeps trying random spots until it succeeds
  #
  # Returns a new board
  # Adds the placement to @placements if store_placements is true
  def place_ship(board, length, store_placements = false)
    placement = random_placement(length)

    if board_with_placement = board.place(placement)
      @placements << placement if store_placements
      board_with_placement
    else
      place_ship(board, length, store_placements) # try again
    end
  end

  private
  def random_placement(length)
    Placement.new(random_coord, random_coord, length, random_direction)
  end

  def random_direction
    Board::ORIENTATIONS.sample
  end

  def random_coord
    (0...Board::SIZE).to_a.sample
  end
end