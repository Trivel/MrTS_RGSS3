#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Quicksand                                              --(
# )--     CREATED:    2014-10-27                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Allows the developer to set which Terrain Tags are quicksand.         --(
# )--  Player will start sinking in quicksand. If DEATH option is set to true--(
# )--  player will get a gameover screen after sinking completely. Or, if    --(
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
  # )--------------------------------------------------------------------------(
  # )--  Set which Terrain Tags are quicksand. E.g. [2, 3, 5]                --(
  # )--  Best effect is if those tiles are set to Bush, too.                 --(
  # )--------------------------------------------------------------------------(
  QUICKSAND_TAGS = [5]
  
  # )--------------------------------------------------------------------------(
  # )--  Speed of player sinking. Default - 0.1 pixel per frame.             --(
  # )--------------------------------------------------------------------------(
  SINKING_SPEED = 0.1
  
  # )--------------------------------------------------------------------------(
  # )--  If DEATH is true and player sinks in completely, player gets a game --(
  # )--  over screen.                                                        --(
  # )--  DEATH_SINK - required sunk pixels to get game over screen. By       --(
  # )--  default player sprite is 32 pixels.                                 --(
  # )--------------------------------------------------------------------------(
  DEATH = true
  DEATH_SINK = 32
  
  # 
  # )--------------------------------------------------------------------------(
  # )--  If DEATH is set to false, set the max possible sink.                --(
  # )--------------------------------------------------------------------------(
  MAX_SINK = 16
  
  # )--------------------------------------------------------------------------(
  # )--  Can player Dash in quicksand?                                       --(
  # )--------------------------------------------------------------------------(
  DASH = false
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
    QUICKSAND_TAGS.include?(terrain_tag)
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: dash?                                                        --(
  # )--------------------------------------------------------------------------(
  def dash?
    return false if in_quicksand? && !DASH
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
      @sunk += SINKING_SPEED
      @sunk = MAX_SINK.to_f if @sunk > MAX_SINK.to_f && !DEATH
      SceneManager.goto(Scene_Gameover) if @sunk >= DEATH_SINK.to_f
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
    if in_quicksand? && ! QUICKSAND_TAGS.include?($game_map.terrain_tag(new_x, new_y)) && @move_succeed
      jump(dx, dy)
    else
      mrts_qcksnd_move_straight(d, turn_ok = true)
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