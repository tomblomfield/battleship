require "placement_strategies.rb"
require "attack_strategies.rb"

class RandomSeekerPlayer

  def name
    "Random Seeker Player"
  end

  def new_game
    PlacementStrategies::Random.new.place_all
  end

  def take_turn(state, ships_remaining)
    @strategy ||= AttackStrategies::SmarterDestroyer.new(state,
      ships_remaining)
    @strategy.update(state, ships_remaining)
    @strategy.take_turn
  end
end

