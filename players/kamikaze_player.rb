class KamikazePlayer
  def name
    "神風 Player"
  end

  def new_game
    board.place_ships!
  end

  def take_turn(state, ships_remaining)
    p board.fire!(state,ships_remaining)
  end

  private
    def board
      Kamikaze::Board.new
    end
end

module Kamikaze
  module Coordinates
    def valid_coordinates?(x,y)
      x > -1 && x < 10 && y > -1 && y < 10
    end

    def vector(*cells)
      return :y if cells.map(&:x).uniq.length == 1
      return :x if cells.map(&:y).uniq.length == 1
    end
  end
end


module Kamikaze
  class Board
    include Coordinates
    attr_reader :cells, :state
    def initialize
      @cells = []
      set_up_cells!
    end

    def find_cell(attrs={})
      @cells.find {|c| match?(c,attrs) }
    end

    def find_cells(attrs={})
      @cells.select {|c| match?(c,attrs) }
    end

    def place_ships!
      ships = Kamikaze::Admiral.new(self).place_ships!
      ships.map(&:to_input)
    end

    def fire!(state,ships_remaining)
      p @state = state
      load_state!(state)
      Kamikaze::Commander.new(self,ships_remaining).next_shot_coordinates
    end

    def inspect
      "#<KamikazePlayer::Board>"
    end


    private
      def set_up_cells!
        iterate_coordinates {|x,y| @cells << Cell.new(x,y,self) }
      end

      def load_state!(state)
        iterate_coordinates do |x,y|
          cell = find_cell(x: x, y: y)
          cell.state = state[y][x]
        end
      end

      def iterate_coordinates
        10.times do |x|
          10.times do |y|
            yield(x,y)
          end
        end
      end

      def match?(cell,attrs={})
        attrs.each do |attribute,value|
          return false unless cell.send(attribute) == value
        end
        true
      end
  end
end


module Kamikaze
  class Cell
    include Coordinates
    attr_reader :x, :y
    attr_accessor :state
    def initialize(x,y,board,state=:unknown)
      @x,@y,@board,@state = x,y,board,state
    end

    def coordinates
      [@x,@y]
    end

    def color
      ((@x + @y) % 2 == 0) ? :red : :black
    end

    def neighbors(attrs={})
      [[@x+1,@y],[@x-1,@y],[@x,@y+1],[@x,@y-1]].map do |(x,y)|
        @board.find_cell(attrs.merge(x: x, y: y))
      end.compact
    end

    def inspect
      "#<KamikazePlayer::Cell @x=#{@x}, @y=#{@y}, @state=#{@state}>"
    end

    [:ship,:hit,:miss,:unknown].each do |state|
      define_method("#{state}?") do
        /#{state}/i === @state
      end
    end

  end
end

module Kamikaze
  class Admiral
    include Coordinates
    def initialize(board)
      @board = board
      @ships = []
    end

    def place_ships!
      [2,3,3,4,5].each do |length|
        place_ship!(length)
      end
      @ships
    end

    def place_ship!(length)
      ship = Ship.new(@board,length)
      if ship.valid? && ship.not_adjacent?
        @ships << ship.place!
      else
        place_ship!(length)
      end
    end

  end

end

module Kamikaze
  class Ship
    include Coordinates
    def initialize(board,length)
      @board = board
      @x,@y = rand(8)+1,rand(8)+1
      @orientation = [:down,:across].sample
      @length = length
    end

    def to_input
      [@x,@y,@length,@orientation]
    end

    def down?
      /down/i === @orientation
    end

    def across?
      /across/i === @orientation
    end

    def place!
      ship_cells { |cell| cell.state = :ship } and self
    end

    def valid?
      ship_cells do |cell|
        return false unless cell
        return false if cell.ship?
      end
      true
    end

    def not_adjacent?
      ship_cells do |cell|
        cell.neighbors.each do |neighbor|
          return false if neighbor.ship?
        end
      end
      true
    end


    private

      def ship_cells
        @length.times do |i|
          cell = @board.find_cell(x: (down? ? @x : @x+i), y: (down? ? @y+i : @y))
          yield(cell)
        end
      end
  end
end

module Kamikaze
  class Commander
    def initialize(board,ships_remaining)
      @board,@ships_remaining = board,ships_remaining
    end

    def next_shot_coordinates
      if wounded_ship?
        eradicate_it!
      else
        seek_and_destroy.coordinates
      end
    end

    private

      def wounded_ship?
        !hit_neighbors.empty?
      end

      def hit_neighbors
        @board.find_cells(state: :hit).flat_map do |cell|
          cell.neighbors(state: :unknown)
        end
      end

      def eradicate_it!
        if vectors_present?
          vector_shots.sample
        else
          fire_around_it
        end
      end

      def vectors_present?
        false
      end

      def vector_shots
        @board.find_cells(state: :hit).inject([])
      end

      def fire_around_it
        hit_neighbors.sample.coordinates
      end

      def seek_and_destroy
        @board.find_cells(state: :unknown,color: :red).sample
      end

  end
end
