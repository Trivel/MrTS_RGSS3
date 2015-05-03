#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Conditional Drops                                      --(
# )--     CREATED:    2014-10-03                                             --(
# )--     VERSION:    1.1                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
# )--  1.0a - Fix when starting battle with enemis without conditional drops.--(
# )--  1.1 - Multiple conditional drops are now allowed on same enemy.       --(
# )--        Variable increase/decrease is now a valid drop.                 --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Allows enemies to drop extra items if a condition is fulfilled like   --(
# )--  killing it with an element which the enemy is strong to.              --(
# )--                                                                        --(
# )--  Also allows enemies to increase variables on their deaths if condition--(
# )--  is fulfilled. Good for exterminate X monsters quests or variables     --(
# )--  which count enemies killed for achievements and other things.         --(
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
# )--                    For variable drop you'd use                         --(
# )--                    <c_drop: variable_id number>                        --(
# )--                    E.g. <c_drop: 23 1>                                 --(
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
# )--                                                                        --(
# )--  #3 variable drop example:                                             --(
# )--  <c_drop: 23 1>                                                        --(
# )--  <c_chance: 100%>                                                      --(
# )--  <c_type: custom>                                                      --(
# )--  <c_formula>                                                           --(
# )--  $game_switches[55]                                                    --(
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
    return unless enemy.conditional_drops && enemy.conditional_drops.size > 0
    
    @conditional_drop_fulfilled = []
    @conditional_drop = []
    @conditional_type = []
    @conditional_type_data = []
    @conditional_chance = []
    @conditional_custom = []
    
    i = 0
    enemy.conditional_drops.each { |drop|
      @conditional_drop_fulfilled[i] = false
      @conditional_drop[i] = drop.conditional_drop
      data = drop.conditional_drop_type
      @conditional_type[i] = data[0]
      @conditional_type_data[i] = data[1]
      @conditional_chance[i] = drop.conditional_drop_chance
      @conditional_custom[i] = drop.conditional_formula
      i += 1
    }
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: make_drop_items                                               --(
  # )--------------------------------------------------------------------------(
  def make_drop_items
    return mrts_conditional_drops_make_drop_items unless @conditional_drop_fulfilled.any? { |f| f }
    drops = mrts_conditional_drops_make_drop_items
    @conditional_drop_fulfilled.size.times { |i|    
      rolled = rand <= @conditional_chance[i] / 100.0
      next unless rolled && @conditional_drop_fulfilled[i]
      item = nil
      case @conditional_drop[i][0]
      when "w"
        item = $data_weapons[@conditional_drop[i][1]]
      when "a"
        item = $data_armors[@conditional_drop[i][1]]
      when "i"
        item = $data_items[@conditional_drop[i][1]]
      else
        if $game_variables[@conditional_drop[i][0].to_i]
          $game_variables[@conditional_drop[i][0].to_i] += @conditional_drop[i][1]
        else
          $game_variables[@conditional_drop[i][0].to_i] = @conditional_drop[i][1]
        end      
      end
      drops.push(item) if item
    }
    drops
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Method: fulfill_conditional                                          --(
  # )--------------------------------------------------------------------------(
  def fulfill_conditional
    return unless @conditional_drop
    @conditional_drop.size.times { |i|
      case @conditional_type[i]
      when :elemental
        @conditional_drop_fulfilled[i] = @conditional_type_data[i] == @result.element
      when :state
        @conditional_drop_fulfilled[i] = state?(@conditional_type_data[i])
      when :custom
        @conditional_drop_fulfilled[i] = eval(@conditional_custom[i])
      end
    }
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
  attr_accessor :conditional_drops
  
  # )--------------------------------------------------------------------------(
  # )-- Method: parse_conditional_drops                                      --(
  # )--------------------------------------------------------------------------(
  def parse_conditional_drops
    
    @conditional_drops = []
    
    tmp = nil
    
    note.split(/[\r\n]+/).each do |l|
      case l
      when /<c_drop:[ ]*(.*)[ ](-*\d+)>/i
        tmp = CDrop.new
        @conditional_drops.push(tmp)
        tmp.conditional_drop = [$1, $2.to_i]
      when /<c_type:[ ]*([a-z]*)[ ]*(\d+)*>/i
        tmp.conditional_drop_type = [$1.to_sym, $2.to_i]
      when /<c_chance:[ ]*(\d+)[%]*>/i
        tmp.conditional_drop_chance = $1.to_f
      when /<c_formula>/i
        @c_drop_formula = true
      when /<\\c_formula>/i
        @c_drop_formula = false
      else
        tmp.conditional_formula += l if @c_drop_formula
      end
    end
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: CDrop                                                           --(
# )---------------------------------------------------------------------=======(
class CDrop
  # )--------------------------------------------------------------------------(
  # )--  Public Instance Variables                                           --(
  # )--------------------------------------------------------------------------(
  attr_accessor :conditional_drop
  attr_accessor :conditional_drop_type
  attr_accessor :conditional_drop_chance
  attr_accessor :conditional_formula
  
  # )--------------------------------------------------------------------------(
  # )--  Method: initialize                                                  --(
  # )--------------------------------------------------------------------------(
  def initialize
    @conditional_drop = nil
    @conditional_drop_type = nil
    @conditional_drop_chance = 100
    @conditional_formula = ""
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