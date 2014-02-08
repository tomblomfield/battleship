class DeathPlayer
  SHIP_LENGTHS = [5, 4, 3, 3, 2]

  def name
    "Death Player"
  end

  def new_game
    Ship.choose_positions(Board.new_with(:empty), SHIP_LENGTHS).map(&:to_a)
  end

  def take_turn(state, ships_remaining)
    board = Board.new(state)
    probabilities = Ship.position_probabilities(ships_remaining)

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
