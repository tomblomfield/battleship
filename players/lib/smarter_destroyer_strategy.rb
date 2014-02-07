require "board.rb"
require "ships.rb"
require "destroyer_strategy"

# SmarterDestroyerStrategy
#
# A class responsible for the strategy of destroying the ships
#
# The smarter destroyer strategy is cleverer about how it destroys
# ships once it has discovered them. It doesn't just randomly look
# at the adjacent tiles to the ship, but reasons in the following way:
#
# It interpolates a line if there is one.
class SmarterDestroyerStrategy < DestroyerStrategy

  def fire_on_hit_ships
    target_tiles = @board.hit_tiles
      .map{ |t| t.neighbours }
      .flatten(1)
      .select { |t| t.state == :unknown }
      .each { |t| t.calculate_score }
      .sort { |t1, t2| t2.score <=> t1.score }

    target_tiles.first
  end
end
