# This represents our board
class Tile

  attr_reader :x, :y, :state

  def initialize(x, y, state)
    @x = x
    @y = y
    @state = state
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

  def directions
    [:up, :down, :left, :right]
  end
end
