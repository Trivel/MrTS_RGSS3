#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr. Trivel                                             --(
# )--     NAME:       Simple Mercenaries                                     --(
# )--     CREATED:    2015-05-08                                             --(
# )--     VERSION:    1.0                                                    --(
# )--                                                                        --(
# )--     Script suggestion by: Silenity                                     --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0  - Initial script.                                                --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Adds functionality of simple mercenaries.                             --(
# )--  Using a script call player can hire mercenaries which stay until death--(
# )--  or until a certain number of victories.                               --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  Use in event/common even script calls:                                --(
# )--  add_mercenary(ID, TIMER)                                              --(
# )--    -- adds mercenary with actor ID for TIMER wins                      --(
# )--  remove_mercenary(ID)                                                  --(
# )--    -- forcefully removes mercenary with actor ID                       --(
# )--  common_event_on_leave(true/false)                                     --(
# )--    -- should common events be process when mercenary leaves?           --(
# )--  common_event_on_join(true/false)                                      --(
# )--    -- should common events be process when mercenary joins?            --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

module Mercenaries
  # )--------------------------------------------------------------------------(
  # )-- Do mercenaries leave on death?                                       --(
  # )--------------------------------------------------------------------------(
  MERCENARIES_LEAVE_ON_DEATH = true
  
  # )--------------------------------------------------------------------------(
  # )-- Should the common event process after the mercenary leaves the party?--(
  # )-- Can be changed using script calls ingame.                            --(
  # )--------------------------------------------------------------------------(
  PROCESS_MERC_LEAVE_COMMON_EVENTS = true
  
  # )--------------------------------------------------------------------------(
  # )-- Should the common event process after the mercenary join the party?  --(
  # )-- Can be changed using script calls ingame.                            --(
  # )--------------------------------------------------------------------------(
  PROCESS_MERC_JOIN_COMMON_EVENTS = true
  
  # )--------------------------------------------------------------------------(
  # )-- Which common events should be called when mercenary joins or leaves. --(
  # )--------------------------------------------------------------------------(
  MERCENARY_COMMON_EVENTS = {
  # Actor_ID => [Join_Common_Event_ID, Leave_Common_Event_ID]
    4 => [1, 2],
  }
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_System                                                     --(
# )---------------------------------------------------------------------=======(
class Game_System
  alias :mrts_merc_gs_initialize :initialize
  
  # )--------------------------------------------------------------------------(
  # )-- Public Instance Variables                                            --(
  # )--------------------------------------------------------------------------(
  attr_accessor :process_ce_on_merc_join
  attr_accessor :process_ce_on_merc_leave
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased Method: intialize                                            --(
  # )--------------------------------------------------------------------------(
  def initialize
    mrts_merc_gs_initialize
    @process_ce_on_merc_join  = Mercenaries::PROCESS_MERC_JOIN_COMMON_EVENTS
    @process_ce_on_merc_leave = Mercenaries::PROCESS_MERC_LEAVE_COMMON_EVENTS
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Actor                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Actor < Game_Battler
  alias :mrts_merc_ga_setup :setup
  alias :mrts_merc_ga_die :die
  
  # )--------------------------------------------------------------------------(
  # )-- Public Instance Variables                                            --(
  # )--------------------------------------------------------------------------(
  attr_accessor :is_mercenary
  attr_accessor :mercenary_timer
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased Method: setup                                                --(
  # )--------------------------------------------------------------------------(
  def setup(actor_id)
    mrts_merc_ga_setup(actor_id)
    @mercenary_timer = 0
    @is_mercenary = false
    @mercenary_leave_common_event = 0
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: set_mercenary                                            --(
  # )--------------------------------------------------------------------------(
  def set_mercenary(timer)
    @is_mercenary = true
    @mercenary_timer = timer
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased Method: die                                                  --(
  # )--------------------------------------------------------------------------(
  def die
    mrts_merc_ga_die
    $game_party.remove_mercenary(@actor_id) if @is_mercenary
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Party                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Party < Game_Unit
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: reduce_mercenary_timer                                   --(
  # )--------------------------------------------------------------------------(
  def reduce_mercenary_timer
    battle_members.each { |m|
      next unless m.is_mercenary
      m.mercenary_timer -= 1
      remove_mercenary(m.id) if m.mercenary_timer <= 0
    }
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: remove_mercenary                                         --(
  # )--------------------------------------------------------------------------(
  def remove_mercenary(id)
    return unless $game_party.members.any? { |m| m.id == id }
    remove_actor(id)
    $game_actors[id].is_mercenary = false
    $game_temp.reserve_common_event(Mercenaries::MERCENARY_COMMON_EVENTS[id][1]) if $game_system.process_ce_on_merc_leave
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: add_mercenary                                            --(
  # )--------------------------------------------------------------------------(
  def add_mercenary(id, timer)
    $game_actors[id].set_mercenary(timer)
    add_actor(id)
    $game_temp.reserve_common_event(Mercenaries::MERCENARY_COMMON_EVENTS[id][0]) if $game_system.process_ce_on_merc_join
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Interpreter                                                --(
# )---------------------------------------------------------------------=======(
class Game_Interpreter
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: add_mercenary                                            --(
  # )--------------------------------------------------------------------------(
  def add_mercenary(id, timer)
    $game_party.add_mercenary(id, timer)
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: remove_mercenary                                         --(
  # )--------------------------------------------------------------------------(
  def remove_mercenary(id)
    $game_party.remove_mercenary(id)
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: common_event_on_leave                                    --(
  # )--------------------------------------------------------------------------(
  def common_event_on_leave(bool)
    $game_system.process_ce_on_merc_leave = bool
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: common_event_on_join                                     --(
  # )--------------------------------------------------------------------------(
  def common_event_on_join(bool)
    $game_system.process_ce_on_merc_join = bool
  end    
end

# )=======---------------------------------------------------------------------(
# )-- Module: BattleManager                                                  --(
# )---------------------------------------------------------------------=======(
module BattleManager ; class << self
  alias :mrts_merc_bm_process_victory :process_victory
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased Method: process_victory                                      --(
  # )--------------------------------------------------------------------------(
  def process_victory
    $game_party.reduce_mercenary_timer
    mrts_merc_bm_process_victory
  end
end ; end