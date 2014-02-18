# SmarterDestroyerStrategy
#
# A class responsible for the strategy of destroying the ships
#
# The smarter destroyer strategy is cleverer about how it destroys
# ships once it has discovered them. It doesn't just randomly look
# at the adjacent tiles to the ship, but reasons in the following way:
#
# It interpolates a line if there is one.
module AttackStrategies
  class SmarterDestroyer < AttackStrategies::Base

    def take_turn
      (fire_on_hit_ships || @board.random_remaining).position
    end

    private

    def fire_on_hit_ships
      @board.hit_tiles
        .map{ |t| t.neighbours }
        .flatten(1)
        .select { |t| t.state == :unknown }
        .each { |t| t.calculate_score }
        .sort { |t1, t2| t2.score <=> t1.score }
        .first
    end
  end
end
