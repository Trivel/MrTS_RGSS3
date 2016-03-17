##=============================================================================
## MrTS_DifferentMpNames.rb
##=============================================================================

##=============================================================================
## Terms of Use
##-----------------------------------------------------------------------------
## Don't remove the header or claim that you wrote this plugin.
## Credit Mr. Trivel if using this plugin in your project.
## Free for commercial and non-commercial projects.
##-----------------------------------------------------------------------------
## Version 1.0
##=============================================================================

#==============================================================================
# ** MpNames
#==============================================================================

module MpNames
  MPLIST = {
   # ACTOR_ID => ["MP NAME", COLOR1, COLOR2],
   1 => ["MP", [64, 128, 192, 255], [64, 192, 240, 255]],
   2 => ["SP", [247, 24, 252, 255], [252, 105, 255, 255]],
   3 => ["TP", [66, 254, 193, 255], [64, 255, 240, 255]],
   4 => ["BP", [208, 46, 46, 255], [237, 87, 87, 255]],
  }
end


#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # * New: set_mp_gauge_colors
  #--------------------------------------------------------------------------
  def set_mp_gauge_colors(actorId)
    if MpNames::MPLIST[actorId]
      r = MpNames::MPLIST[actorId][1][0]
      g = MpNames::MPLIST[actorId][1][1]
      b = MpNames::MPLIST[actorId][1][2]
      a = MpNames::MPLIST[actorId][1][3]
      @mp_gauge_color1 = Color.new(r, g, b, a)
      
      r = MpNames::MPLIST[actorId][2][0]
      g = MpNames::MPLIST[actorId][2][1]
      b = MpNames::MPLIST[actorId][2][2]
      a = MpNames::MPLIST[actorId][2][3]
      @mp_gauge_color2 = Color.new(r, g, b, a);
    else
      @mp_gauge_color1 = text_color(22)
      @mp_gauge_color2 = text_color(23)
    end
  end
    
  #--------------------------------------------------------------------------
  # * Overwritten: mp_gauge_color1
  #--------------------------------------------------------------------------
  def mp_gauge_color1
    return @mp_gauge_color1 if @mp_gauge_color1
    return text_color(22)
  end
  
  #--------------------------------------------------------------------------
  # * Overwritten: mp_gauge_color2
  #--------------------------------------------------------------------------
  def mp_gauge_color2
    return @mp_gauge_color2 if @mp_gauge_color2
    return text_color(23)
  end

  #--------------------------------------------------------------------------
  # * Alias: draw_actor_mp
  #--------------------------------------------------------------------------
  alias :mrts_dmpn_draw_actor_mp :draw_actor_mp
  def draw_actor_mp(actor, x, y, width = 124)
    set_mp_gauge_colors(actor.id)
    $game_system.set_actor_mp_name(actor.id)
    mrts_dmpn_draw_actor_mp(actor, x, y, width)
  end
end


#==============================================================================
# ** Game_System
#==============================================================================
class Game_System
  #--------------------------------------------------------------------------
  # * New: set_actor_mp_name
  #--------------------------------------------------------------------------
  def set_actor_mp_name(actorId)
    if MpNames::MPLIST[actorId]
      @actor_mp_name = MpNames::MPLIST[actorId][0]
    else
      Vocab::basic(5)
    end
  end
  
  #--------------------------------------------------------------------------
  # * New: get_actor_mp_name
  #--------------------------------------------------------------------------
  def get_actor_mp_name
    return @actor_mp_name if @actor_mp_name
    return Vocab::basic(5)
  end
end


#==============================================================================
# ** Vocab
#==============================================================================

module Vocab
  #--------------------------------------------------------------------------
  # * Overwritten: mp_a
  #--------------------------------------------------------------------------
  def self.mp_a
    return $game_system.get_actor_mp_name
  end
end
