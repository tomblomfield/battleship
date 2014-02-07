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
  class Twos < AttackStrategies::Base

    def initialize(*args)
      @evens_or_odds = rand(2)
      super
    end

    def take_turn
      (fire_on_hit_ships || no_leads_strategy).position
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

    def no_leads_strategy
      # @board.random_remaining
      tiles = valid_unknown_tiles
      tiles[rand(tiles.count)]
    end

    def valid_unknown_tiles
      @board.unknown_tiles.select do|t|
        (t.x + t.y) % 2 == @evens_or_odds
      end
    end
  end
end
