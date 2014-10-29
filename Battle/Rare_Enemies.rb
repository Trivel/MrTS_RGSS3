#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Rare Enemies                                           --(
# )--     CREATED:    2014-10-29                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  There's a chance to encouter a rare version of the enemy instead of   --(
# )--  default one.                                                          --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  Use these note tags in Enemy note box:                                --(
# )--  <re_id: X> - X to what enemy with ID X can the enemy change.          --(
# )--  <re_chc: X%> - X is what chance of it happening. X can be 0.5%, 10%.. --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Enemy < Game_Battler
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :re_ge_initialize :initialize
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: initialize                                                   --(
  # )--------------------------------------------------------------------------(
  def initialize(index, enemy_id)
    new_id = enemy_id
    tmp_ene = $data_enemies[enemy_id]
    if tmp_ene.rare_enemy_id
      rolled = rand <= tmp_ene.rare_enemy_chance
      new_id = tmp_ene.rare_enemy_id if rolled
    end
    re_ge_initialize(index, new_id)
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: RPG::Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class RPG::Enemy < RPG::BaseItem
  
  # )--------------------------------------------------------------------------(
  # )--  Public Instance Variables                                           --(
  # )--------------------------------------------------------------------------(
  attr_accessor :rare_enemy_id
  attr_accessor :rare_enemy_chance
  
  # )--------------------------------------------------------------------------(
  # )-- Method: parse_rare_enemies                                           --(
  # )--------------------------------------------------------------------------(
  def parse_rare_enemies
    @rare_enemy_id = note =~ /<re_id:[ ]*(\d+)>/i ? $1.to_i : nil
    @rare_enemy_chance = note =~ /<re_chc:[ ]*(\d+\.*\d*)%*>/i ? ($1.to_f/100.0) : nil
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Enemy                                                      --(
# )---------------------------------------------------------------------=======(
module DataManager
  class << self     
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
    alias :re_dm_create_game_objects    :create_game_objects
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: create_game_objects                                           --(
  # )--------------------------------------------------------------------------(
  def self.create_game_objects
    re_dm_create_game_objects
    parse_rare_enemies
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: self.parse_rare_enemies                                  --(
  # )--------------------------------------------------------------------------(
  def self.parse_rare_enemies
    enemies = $data_enemies
    for enemy in enemies
      next if enemy.nil?
      enemy.parse_rare_enemies
    end
  end
end