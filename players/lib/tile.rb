# This represents our board
class Tile

  attr_reader :x, :y, :state, :board, :score

  def initialize(x, y, state, board)
    @x = x
    @y = y
    @state = state
    @board = board
    @score = nil
  end

  def update(state)
    @state = state
  end

  def position
    [x, y]
  end

  def neighbour_position(direction)
    case direction
    when :left
      [x - 1, y]
    when :right
      [x + 1, y]
    when :up
      [x, y - 1]
    when :down
      [x, y + 1]
    end
  end

  # Returns the (potentially nonexistent) positions of the neighbouring tiles
  def neighbour_positions
    directions.map { |d| neighbour_position(d) }
  end

  def neighbour(direction)
    @board.get_tile(*neighbour_position(direction))
  end

  def neighbours
    directions.map { |d| neighbour(d) }.compact
  end

  def directions
    [:up, :down, :left, :right]
  end

  def calculate_score
    # @score = directions.reduce do |dir, score|
    #   score + consecutive_hit_tiles(dir)
    # end
    @score = directions.map { |dir| consecutive_hit_tiles(dir) }.reduce(&:+)
    # @score = directions.sum
  end

  def consecutive_hit_tiles(direction)
    n = self
    count = 0
    while (n = n.neighbour(direction)) && n.state == :hit
      count += 1
    end
    count
  end
end
