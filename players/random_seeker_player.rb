require "ship_placers.rb"
require "destroyer_strategy.rb"

class RandomSeekerPlayer

  def name
    "Random Seeker Player"
  end

  def new_game
    RandomShipPlacer.new.place_all
  end

  def take_turn(state, ships_remaining)
    @strategy ||= DestroyerStrategy.new(state, ships_remaining)
    @strategy.update(state, ships_remaining)
    @strategy.take_turn
  end
end

