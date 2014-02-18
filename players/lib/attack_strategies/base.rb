require_relative "../board.rb"
require_relative "../ships.rb"

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
  class Base

    def initialize(state, ships_remaining)
      @board = Board.new(state)
      @ships = Ships.new(ships_remaining)
      @turn = 0
    end

    def update(state, ships_remaining)
      @turn += 1
      @board.update(state)
      @ships.update(ships_remaining)
      sink_ship(@board.latest_tile, @ships.recently_sunk) if @ships.recently_sunk
    end

    def take_turn
      @board.random_remaining.position
    end

    private

    # Takes a dot on a newly destroyed ship and sinks it.
    # If we can't figure out where the ship is, leave it alone
    def sink_ship(tile, destroyed_ship)
      find_sunk_ship_spots(tile, destroyed_ship).each {|t| t.update(:sunk)}
    end

    # Returns spots corresponding to the newly sunken ship
    # If ambiguous, return empty array
    def find_sunk_ship_spots(tile, destroyed_ship)
      hs = find_hit_ship_tiles(tile, [:left, :right])
      vs = find_hit_ship_tiles(tile, [:up, :down])
      if hs.size == destroyed_ship && vs.size != destroyed_ship
        return hs
      elsif hs.size != destroyed_ship && vs.size == destroyed_ship
        return vs
      else
        return []
      end
    end

    # Return a list of consecutive hit dots along an axis containing tile
    def find_hit_ship_tiles(tile, directions)
      tiles = [tile]
      directions.each do |dir|
        t = tile
        while t = @board.get_neighbour(t, dir)
          if t.state == :hit
            tiles << t
          else
            break
          end
        end
      end
      tiles
    end
  end
end
