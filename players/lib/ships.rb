# This represents our ships
class Ships

  attr_reader :recently_sunk

  def initialize(ships_remaining)
    @ships_remaining = ships_remaining
    @recently_sunk = nil
  end

  def update(ships_remaining)
    destroyed_ship = newly_destroyed_ship(ships_remaining)
    @recently_sunk = destroyed_ship
    @ships_remaining = ships_remaining
  end

  def newly_destroyed_ship(ships_remaining)
    return nil if ships_remaining.length == @ships_remaining.length
    (@ships_remaining - ships_remaining).first || 3 # 3 is a duplicate
  end
end
