# ShipPlacer
#
# A class that generates a list of placed ships
#
#
# Currently this is done mostly randomly. From biggest ship to smallest,
# Place the ship randomly on the board. If it conflicts with an existing
# one, then place it again.
#
#
class RandomShipPlacer

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
    placement_dots(placement).any? { |d| taken_dots.include?(d) }
  end

  # The dots currently taken by other ships
  def taken_dots
    @placements.map {|p| placement_dots(p) }.flatten(1)
  end

  # Choose ship placement
  def generate_placement(direction, ship)
    if direction == :across
      [rand(10-(ship +1)), rand(10), ship, direction]
    elsif direction == :down
      [rand(10), rand(10-(ship +1)), ship, direction]
    end
  end

  # The dots taken up by a ship
  def placement_dots(placement)
    x, y, ship, orientation = placement
    size = ship -1
    if orientation == :across
      (0..size).map { |i| [x + i, y] }
    else
      (0..size).map { |i| [x, y + i] }
    end
  end
end
