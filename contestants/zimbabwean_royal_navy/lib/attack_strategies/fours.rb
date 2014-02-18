# FoursStrategy
#
# A class responsible for the strategy of destroying the ships
#
# The four's strategy starts by only hitting tiles that are
# 4 apart (staggered randomly for each game)
#
# Once you can no longer do that, it lets two's strategy take over.
#
# The idea is that this beats twos since you have a higher likelyhood
# of find the 2 and 3 ship before needing to switch to 2s (which uses more
# spaces)
#
#
module AttackStrategies
  class Fours < AttackStrategies::Base

    def initialize(*args)
      @evens_or_odds = rand(2)
      @fourdie = rand(4)
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
      tiles = valid_unknown_4_tiles
      tiles = valid_unknown_2tiles if tiles.size == 0
      tiles[rand(tiles.count)]
    end

    def valid_unknown_4_tiles
      @board.unknown_tiles.select do|t|
        (t.x + t.y ) % 4 == @fourdie
      end
    end

    def valid_unknown_2tiles
      @board.unknown_tiles.select do|t|
        (t.x + t.y) % 2 == @fourdie % 2
      end
    end
  end
end
