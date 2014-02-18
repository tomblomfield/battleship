require "./lib/board"

# Places ships randomly
class RandomPlacer
  attr_accessor :board
  def initialize(board)
    @board = board
  end

  # Places all ships, stores them in @placements
  def place_all_ships
    fleet = Board::INITIAL_FLEET
    placements = []
    until fleet.empty?
      placement = random_placement(fleet.first)
      if board_with_placement = board.place(placement)
        placements << placement
        fleet.shift
      end
    end
    placements
  end

  def random_placement(length)
    Placement.new(random_coord, random_coord, length, random_direction)
  end

  private
  def random_direction
    Board::ORIENTATIONS.sample
  end

  def random_coord
    (0...Board::SIZE).to_a.sample
  end
end