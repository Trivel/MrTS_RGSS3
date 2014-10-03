#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Conditional Drops                                      --(
# )--     CREATED:    2014-10-03                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
# )--  1.0a - Fix when starting battle with enemis without conditional drops.--(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Allows enemies to drop an extra item if a condition is fulfilled like --(
# )--  killing it with an element which the enemy is strong to.              --(
# )--                                                                        --(
# )--  Idea is from from Etrian Odyssey games where monsters could drop an   --(
# )--  extra item when a specific is fulfilled.                              --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  Use specific notetags on Enemy:                                       --(
# )--  --General:                                                            --(
# )--    <c_drop: X Y> - What item is the conditional drop.                  --(
# )--                    X - w, a, i - w - weapon, a - armor, i - item       --(
# )--                    Y - item number                                     --(
# )--                    Example: <c_drop: a 15> - 15th armor is the drop.   --(
# )--                                                                        --(
# )--    <c_chance X%> - What's the chance of getting conditional drop.      --(
# )--                    Example: <c_chance 77.7%>                           --(
# )--                                                                        --(
# )--  --Conditional drop type notetags:                                     --(
# )--  <c_type: elemental X> - Enemy must be killed with element X to be     --(
# )--                          able to drop the conditional drop.            --(
# )--                          Example: <c_type: elemental 5>                --(
# )--                                                                        --(
# )--  <c_type: state X> - Enemy must have state X when dying to be able to  --(
# )--                      drop the conditional drop.                        --(
# )--                      Example: <c_type: state 5>                        --(
# )--                                                                        --(
# )--  <c_type: custom> - You will have to specify condition yourself.       --(
# )--                                                                        --(
# )--  -- Type: Custom:                                                      --(
# )--  <c_formula> and <\c_formula> - to know where the custom condition is. --(
# )--  Example use:                                                          --(
# )--  <c_formula>                                                           --(
# )--  $game_party.members.size == 1                                         --(
# )--  <\c_formula>                                                          --(
# )--  This condition would check if there's only 1 member in the party.     --(
# )--                                                                        --(
# )--                                                                        --(
# )--  Example full notetags:                                                --(
# )--  #1:                                                                   --(
# )--  <c_drop: w 5>                                                         --(
# )--  <c_chance: 50%>                                                       --(
# )--  <c_type: elemental 5>                                                 --(
# )--                                                                        --(
# )--  #2:                                                                   --(
# )--  <c_drop: i 15>                                                        --(
# )--  <c_chance: 100%>                                                      --(
# )--  <c_type: custom>                                                      --(
# )--  <c_formula>                                                           --(
# )--  $game_switch[15] == true                                              --(
# )--  <\c_formula>                                                          --(
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
  alias :mrts_conditional_drops_initialize :initialize
  alias :mrts_conditional_drops_make_drop_items :make_drop_items
  alias :mrts_conditional_drops_execute_damage :execute_damage
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: initialize                                                    --(
  # )--------------------------------------------------------------------------(
  def initialize(index, enemy_id)
    mrts_conditional_drops_initialize(index, enemy_id) 
    return unless enemy.conditional_drop
    @conditional_drop_fulfilled = false
    @conditional_drop = enemy.conditional_drop
    data = enemy.conditional_drop_type
    @conditional_type = data[0]
    @conditional_type_data = data[1]
    @conditional_chance = enemy.conditional_drop_chance
    @conditional_custom = enemy.conditional_formula
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: make_drop_items                                               --(
  # )--------------------------------------------------------------------------(
  def make_drop_items
    return mrts_conditional_drops_make_drop_items unless @conditional_drop_fulfilled
    drops = mrts_conditional_drops_make_drop_items
    rolled = rand <= @conditional_chance / 100.0
    return drops unless rolled
    item = nil
    case @conditional_drop[0]
    when "w"
      item = $data_weapons[@conditional_drop[1]]
    when "a"
      item = $data_armors[@conditional_drop[1]]
    when "i"
      item = $data_items[@conditional_drop[1]]
    end
    drops.push(item)
    drops
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Method: fulfill_conditional                                          --(
  # )--------------------------------------------------------------------------(
  def fulfill_conditional
    return unless @conditional_drop
    case @conditional_type
    when :elemental
      @conditional_drop_fulfilled = @conditional_type_data == @result.element
    when :state
      @conditional_drop_fulfilled = state?(@conditional_type_data)
    when :custom
      @conditional_drop_fulfilled = eval(@conditional_custom)
    end
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: execute_damage                                                --(
  # )--------------------------------------------------------------------------(
  def execute_damage(user)
    fulfill_conditional if hp - @result.hp_damage <= 0
    mrts_conditional_drops_execute_damage(user)    
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class Game_ActionResult
  
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :mrts_conditional_drops_clear_damage_values :clear_damage_values
  alias :mrts_conditional_drops_make_damage :make_damage
  
  # )--------------------------------------------------------------------------(
  # )--  Public Instance Variables                                           --(
  # )--------------------------------------------------------------------------(
  attr_accessor :element                     
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: clear_damage_values                                           --(
  # )--------------------------------------------------------------------------(
  def clear_damage_values
    mrts_conditional_drops_clear_damage_values
    @element = 0
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: make_damage                                                   --(
  # )--------------------------------------------------------------------------(
  def make_damage(value, item)
    mrts_conditional_drops_make_damage(value, item)
    @element = item.damage.element_id
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: RPG::Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class RPG::Enemy < RPG::BaseItem
  
  # )--------------------------------------------------------------------------(
  # )--  Public Instance Variables                                           --(
  # )--------------------------------------------------------------------------(
  attr_accessor :conditional_drop
  attr_accessor :conditional_drop_type
  attr_accessor :conditional_drop_chance
  attr_accessor :conditional_formula
  
  # )--------------------------------------------------------------------------(
  # )-- Method: parse_conditional_drops                                      --(
  # )--------------------------------------------------------------------------(
  def parse_conditional_drops
    @conditional_drop = nil
    @conditional_drop_type = nil
    @conditional_drop_chance = 100
    @conditional_formula = ""
    
    note.split(/[\r\n]+/).each do |l|
      case l
      when /<c_drop:[ ]*(.)[ ](\d+)>/i
        @conditional_drop = [$1, $2.to_i]
      when /<c_type:[ ]*([a-z]*)[ ]*(\d+)*>/i
        @conditional_drop_type = [$1.to_sym, $2.to_i]
      when /<c_chance:[ ]*(\d+)[%]*>/i
        @conditional_drop_chance = $1.to_f
      when /<c_formula>/i
        @c_drop_formula = true
      when /<\\c_formula>/i
        @c_drop_formula = false
      else
        @conditional_formula += l if @c_drop_formula
      end
    end
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
    alias :mrts_conditional_drops_create_game_objects    :create_game_objects
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: create_game_objects                                           --(
  # )--------------------------------------------------------------------------(
  def self.create_game_objects
    mrts_conditional_drops_create_game_objects
    parse_conditional_drops
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: parse_conditional_drops                                  --(
  # )--------------------------------------------------------------------------(
  def self.parse_conditional_drops
    enemies = $data_enemies
    for enemy in enemies
      next if enemy.nil?
      enemy.parse_conditional_drops
    end
  end
end