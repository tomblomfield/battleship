# This represents our board
class Board

  attr_reader :last_dot

  def initialize(state)
    @state = state
  end

  def update(state)
    @last_dot = newly_updated_dot(state)
    set_dot(@last_dot, state[@last_dot[1]][@last_dot[0]]) if @last_dot
  end

  def get_dot(x, y)
    return nil if [x, y].any? { |c| c < 0 || c >= @state.size }
    @state[y][x]
  end

  def set_dot(dot, status)
    @state[dot[1]][dot[0]] = status
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

  def hit_dots
    dots = []
    @state.each_with_index do |row, y|
      row.each_with_index do |s, x|
        dots << [x, y] if s == :hit
      end
    end
    dots
  end

  def dots_left_count
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

  def random_remaining
    nth_unkown(rand(dots_left_count))
  end

end
