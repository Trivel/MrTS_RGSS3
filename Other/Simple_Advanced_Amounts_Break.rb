#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr. Trivel                                             --(
# )--     NAME:       Simple Advanced Amounts Breaks                         --(
# )--     CREATED:    2015-05-08                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0  - Initial script.                                                --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Changes the amount limits of battle members, items, actor stats,      --(
# )--  gold.                                                                 --(
# )--  In addition battle members, items and gold limit can be changed using --(
# )--  variables in game.                                                    --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  Set up the module below and that's all.                               --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

module BreakModule
  
  # )--------------------------------------------------------------------------(
  # )-- Should variable's value be used to determine battle member number?   --(
  # )-- Set it to -1 if not, else set it to variable ID.                     --(
  # )--------------------------------------------------------------------------(
  MAX_BATTLE_MEMBERS_VARIABLE = 1
  
  # )--------------------------------------------------------------------------(
  # )-- If not using variable for max battle members, choose how many actors --(
  # )-- are there in battle.                                                 --(
  # )--------------------------------------------------------------------------(
  MAX_BATTLE_MEMBERS = 2
  
  # )--------------------------------------------------------------------------(
  # )-- Should variable's value be used to determine max gold party can carry? (
  # )-- Set it to -1 if not, else set it to variable ID.                     --(
  # )--------------------------------------------------------------------------(
  MAX_GOLD_VARIABLE = -1
  
  # )--------------------------------------------------------------------------(
  # )-- If not using variable for max gold, choose how much gold can party   --(
  # )-- carry.                                                               --(
  # )--------------------------------------------------------------------------(
  MAX_GOLD = 999_999_999_999
  
  # )--------------------------------------------------------------------------(
  # )-- Max amount for items per type globally.                              --(
  # )--------------------------------------------------------------------------(
  MAX_QUANTITY = {
    :weapon => 30,
    :item => 30,
    :armor => 30
  }
  
  # )--------------------------------------------------------------------------(
  # )-- Max specific item amount (overrwrites global value for that item)    --(
  # )--------------------------------------------------------------------------(
  MAX_ITEM = {
    :weapon => {
      # Item_ID => [Variable_ID, Amount_if_Variable_ID_is_-1]
      1 => [-1, 15], # Only 15 weapon ID 1 can be carried at the same time
      2 => [2], # Party can only have Weapon ID 2s as the same as the Variable #2
    },
    :armor => {
      
    },
    :item => {
      
    }
  }
  
  # )--------------------------------------------------------------------------(
  # )-- Default actor max stats.                                             --(
  # )--------------------------------------------------------------------------(
  MAX_ACTOR_PARAMS_GLOBAL = {
    #MAX HP
    0 => 10000,
    
    # MAX MP
    1 => 50,
    
    # ATK
    2 => 1000,
    
    # DEF
    3 => 1000,
    
    # MAG
    4 => 1000,
    
    # MDF
    5 => 1000,
    
    # AGI
    6 => 1000,
    
    # LUK
    7 => 1000
  }
  
  # )--------------------------------------------------------------------------(
  # )-- Specific actor max stats. Overrides global of that parameter.        --(
  # )--------------------------------------------------------------------------(
  MAX_ACTOR_PARAMS_SPECIFIC = {
   # Actor_ID => { stats }
    1 => {
      0 => 100,
      1 => 0,
      2 => 20,
      3 => 20,
      4 => 1,
      5 => 1,
      6 => 100,
      7 => 1000
    },
  }
  
end
# )=======---------------------------------------------------------------------(
# )-- Class: Game_Party                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Party < Game_Unit ; include BreakModule
  
  # )--------------------------------------------------------------------------(
  # )-- Overwrite Method: max_battle_members                                 --(
  # )--------------------------------------------------------------------------(
  def max_battle_members
    [MAX_BATTLE_MEMBERS_VARIABLE == -1 ? MAX_BATTLE_MEMBERS : $game_variables[MAX_BATTLE_MEMBERS_VARIABLE], 1].max
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Overwrite Method: max_gold                                           --(
  # )--------------------------------------------------------------------------(
  def max_gold
    MAX_GOLD_VARIABLE == -1 ? MAX_GOLD : $game_variables[MAX_GOLD_VARIABLE]
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Overwrite Method: max_item_number                                    --(
  # )--------------------------------------------------------------------------(
  def max_item_number(item)
    case item
    when RPG::Weapon
      type = :weapon
    when RPG::Armor
      type = :armor
    when RPG::UsableItem
      type = :item
    end
    
    if MAX_ITEM[type][item.id]
      return MAX_ITEM[type][item.id][0] == -1 ? MAX_ITEM[type][item.id][1] : $game_variables[MAX_ITEM[type][item.id][0]]
    end
    
    return MAX_QUANTITY[type]
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Spriteset_Battle                                                --(
# )---------------------------------------------------------------------=======(
class Spriteset_Battle
  
  # )--------------------------------------------------------------------------(
  # )-- Overwrite Method: create_actors                                      --(
  # )--------------------------------------------------------------------------(
  def create_actors
    @actor_sprites = Array.new($game_party.max_battle_members) { Sprite_Battler.new(@viewport1) }
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Actor                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Actor < Game_Battler ; include BreakModule
  
  # )--------------------------------------------------------------------------(
  # )-- Overwrite Method: param_max                                          --(
  # )--------------------------------------------------------------------------(
  def param_max(param_id)
    return MAX_ACTOR_PARAMS_SPECIFIC[@actor_id][param_id] if MAX_ACTOR_PARAMS_SPECIFIC[@actor_id] && MAX_ACTOR_PARAMS_SPECIFIC[@actor_id][param_id]
    return MAX_ACTOR_PARAMS_GLOBAL[param_id]
  end
end