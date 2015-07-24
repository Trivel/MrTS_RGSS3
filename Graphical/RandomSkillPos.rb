#===============================================================================
# )----------------------------------------------------------------------------(
# )--     SCRIPT AUTHOR:     Mr. Trivel                                      --(
# )--     SCRIPT NAME:       Random Skill Position                           --(
# )--     CREATED:           2015-07-24                                      --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )-- Write this notetage in skill's note section that you want to have a    --(
# )-- random skill position on the target:                                   --(
# )--  <random anim pos>                                                     --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free to use for both commercial and non commercial use                --(
# )--  while proper credit is given to Mr. Trivel.                           --(
# )----------------------------------------------------------------------------(
#===============================================================================


# )============----------------------------------------------------------------(
# )-- Class: Scene_Battle                                                    --(
# )----------------------------------------------------------------============(
class Scene_Battle < Scene_Base
  alias :mrts_rta_sb_use_item :use_item
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased method: use_item                                             --(
  # )--------------------------------------------------------------------------(
  def use_item
    item = @subject.current_action.item
    if item.random_position_animation?
      targets = @subject.current_action.make_targets.compact
      targets.each { |t| t.random_anim_pos = true }
    end
    mrts_rta_sb_use_item
  end
end

# )============----------------------------------------------------------------(
# )-- Class: Game_Battler                                                    --(
# )----------------------------------------------------------------============(
class Game_Battler < Game_BattlerBase
  alias :mrts_rta_gb_clear_sprite_effects :clear_sprite_effects
  
  attr_accessor :random_anim_pos
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased method: clear_sprite_effects                                 --(
  # )--------------------------------------------------------------------------(
  def clear_sprite_effects
    mrts_rta_gb_clear_sprite_effects
    @random_anim_pos = false
  end
end

# )============----------------------------------------------------------------(
# )-- Class: Sprite_Base                                                     --(
# )----------------------------------------------------------------============(
class Sprite_Base < Sprite
  alias :mrts_rta_sb_set_animation_origin :set_animation_origin
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased method: set_animation_origin                                 --(
  # )--------------------------------------------------------------------------(
  def set_animation_origin
    mrts_rta_sb_set_animation_origin
    if @battler.random_anim_pos
      @ani_ox += rand(width) - width/2
      @ani_oy += rand(height) - height/2
    end
  end
end

# )============----------------------------------------------------------------(
# )-- Class: RPG::UsableItem                                                 --(
# )----------------------------------------------------------------============(
class RPG::UsableItem < RPG::BaseItem
  
  # )--------------------------------------------------------------------------(
  # )-- New method: random_position_animation?                               --(
  # )--------------------------------------------------------------------------(
  def random_position_animation?
    @random_pos_anime ||= self.note =~ /<random anim pos>/i ? true : false
  end
end
