require "tile.rb"

# This represents our board
class Board

  attr_reader :latest_tile

  def initialize(state)
    @tiles = {}
    instantiate_tiles(state)
  end

  def instantiate_tiles(state)
    state.each_with_index do |row, y|
      row.each_with_index do |status, x|
        @tiles[[x, y]] = Tile.new(x, y, status, self)
      end
    end
  end

  def update(state)
    tile = newly_updated_tile(state)
    tile.update(state[tile.y][tile.x]) if tile
    @latest_tile = tile
  end

  def get_tile(x, y)
    @tiles[[x, y]]
  end

  def get_tile_state(x, y)
    t = get_tile(x, y)
    t.state if t
  end

  def get_neighbour(tile, direction)
    get_tile(*tile.neighbour_position(direction))
  end

  def get_neighbours(tile)
    tile.neighbour_positions.map {|c| get_tile(*c) }.compact
  end

  # Returns the newly updated tile if any
  def newly_updated_tile(state)
    state.each_with_index do |row, y|
      row.each_with_index do |s, x|
        next unless get_tile(x, y).state == :unknown
        return get_tile(x, y) unless s == :unknown
      end
    end
    nil
  end

  def hit_tiles
    @tiles.values.select { |t| t.state == :hit }
  end

  def unknown_tiles
    @tiles.values.select{ |t| t.state == :unknown }
  end

  def random_remaining
    unknown_tiles[rand(unknown_tiles.count)]
  end
end
