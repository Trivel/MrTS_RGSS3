#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Quicksand                                              --(
# )--     CREATED:    2014-10-27                                             --(
# )--     VERSION:    1.2                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
# )--  1.1 - Player is slowed down while in quicksand.                       --(
# )--  1.2 - Multiple quicksand tiles.                                       --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Allows the developer to set which Terrain Tags are quicksand.         --(
# )--  Player will start sinking in quicksand. If DEATH option is set to true--(
# )--  player will get a game over screen after sinking completely. Or, if   --(
# )--  it's false, player will sink to a specific amount.                    --(
# )--                                                                        --(
# )--  Bonus: Best effect reached when quicksand tiles have Bush option.     --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  Customize value in Quicksand module. And play.                        --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

# )=======---------------------------------------------------------------------(
# )-- Module: Quicksand                                                      --(
# )---------------------------------------------------------------------=======(
module Quicksand
  
  Quicksands = {
    # Quicksand
    2 => {  :sinking_speed => 0.1,  # Sinking Speed in pixels per frame
            :slow_down => 0.05,     # Movement slow-down by %
            :max_slow_down => 0.5,  # Max slowdown in %
            :death => true,         # Death after sinking?
            :death_sink => 32,      # Pixels for death, VX Ace default is 32px
            :max_sink => 32,        # Max sink possible
            :dash => false          # Can dash in quicksand?
         },
    # Snow
    3 => {  :sinking_speed => 0.1,
            :slow_down => 0.04,
            :max_slow_down => 0.5,
            :death => false,
            :death_sink => 32,
            :max_sink => "$game_party.has_item?($data_items[1]) ? 4 : 8", # if party has item 1, make max sink 4, else it's 8
            :dash => true
         }
    
  }
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Player                                                     --(
# )---------------------------------------------------------------------=======(
class Game_Player < Game_Character
  
  include Quicksand
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :mrts_qcksnd_initialize :initialize
  alias :mrts_qcksnd_dash? :dash?
  alias :mrts_qcksnd_update :update
  alias :mrts_qcksnd_shift_y :shift_y
  alias :mrts_qcksnd_move_straight :move_straight 
  alias :mrts_qcksnd_update_move :update_move
  
  # )--------------------------------------------------------------------------(
  # )--  Public Instance Variables                                           --(
  # )--------------------------------------------------------------------------(
  attr_accessor :sunk
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: initialize                                                   --(
  # )--------------------------------------------------------------------------(
  def initialize
    mrts_qcksnd_initialize
    @sunk = 0.0
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: in_quicksand?                                           --(
  # )--------------------------------------------------------------------------(
  def in_quicksand?
    Quicksands[terrain_tag]
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: qcks_can_dash?                                          --(
  # )--------------------------------------------------------------------------(
  def qcks_can_dash?
    Quicksands[terrain_tag][:dash]
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: qcks_sink_speed                                         --(
  # )--------------------------------------------------------------------------(
  def qcks_sink_speed
    Quicksands[terrain_tag][:sinking_speed]
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: qcks_max_sink                                           --(
  # )--------------------------------------------------------------------------(
  def qcks_max_sink
    Quicksands[terrain_tag][:max_sink]
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: qcks_death_sink                                         --(
  # )--------------------------------------------------------------------------(
  def qcks_death_sink
    Quicksands[terrain_tag][:death_sink]
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: qcks_death                                              --(
  # )--------------------------------------------------------------------------(
  def qcks_death
    Quicksands[terrain_tag][:death]
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: qcks_slow_down                                          --(
  # )--------------------------------------------------------------------------(
  def qcks_slow_down
    Quicksands[terrain_tag][:slow_down]
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: qcks_max_slow_down                                      --(
  # )--------------------------------------------------------------------------(
  def qcks_max_slow_down
    Quicksands[terrain_tag][:max_slow_down]    
  end  
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: dash?                                                        --(
  # )--------------------------------------------------------------------------(
  def dash?
    return false if in_quicksand? && !qcks_can_dash?
    mrts_qcksnd_dash?
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: update                                                       --(
  # )--------------------------------------------------------------------------(
  def update
    mrts_qcksnd_update
    update_sinking
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: update_sinking                                          --(
  # )--------------------------------------------------------------------------(
  def update_sinking
    if in_quicksand?
      @sunk += qcks_sink_speed
      max_sink = eval(qcks_max_sink.to_s).to_f
      @sunk = max_sink if @sunk > max_sink
      SceneManager.goto(Scene_Gameover) if @sunk >= qcks_death_sink.to_f && qcks_death
    else
      @sunk -= 8.0 if @sunk > 0
      @sunk = 0 if @sunk < 0
    end
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: shift_y                                                      --(
  # )--------------------------------------------------------------------------(
  def shift_y
    shift = mrts_qcksnd_shift_y
    return shift-@sunk.to_i
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: move_straight                                                --(
  # )--------------------------------------------------------------------------(
  def move_straight(d, turn_ok = true)
    @move_succeed = passable?(@x, @y, d)
    dx = (d == 6 ? 1 : d == 4 ? -1 : 0)
    dy = (d == 2 ? 1 : d == 8 ? -1 : 0)
    new_x = @x + dx
    new_y = @y + dy
    if in_quicksand? && $game_map.terrain_tag(new_x, new_y) != terrain_tag && @move_succeed
      jump(dx, dy)
    else
      mrts_qcksnd_move_straight(d, turn_ok = true)
    end
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: update_move                                                  --(
  # )--------------------------------------------------------------------------(
  def update_move
    if in_quicksand?
      slowdown = distance_per_frame * [qcks_max_slow_down, (1 - @sunk*qcks_slow_down)].max
      @real_x = [@real_x - slowdown, @x].max if @x < @real_x
      @real_x = [@real_x + slowdown, @x].min if @x > @real_x
      @real_y = [@real_y - slowdown, @y].max if @y < @real_y
      @real_y = [@real_y + slowdown, @y].min if @y > @real_y
      update_bush_depth
    else
      mrts_qcksnd_update_move
    end
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class Sprite_Character < Sprite_Base
  
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :mrts_qcksnd_initialize :initialize
  alias :mrts_qcksnd_update_other :update_other
  alias :mrts_qcksnd_update_src_rect :update_src_rect
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: initialize                                                   --(
  # )--------------------------------------------------------------------------(
  def initialize(*args)
    @sunk = 0.0
    mrts_qcksnd_initialize(*args)
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: update_src_rect                                              --(
  # )--------------------------------------------------------------------------(
  def update_src_rect
    mrts_qcksnd_update_src_rect    
    self.src_rect.height -= @sunk
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: update_other                                                 --(
  # )--------------------------------------------------------------------------(
  def update_other
    mrts_qcksnd_update_other
    @sunk = @character.sunk if @character.is_a?(Game_Player)
  end
end