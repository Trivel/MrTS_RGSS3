#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr. Trivel                                             --(
# )--     NAME:       Change Equipment on Level Up                           --(
# )--     CREATED:    2015-05-02                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0  - Initial script.                                                --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Replace current equipment on level up.                                --(
# )-   Any amount of equipment can be replaced on level up.                  --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  Set up the module below and that's all.                               --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

module EquipmentLevelUp
  
  # )--------------------------------------------------------------------------(
  # )--  Should the current equiped item should be destroyed or unequiped?   --(
  # )--------------------------------------------------------------------------(
  DESTROY_EQUIPPED_ITEM = false
  
  # )--------------------------------------------------------------------------(
  # )--  A structure for defining which equipment actor equips on level up.  --(
  # )--                                                                      --(
  # )--  Structure:                                                          --(
  # )--  Actor_ID => {                                                       --(
  # )--    Level => [[item], [item]],                                        --(
  # )--  },                                                                  --(
  # )--  Actor_ID => {                                                       --(
  # )--    Level => [[item]],                                                --(
  # )--  },                                                                  --(
  # )--                                                                      --(
  # )--  item being [item_ID, item_type, slot_id]                            --(
  # )--  item_type being :weapon for weapon and :armour for armour           --(
  # )--                                                                      --(
  # )--  by default slot IDs go like this:                                   --(
  # )--  0 - weapon                                                          --(
  # )--  1 - shield (or weapon if character can dual wield)                  --(
  # )--  2 - head                                                            --(
  # )--  3 - armor                                                           --(
  # )--  4 - accessory                                                       --(
  # )--------------------------------------------------------------------------(
  HASH = {   
  
    # #Example    
    1 => { # Actor with ID one
       5 => [[21, :weapon, 0], [22, :armour, 3]], # on level 5 equip actor with 
                                                  # weapon ID 21 on slot 0 (weapon) 
                                                  # and equip armour with ID 22 on slot 3       
      10 => [[23, :weapon, 0]], # on level 10 equip weapon with ID 23 on slot 0
      15 => [[24, :armour, 3]], #on level 15 equip armour with ID 24 on slot 3
    },
    
    
  }
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Actor                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Actor < Game_Battler
  
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :mrts_equipchange_level_up :level_up  
  
  # )--------------------------------------------------------------------------(
  # )--  Aliased Method: level_up                                            --(
  # )--------------------------------------------------------------------------(
  def level_up
    mrts_equipchange_level_up
    
    return unless EquipmentLevelUp::HASH[@actor_id]
    a = EquipmentLevelUp::HASH[@actor_id]
    return unless a[@level]
    a[@level].each { |i|
      case i[1]
      when :weapon
        item = $data_weapons[i[0]]
      when :armour
        item = $data_armors[i[0]]
      end
      
      change_equip(i[2], nil) unless EquipmentLevelUp::DESTROY_EQUIPPED_ITEM
      force_change_equip(i[2], item)
    }
  end
end 