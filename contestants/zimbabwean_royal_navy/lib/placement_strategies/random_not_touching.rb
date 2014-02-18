# RandomNotTouching
#
# A class that generates a list of placed ships
#
# Currently this is done most
# Place the ship randomly on the board. If it conflicts with an existing
# one, then place it again.
#
# Also, ships cannot be within one tile of each other
#
module PlacementStrategies
  class RandomNotTouching

    def initialize
      @placements = []
    end

    def place_all
      ships.each do |ship|
        begin
          p = generate_placement([:across, :down][rand(2)], ship)
        end while conflict?(p)
        @placements << p
      end
      @placements
    end

    private

    def ships
      [5, 4, 3, 3, 2]
    end

    # Does this ship placement conflict with the ships already placed?
    def conflict?(placement)
      ship_dots(placement).any? { |d| restricted_dots.include?(d) }
    end

    # Restricted dots (dots that we cannot place on)
    def restricted_dots
      @placements.map {|p| ship_proximity_dots(p) }.flatten(1)
    end

    # Choose ship placement
    def generate_placement(direction, ship)
      if direction == :across
        [rand(10-(ship +1)), rand(10), ship, direction]
      elsif direction == :down
        [rand(10), rand(10-(ship +1)), ship, direction]
      end
    end

    # Is this dot on the board?
    def invalid_dot?(dot)
      x, y = dot
      x < 0 || x >= 10 || y < 0 || y >= 10
    end

    # The dots taken by and around a ship
    def ship_proximity_dots(placement)
      p = placement
      [ship_dots(p), ship_surrounding_dots(p)].flatten(1).uniq
    end

    # The dots taken up by a ship
    def ship_dots(placement)
      x, y, ship, orientation = placement
      size = ship -1
      if orientation == :across
        (0..size).map { |i| [x + i, y] }
      else
        (0..size).map { |i| [x, y + i] }
      end
    end

    # The dots surrounding a ship
    def ship_surrounding_dots(placement)
      x, y, ship, orientation = placement
      if orientation == :across
        down = ship_dots([x, y+1, ship, orientation])
        up = ship_dots([x, y-1, ship, orientation])
        left = [[x-1, y]]
        right = [[x + ship, y]]
      else
        left = ship_dots([x -1, y, ship, orientation])
        right = ship_dots([x + 1, y, ship, orientation])
        up = [[x, y -1]]
        down = [[x, y + ship]]
      end
      [down, up, left, right].flatten(1).reject { |d| invalid_dot?(d) }
    end
  end
end
