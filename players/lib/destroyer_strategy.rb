require "board.rb"
require "ships.rb"

# DestroyerStrategy
#
# A class responsible for the strategy of destroying the ships
#
# The Destroyer Strategy chooses random points in unkown territory
# on the board.
# Once it hits something it will naively search the space around
# that point until it sinks the ship.
#
# Once all known ships are sunken, it will return to random shots
# in unkown territory.
#
class DestroyerStrategy

  def initialize(state, ships_remaining)
    @board = Board.new(state)
    @ships = Ships.new(ships_remaining)
  end

  def update(state, ships_remaining)
    @board.update(state)
    @ships.update(ships_remaining)
    sink_ship(@board.last_dot, @ships.recently_sunk) if @ships.recently_sunk
  end

  def take_turn
    get_hit_dots_neighbour || @board.random_remaining
  end

  private

  # Takes a dot on a newly destroyed ship and sinks it.
  # If we can't figure out where the ship is, leave it alone
  def sink_ship(dot, destroyed_ship)
    find_sunk_ship_spots(dot, destroyed_ship).each do |dot|
      @board.set_dot(dot, :sunk)
    end
  end

  # Returns spots corresponding to the newly sunken ship
  # If ambiguous, return empty array
  def find_sunk_ship_spots(dot, destroyed_ship)
    hs = find_hit_ship_spots(dot, [:left, :right])
    vs = find_hit_ship_spots(dot, [:up, :down])
    if hs.size == destroyed_ship && vs.size != destroyed_ship
      return hs
    elsif hs.size != destroyed_ship && vs.size == destroyed_ship
      return vs
    else
      return []
    end
  end

  def find_dot_to_the(direction, dot)
    case direction
    when :left
      [dot[0] - 1, dot[1]]
    when :right
      [dot[0] + 1, dot[1]]
    when :up
      [dot[0], dot[1] - 1]
    when :down
      [dot[0], dot[1] + 1]
    end
  end

  # Return a list of consecutive hit dots along an axis containing dot
  def find_hit_ship_spots(dot, directions)
    spots = [dot]
    directions.each do |dir|
      neighbour = dot
      while neighbour = find_dot_to_the(dir, neighbour)
        if @board.get_dot(neighbour[0], neighbour[1]) == :hit
          spots << neighbour
        else
          break
        end
      end
    end
    spots
  end

  def directions
    [:up, :down, :left, :right]
  end

  def get_hit_dots_neighbour
    @board.hit_dots.map{ |d| likely_target(d) }.compact.first
  end

  def likely_target(target)
    directions.
      map { |d| find_dot_to_the(d, target) }.
      find { |d| @board.get_dot(*d) == :unknown }
  end
end
