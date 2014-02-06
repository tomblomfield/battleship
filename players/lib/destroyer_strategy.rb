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
# Known BUG: it always seeks out the end of a ship even if it knows
# that the ship is sunk
class DestroyerStrategy

  def get_dot(x, y)
    return nil if [x, y].any? { |c| c < 0 || c >= @state.size }
    @state[y][x]
  end

  def set_dot(dot, status)
    @state[dot[1]][dot[0]] = status
  end

  def initialize(state, ships_remaining)
    @state = state
    @ships_remaining = ships_remaining
  end

  def newly_destroyed_ship(ships_remaining)
    return nil if ships_remaining.length == @ships_remaining.length
    (@ships_remaining - ships_remaining).first || 3 # 3 is a duplicate
  end

  # Returns any newly updated dot
  def newly_updated_dot(state)
    state.each_with_index do |row, y|
      row.each_with_index do |s, x|
        next unless get_dot(x, y) == :unknown
        return [x, y] unless s == :unknown
      end
    end
    nil
  end

  # Takes a dot on a newly destroyed ship and sinks it.
  # If we can't figure out where the ship is, leave it alone
  def sink_ship(dot, destroyed_ship)
    find_sunk_ship_spots(dot, destroyed_ship).each do |dot|
      set_dot(dot, :sunk)
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
        if get_dot(neighbour[0], neighbour[1]) == :hit
          spots << neighbour
        else
          break
        end
      end
    end
    spots
  end

  def update(state, ships_remaining)
    dot = newly_updated_dot(state)
    set_dot(dot, state[dot[1]][dot[0]]) if dot

    destroyed_ship = newly_destroyed_ship(ships_remaining)
    sink_ship(dot, destroyed_ship) if destroyed_ship
    @ships_remaining = ships_remaining
  end

  def take_turn
    sunk = @state.flatten.select{ |x| x == :sunk }.count
    if hit_dots.size > 0
      likely = get_hit_dots_neighbour(hit_dots)
      likely || random_remaining
    else
      random_remaining
    end
  end

  def directions
    [:up, :down, :left, :right]
  end

  def get_hit_dots_neighbour(hit_dots)
    hit_dots.map{ |d| likely_target(d) }.compact.first
  end

  def likely_target(target)
    directions.
      map { |d| find_dot_to_the(d, target) }.
      find { |d| get_dot(*d) == :unknown }
  end

  def hit_dots
    dots = []
    @state.each_with_index do |row, y|
      row.each_with_index do |s, x|
        dots << [x, y] if s == :hit
      end
    end
    hits = @state.flatten.select{ |x| x == :hit}
    dots
  end

  def random_remaining
    nth_unkown(rand(dots_left))
  end

  def dots_left
    @state.flatten.select{ |x| x == :unknown }.count
  end

  def nth_unkown(n)
    @state.each_with_index do |row, y|
      row.each_with_index do |s, x|
        next unless s == :unknown
        return [x, y] if n == 0
        n -= 1
      end
    end
  end
end
