# DestroyerStrategy
#
# A class responsible for the strategy of destroying the ships
#
# The Destroyer Strategy chooses random points in unkown territory
# on the board.
# Once it hits something it will naively search the space around
# that point until it sinks the ship.
#
# Once all known ships are sunken, it will return to random shots
# in unkown territory.
#
module AttackStrategies
  class Destroyer < AttackStrategies::Base

    def take_turn
      (fire_on_hit_ships || @board.random_remaining).position
    end

    private

    def fire_on_hit_ships
      @board.hit_tiles.map{ |t| adjacent_unknown_tile(t) }.compact.first
    end

    # A likely place for a ship tile to be
    def adjacent_unknown_tile(tile)
      tile.neighbours.find {|t| t.state == :unknown }
    end
  end
end
