# Immutable board that keeps track of the probability that a ship is in each 
# position
class Board
  SIZE = 10
  INITIAL_FLEET = [5, 4, 3, 3, 2]
  ORIENTATIONS = [:down, :across]

  def initialize(board = empty_board)
    @board = board
  end

  # State with all unknowns
  def empty_board
    (0...SIZE).map { (0...SIZE).map { :unknown } }
  end

  # Boats can intersect with positions that are [:unknown, :hit]
  # 
  # Returns a new board with an updated placement
  # Returns nil if the ship could not be placed 
  def place(placement)
    return unless can_place?(placement)

    new_board = @board.dup
    placement.expand_placement.each do |x, y|
      new_board[y][x] = :ship
    end
    Board.new(new_board)
  end

  def can_place?(placement)
    placement.expand_placement.all? do |xy|
      [:unknown, :hit].include?(board_hash[xy])
    end
  end

  private

  # Optimization - Hash that maps [x, y] positions to states
  def board_hash
    @board_hash ||= create_board_hash
  end

  def create_board_hash
    board_hash = {}
    @board.each_with_index do |row, y|
      row.each_with_index do |state, x|
        board_hash[[x,y]] = state
      end
    end
    board_hash
  end
end

# A placement is a location for a ship
class Placement
  attr_accessor :x, :y, :length, :direction

  def initialize(x, y, length, direction)
    @x, @y, @length, @direction = x, y, length, direction
  end

  # Returns an ary of x,y tuples
  def expand_placement
    raise ArgumentError unless [:across, :down].include?(direction)
    dx, dy = direction == :across ? [1, 0] : [0, 1]
    (0...length).map{ |i| [x + i * dx, y + i * dy] }
  end

  def to_a
    [x, y, length, direction]
  end
end