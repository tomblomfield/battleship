class DeathPlayer
  SHIP_LENGTHS = [5, 4, 3, 3, 2]

  def name
    "Death Player"
  end

  def new_game
    @shots = []

    RandomShipPositionChooser.positions(Board.defaults(:empty), SHIP_LENGTHS).
      map(&:to_a)
  end

  def take_turn(state, ships_remaining)
    target = pick_target(state, @shots, ships_remaining)
    @shots << target if target
    target
  end

private
  def pick_target(state_board, shots, ships_remaining)
    Trace.next_target(state_board, shots) ||
      ShipPositionProbability.next_target(state_board, ships_remaining) ||
      nil
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

module Board
  SIZE = 10

  def self.copy(board)
    board.map(&:dup)
  end

  def self.defaults(default)
    (0...SIZE).map {|_| (0...SIZE).map {|_| default }}
  end

  def self.all_coordinates
    (0...Board::SIZE).map {|x| (0...Board::SIZE).map {|y| [x, y] }}.flatten(1)
  end

  def self.get(board, coordinate)
    board[coordinate[1]][coordinate[0]]
  end

  def self.set(board, coordinate, value)
    cp = Board.copy(board)
    cp[coordinate[1]][coordinate[0]] = value
    cp
  end

  def self.line(coordinate, dx, dy)
    x, y = coordinate
    coordinates = []
    while x >= 0 && y >= 0 && x < SIZE && y < SIZE
      coordinates << [x, y]
      x += dx
      y += dy
    end

    coordinates
  end


  # use state board for prob

  def self.to_s(board)
    board.map {|x| x.to_s }.join("\n")
  end
end

module RandomShipPositionChooser
  def self.positions(board, ship_lengths)
    return [] if ship_lengths.empty?
    position = random_empty_ship_position(board, ship_lengths[0])
    [position] + positions(
      position.to_coordinates.inject(board) {|b, c| Board.set(b, c, :ship) },
      ship_lengths[1..-1])
  end

private
  def self.random_empty_ship_position(board, length)
    position = Position.random(length)
    return position if position.to_coordinates.all? {|x| Board.get(board, x) != :ship }
    return random_empty_ship_position(board, length)
  end
end

module ShipPositionProbability
  def self.next_target(board, ship_lengths)
    probability_board = distribution(ship_lengths)
    targets =
      Board.all_coordinates.
      select {|c| Board.get(board, c) == :unknown }.
      sort_by {|c| Board.get(probability_board, c) }.
      reverse

    targets.empty? ? nil : targets[0]
  end

  def self.distribution(ship_lengths)
    ship_lengths.inject(Board.defaults(0)) do |board, length|
      across = Board.all_coordinates.select {|c| c[0] <= Board::SIZE-length }.
        map {|c| Position.new(c[0], c[1], length, :across).to_coordinates }.flatten(1)

      down = Board.all_coordinates.select {|c| c[1] <= Board::SIZE-length }.
        map {|c| Position.new(c[0], c[1], length, :down).to_coordinates }.flatten(1)

      (across + down).inject(board) do |board, coordinate|
        Board.set(board, coordinate, Board.get(board, coordinate) + 1)
      end
    end
  end
end

module Trace
  def self.next_target(board, shots)
    shots.reverse.select {|s| Board.get(board, s) == :hit }.each do |hit|
      target = find_next_target_from_hit(board, hit)
      return target if target
    end && nil # what is ruby idiom for this?
  end

private
  def self.find_next_target_from_hit(board, hit)
    find_next_target_from_line(board, Board.line(hit,   -1,  0)) || # left
      find_next_target_from_line(board, Board.line(hit,  1,  0)) || # right
      find_next_target_from_line(board, Board.line(hit,  0, -1)) || # up
      find_next_target_from_line(board, Board.line(hit,  0,  1))    # down
  end

  def self.find_next_target_from_line(board, coordinates)
    coordinates.take_while {|c| Board.get(board, c) != :miss }.
      find {|c| Board.get(board, c) == :unknown }
  end
end
