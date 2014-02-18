require "./lib/random_placer"
require "./lib/board"

# Randomly places ships in legal position and then adds up the likelihood that
# a ship is in any give spot
class StatisticalGuesser

  def initialize(board, ships_remaining)
    @board = board
    @ships_remaining = ships_remaining
  end

  def take_turn
    10000.times do
      make_guess_and_increment_counters
    end
    most_popular_xy
  end

  private
  # Matrix of board positions with the relative likelihood that a ship is in
  # that position
  def matrix
    @matrix ||= Hash.new(0)
  end

  # Attempts to place a boat randomly. If it succeeds, increment all the counters in the position
  def make_guess_and_increment_counters
    placement = RandomPlacer.new(@board).random_placement(random_ship)
    placement.expand_placement.each do |xy|
      @matrix[xy] += 1
    end
  end

  def most_popular_xy
    @matrix.to_a.sort { |key, value| value }.first.first
  end

  def random_ship
    @ships_remaining.sample
  end
end