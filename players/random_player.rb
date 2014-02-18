class RandomPlayer

  def name
    "Random Player"
  end

  def new_game
    [
      [0, 0, 5, :across],
      [0, 1, 4, :across],
      [0, 2, 3, :across],
      [0, 3, 3, :across],
      [0, 4, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)
    Board.new(state, ships_remaining).random_remaining
  end
end

class Board

  attr_accessor :state, :ships_remaining

  def initialize(state, ships_remaining)
    @state = state
    @ships_remaining = ships_remaining
  end

  def random_remaining
    nth_unkown(rand(dots_left))
  end

  def dots_left
    state.flatten.select{ |x| x == :unknown }.count
  end

  def nth_unkown(n)
    state.each_with_index do |row, y|
      row.each_with_index do |s, x|
        next unless s == :unknown
        return [x, y] if n == 0
        n -= 1
      end
    end
  end
end