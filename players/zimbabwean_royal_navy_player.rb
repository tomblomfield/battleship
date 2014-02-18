require_relative "lib/placement_strategies.rb"
require_relative "lib/attack_strategies.rb"

class ZimbabweanRoyalNavyPlayer

  def name
    "Zimbabwean Royal Navy"
  end

  def new_game
    PlacementStrategies::RandomNotTouching.new.place_all
  end

  def take_turn(state, ships_remaining)
    @strategy ||= AttackStrategies::Fours.new(state,
      ships_remaining)
    @strategy.update(state, ships_remaining)
    @strategy.take_turn
  end
end

