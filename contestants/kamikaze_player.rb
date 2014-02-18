class KamikazePlayer
  def name
    "神風 Player"
  end

  def new_game
    board.place_ships!
  end

  def take_turn(state, ships_remaining)
    board.fire!(state,ships_remaining)
  rescue
    [rand(9),rand(9)]
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
      @@last_turn_ships_remaining = []
      @@sunk_ship_coordinates = []
      @@last_turn_coords = []
      ships = Kamikaze::Admiral.new(self).place_ships!
      ships.map(&:to_input)
    end

    def fire!(state,ships_remaining)
      @state = state
      @ships_remaining = ships_remaining
      load_state!(state)
      record_sunk_ships!
      coords = Kamikaze::Commander.new(self,ships_remaining).next_shot_coordinates
      @@last_turn_ships_remaining = ships_remaining
      @@last_turn_coords = coords
      coords
    end

    def inspect
      "#<KamikazePlayer::Board>"
    end

    def moves
      100 - find_cells(unknown?: true).count
    end

    def no_hits?
      !find_cell(hit?: true)
    end

    def biggest_ship_remaining
      @ships_remaining.max
    end

    def vectors
      find_cells(state: :hit, vectors?: true).flat_map(&:vectors).uniq { |v| [:coordinate,:min,:max,:length,:state].map{|a| v.send(a) } }
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
          a = case attribute
          when Array then cell.send(attribute[0],*attribute[1..-1])
          else cell.send(attribute)
          end

          return false unless a == value
        end
        true
      end

      def ship_sunk_last_turn
        lt_remaining = @@last_turn_ships_remaining.dup
        @ships_remaining.each do |ship|
          found = lt_remaining.index(ship)
          lt_remaining.delete_at(found) if found
        end
        lt_remaining.first
      end

      def record_sunk_ships!
        add_sunk_ship! if ship_sunk_last_turn
        load_known_sunk_ships!
      rescue
      end

      def load_known_sunk_ships!
        @@sunk_ship_coordinates.each do |coord|
          find_cell(x: coord[0], y: coord[1]).state = :sunk
        end
      end

      def last_turns_cell
        find_cell(x: @@last_turn_coords[0], y: @@last_turn_coords[1]) if @@last_turn_coords
      end

      def add_sunk_ship!
        vector = vectors.find{|v| v.includes_cell?(last_turns_cell) }
        if vector && vector.length == ship_sunk_last_turn
          vector.cells.each do |cell|
            @@sunk_ship_coordinates << cell.coordinates
          end
        end
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
      return :gold if ((@x + @y) % 4 == 0)
      return :red if ((@x + @y) % 2 == 0)
      :black
    end

    def can_hide?(ship_size)
      max_hide.map {|c,max| max >= ship_size }.any?
    end

    def can_hide_both_ways?(ship_size)
      max_hide.map {|c,max| max >= ship_size }.all?
    end

    def neighbors(attrs={})
      [[@x+1,@y],[@x-1,@y],[@x,@y+1],[@x,@y-1]].map do |(x,y)|
        @board.find_cell(attrs.merge(x: x, y: y))
      end.compact
    end

    def vectors
      neighbors(state: @state).map do |c|
        Vector.new(self,c,@board)
      end
    end

    def vectors?
      !vectors.empty?
    end

    def inspect
      "#<KamikazePlayer::Cell @x=#{@x}, @y=#{@y}, @state=#{@state}>"
    end

    [:ship,:hit,:miss,:unknown,:sunk].each do |state|
      define_method("#{state}?") do
        /#{state}/i === @state
      end
    end

    def min_ship_length
      possible_ships.values.max
    end

    private
      # can_hide?(3,:x,:+)
      def max_hide
        [:x,:y].inject({}) do |h,c|
          h.merge(c => [:+,:-].inject(1) { |i,d| i + how_far(:unknown?,c,d) })
        end
      end

      def possible_ships
        return {} unless hit?
        [:x,:y].inject({}) do |h,c|
          h.merge(c => [:+,:-].inject(1) { |i,d| i + how_far(:hit?,c,d) })
        end
      end

      def coordinate_scope
        {x: @x, y: @y}
      end

      def how_far(attribute,coordinate,direction)
        i = 1
        loop do
          cell = @board.find_cell(coordinate_scope.merge(coordinate => send(coordinate).send(direction,i)))
          break unless (cell && cell.send(attribute))
          i += 1
        end
        i - 1
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
      if vectors_present?
        vector_shots.sample.coordinates
      elsif wounded_ship?
        fire_around_it.coordinates
      elsif seek_and_destroy
        seek_and_destroy.coordinates
      elsif false_vector_ignores
        false_vector_ignores.coordinates
      else
        @board.find_cells(state: :unknown).sample.coordinates
      end
    end

    private

      def wounded_ship?
        !hit_neighbors.empty?
      end

      def hit_neighbors
        @board.find_cells(state: :hit, vectors?: false).flat_map do |cell|
          cell.neighbors(state: :unknown)
        end
      end

      def vectors_present?
        !vector_shots.empty?
      end

      def vector_shots
        @board.vectors.flat_map(&:open_ends).uniq
      end

      def false_vector_ignores
        @board.find_cells(state: :hit).flat_map do |cell|
          cell.neighbors(state: :unknown)
        end.sample
      end

      def fire_around_it
        hit_neighbors.sample
      end

      def seek_and_destroy
        @board.find_cells(state: :unknown,color: :gold).sample ||
        @board.find_cells(state: :unknown,color: :red).sample
      end

  end
end

module Kamikaze
  class Vector
    attr_reader :coordinate, :min, :max, :length, :state
    def initialize(cell1,cell2,board)
      @cell1 = cell1
      @cell2 = cell2
      @board = board
      @state = cell1.state
      @coordinate = find_coordinate(cell1,cell2)
      @coordinate_value = cell1.send(@coordinate)
      @var_coordinate = @coordinate == :x ? :y : :x
      @min = how_far(:-)
      @max = how_far(:+)
      @length = (@max - @min) + 1
    end

    def cells
      (@min..@max).map do |c|
        @board.find_cell(@coordinate => @coordinate_value, @var_coordinate => c)
      end
    end

    def includes_cell?(cell)
      cells.include?(cell)
    end

    def open_ends
      ends.select {|cell| cell.unknown? }
    end

    def open?
      !open_ends.empty?
    end


    private
      def find_coordinate(cell1,cell2)
        [:x,:y].each do |coord|
          return coord if cell1.send(coord) == cell2.send(coord)
        end
      end

      def how_far(direction)
        i = 1
        loop do
          cell = @board.find_cell(@coordinate => @coordinate_value, @var_coordinate => @cell1.send(@var_coordinate).send(direction,i))
          break unless (cell && cell.send("#{@state}?"))
          i += 1
        end
        @cell1.send(@var_coordinate).send(direction,(i-1))
      end

      def ends
        [@board.find_cell(@coordinate => @coordinate_value,@var_coordinate => (@min-1)),@board.find_cell(@coordinate => @coordinate_value,@var_coordinate => (@max+1))].compact
      end

  end
end
