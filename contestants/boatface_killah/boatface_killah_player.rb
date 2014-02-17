require "board"
require "statistical_guesser"
require "snipe_guesser"
require "random_placer"

class BoatfaceKillahPlayer
  def name
    "Boatface Killah"
  end

  def new_game
    placer = RandomPlacer.new(Board.new)
    placer.place_all_ships
    placer.placements.map(&:to_a)
  end

  def take_turn(state, ships_remaining)
    # state is the known state of opponents fleet
    # ships_remaining is an array of the remaining opponents ships

    board = Board.new(state)
    SnipeGuesser.take_turn(board, ships_remaining) ||
    StatisticalGuesser.take_turn(board, ships_remaining)
  end
end

# p BoatfaceKillahPlayer.new.new_game