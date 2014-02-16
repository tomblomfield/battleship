class AdmiralFriendlyPlayer
  attr_accessor :shots_available, :prior_shot, :target_group
  attr_reader   :name, :new_game

  def initialize
    @name            = "Admiral Mortimer Friendly"
    @new_game        = Command::Deploy::launch_fleet!
    @shots_available = Command::Deploy::new_tracking_grid 10
    @prior_shot    = [-1, -1]
    @target_group  = []
  end

  def take_turn current_grid, _ships_remaining
    target! current_grid
    fire! current_grid
  end

  def target! current_grid
    @target_group = Operations::Targeting::check_for_hit current_grid, @prior_shot, @shots_available
  end

  def fire! current_grid
    @prior_shot = Operations::Gunnery::fire! @target_group, @shots_available, current_grid
  end

  module Operations
    module Gunnery
      def self.fire! target_group, shots_available, current_grid
        shot = get_shot target_group, shots_available
        remove_shot shots_available, shot
        shot
      end

      def self.remove_shot shots_available, shot
        shots_available.delete shot
      end

      def self.get_shot target_group, shots_available
        target_group.empty? ? get_random_shot(shots_available) : target_group.pop
      end

      def self.get_random_shot shots_available
        shot = shots_available[ rand shots_available.size  ]
      end
    end

    module Targeting
      def self.check_for_hit current_grid, prior_shot, shots_available
        target_group = []
        if current_grid[prior_shot[1]][prior_shot[0]].to_sym == :hit
          target_group = get_target_group prior_shot, shots_available
        end
        target_group
      end

      def self.get_target_group shot, shots_available
        [:north, :east, :south, :west].each_with_object([]){| direction, group |
          group << get_live_adjacent_coordinate(shots_available, direction, shot[0], shot[1])
        }.compact.sort
      end

      def self.get_live_adjacent_coordinate shots_available, direction, y, x
        target = Radar::get_adjacent_space direction, y, x
        shots_available.index(target) ? target : nil
      end
    end

    module Radar
      def self.get_adjacent_space direction, y, x
        { north: ->(y,x){ [y, x-1] }, east: ->(y,x){ [y+1, x] },
          south: ->(y,x){ [y, x+1] }, west: ->(y,x){ [y-1, x] }
        }[direction].call(y,x)
      end

      def self.get_adjacent_coordinates current_grid, space
        [:north, :east, :south, :west].each_with_object([]) do | direction, spaces |
          spaces << get_adjacent_space(direction, space[0], space[1])
        end
      end
    end
  end

  module Command
    module Deploy
      def self.new_tracking_grid size
        rows, columns, grid = size, size, []
        0.upto(rows-1) do |row_index|
          0.upto(columns-1) {|column_index| grid << [ column_index, row_index ] }
        end
        grid
      end

      def self.launch_fleet!
        boards = [
          [[0,0,5,:down],  [4,4,4,:across],[9,3,3,:down],  [2,2,3,:across],[9,7,2,:down]],
          [[0,0,5,:across],[7,0,4,:down],  [0,2,3,:down],  [2,5,3,:down],  [8,8,2,:down]],
          [[1,1,5,:down],  [6,1,3,:across],[2,3,3,:across],[4,4,2,:down],  [6,3,4,:down]],
          [[9,0,3,:down],  [1,3,2,:across],[4,3,4,:down],  [7,3,5,:down],  [1,7,3,:down]],
          [[1,0,4,:across],[9,0,3,:down],  [6,4,2,:down],  [1,5,5,:down],  [3,7,3,:across]],
          [[0,0,4,:down],  [1,4,5,:across],[0,5,3,:down],  [1,8,2,:across],[4,8,3,:across]],
          [[0,1,5,:across],[5,1,3,:across],[8,2,2,:down],  [2,6,3,:across],[9,6,4,:down]],
          [[3,0,3,:across],[0,1,2,:across],[8,1,5,:down],  [1,5,4,:down],  [3,8,3,:across]],
          [[2,1,3,:across],[6,1,2,:across],[1,3,5,:across],[7,4,4,:down],  [2,6,3,:across]],
          [[5,0,3,:down],  [1,1,4,:down],  [3,2,2,:down],  [6,4,3,:down],  [2,8,5,:across]]
        ]
        boards[rand boards.size ]
      end
    end
  end

end
