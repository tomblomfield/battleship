require "board"

# Places ships randomly
class RandomPlacer
  attr_accessor :board
  def initialize(board)
    @board = board
  end

  # Places all ships, returns an ary of placements
  def place_all_ships
    fleet = Board::INITIAL_FLEET
    placements = []
    until fleet.empty?
      placement = self.class.random_placement(fleet.first)
      if board_with_placement = board.place(placement)
        board = board_with_placement
        placements << placement
        fleet.shift
      end
    end
    placements
  end

  def self.random_placement(length)
    Placement.new(random_coord, random_coord, length, random_direction)
  end

  def self.random_coord
    (0...Board::SIZE).to_a.sample
  end

  def self.random_direction
    Board::ORIENTATIONS.sample
  end
end