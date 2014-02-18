require "random_placer"
require "board"

# Randomly places ships in legal position and then adds up the likelihood that
# a ship is in any give spot
class MonteCarloMissileLauncher

  def initialize(board, ships_remaining)
    @board = board
    @ships_remaining = ships_remaining
  end

  def take_turn
    2000.times do
      make_guess_and_increment_counters
    end
    most_popular_xy
  end

  private
  # Matrix of board positions with the relative likelihood that a ship is in
  # that position
  def matrix
    @matrix ||= create_matrix
  end

  def create_matrix
    matrix = {}
    10.times do |x|
      10.times { |y| matrix[[x,y]] = 0 }
    end
    matrix
  end

  # Attempts to place a boat randomly. If it succeeds, increment all the counters in the position
  def make_guess_and_increment_counters
    placement = RandomPlacer.random_placement(random_ship)
    if @board.can_place?(placement)
      placement.expand_placement.each do |xy|
        matrix[xy] += score(xy)
      end
    end
  end

  # Ships are more likely to be placed where there are already hits
  def score(xy)
    case @board.state(xy)
    when :hit
      10
    when :unknown
      1
    else
      0
    end
  end

  def most_popular_xy
    unguessed = @matrix.to_a.select do |xy, count|
      @board.unknown_xy?(xy)
    end

    unguessed.sort_by { |xy, count| -count }.first.first
  rescue NoMethodError # If none of our placements hit a valid ship
    nil
  end

  def random_ship
    @ships_remaining.sample
  end
end