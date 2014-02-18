require "board"
require "monte_carlo_missile_launcher"
require "random_placer"

class BoatfaceKillahPlayer
  def name
    "Boatface Killah"
  end

  def new_game
    RandomPlacer.new(Board.new).place_all_ships.map(&:to_a)
  end

  def take_turn(state, ships_remaining)
    board = Board.new(state)
    MonteCarloMissileLauncher.new(board, ships_remaining).take_turn
  end
end