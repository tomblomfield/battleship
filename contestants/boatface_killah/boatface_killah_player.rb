$:.unshift File.expand_path("./lib", __FILE__)

require "./lib/board"
require "./lib/statistical_guesser"
require "./lib/snipe_guesser"
require "./lib/random_placer"

class BoatfaceKillahPlayer
  def name
    "Boatface Killah"
  end

  def new_game
    placer = RandomPlacer.new(Board.new).place_all_ships.map(&:to_a)
  end

  def take_turn(state, ships_remaining)
    # state is the known state of opponents fleet
    # ships_remaining is an array of the remaining opponents ships

    board = Board.new(state)
    # SnipeGuesser.take_turn(board, ships_remaining) ||
    StatisticalGuesser.new(board, ships_remaining).take_turn
  end
end

p BoatfaceKillahPlayer.new.new_game