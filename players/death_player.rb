class DeathPlayer
  SHIP_LENGTHS = [5, 4, 3, 3, 2]

  def name
    "Death Player"
  end

  def new_game
    RandomShipPositionChooser.positions(Board.new_with(:empty), SHIP_LENGTHS).
      map(&:to_a)
  end

  def take_turn(state, ships_remaining)
    board = Board.new(state)
    probabilities = ShipPositionProbability.distribution(ships_remaining)

    targets =
      Board.all_coordinates.
      select {|c| board.get(c) == :unknown }.
      sort_by {|c| probabilities.get(c) }.
      reverse

    targets[0] unless targets.empty?
  end
end

class Position
  def initialize(x, y, length, direction)
    @x, @y, @length, @direction = x, y, length, direction
  end

  def self.random(length)
    direction = rand < 0.5 ? :across : :down
    Position.new(direction == :across ? rand(Board::SIZE - length) : rand(Board::SIZE),
                 direction == :down ? rand(Board::SIZE - length) : rand(Board::SIZE),
                 length,
                 direction)
  end

  def to_a
    [@x, @y, @length, @direction]
  end

  def to_coordinates
    (0...@length).map do |i|
      [@direction == :across ? @x + i : @x,
       @direction == :down ? @y + i : @y]
    end
  end
end

class Board
  SIZE = 10

  def initialize(data)
    @data = Board.copy_data(data)
  end

  def self.new_with(default)
    Board.new((0...SIZE).map {|_| (0...SIZE).map {|_| default }})
  end

  def self.copy_data(data)
    data.map(&:dup)
  end

  def self.all_coordinates
    (0...Board::SIZE).map {|x| (0...Board::SIZE).map {|y| [x, y] }}.flatten(1)
  end

  def get(coordinate)
    @data[coordinate[1]][coordinate[0]]
  end

  def set(coordinate, value)
    data_c = Board.copy_data(@data)
    data_c[coordinate[1]][coordinate[0]] = value
    Board.new(data_c)
  end

  def to_list
    (0...Board::SIZE).map {|x| (0...Board::SIZE).map {|y| [[x, y], get([x, y])] }}.flatten(1)
  end

  def to_s
    @data.map {|x| x.to_s }.join("\n")
  end
end

module RandomShipPositionChooser
  def self.positions(board, ship_lengths)
    return [] if ship_lengths.empty?
    position = self.random_empty_ship_position(board, ship_lengths[0])
    [position] + self.positions(
      position.to_coordinates.inject(board) {|b, c| b.set(c, :ship) },
      ship_lengths[1..-1])
  end

private
  def self.random_empty_ship_position(board, length)
    position = Position.random(length)
    return position if position.to_coordinates.all? {|x| board.get(x) != :ship }
    return random_empty_ship_position(board, length)
  end
end

module ShipPositionProbability
  def self.distribution(ship_lengths)
    ship_lengths.inject(Board.new_with(0)) do |board, length|
      across = Board.all_coordinates.select {|c| c[0] <= Board::SIZE-length }.
        map {|c| Position.new(c[0], c[1], length, :across).to_coordinates }.flatten(1)

      down = Board.all_coordinates.select {|c| c[1] <= Board::SIZE-length }.
        map {|c| Position.new(c[0], c[1], length, :down).to_coordinates }.flatten(1)

      (across + down).inject(board) do |board, coordinate|
        board.set(coordinate, board.get(coordinate) + 1)
      end
    end
  end
end
