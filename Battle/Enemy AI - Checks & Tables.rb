#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Enemy AI - Checks & Tables                             --(
# )--     CREATED:    2014-11-09                                             --(
# )--     VERSION:    1.1                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
# )--  1.1 - Small compatibility addon.                                      --(
# )--        Enemies will use default patterns in database if tables and     --(
# )--          checks aren't created.                                        --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Instead of using Attack Patterns in database which don't allow for    --(
# )--  much customization. All enemy patterns will be written in module      --(
# )--  allowing more complex and varying interactions in the battle.         --(
# )--                                                                        --(
# )--  How the AI works:                                                     --(
# )--   AI goes through every Check in order, checking conditions for it.    --(
# )--   Depending on condition results, it checks which Table to use.        --(
# )--   If Table is a nil, it goes to the next check. Else it uses the Table --(
# )--   that was set.                                                        --(
# )--   Repeat for all checks until Table is found.                          --(
# )--   After Table is found, it uses weighted randomness to determine which --(
# )--   attack to use from that Table.                                       --(
# )--                                                                        --(
# )--  Warning: This may be a tiny little bitty bitsy complex to set up.     --( 
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

module ATDATA
  
  # )--------------------------------------------------------------------------(
  # )--  DATA Hash creation. Leave it alone.                                 --(
  # )--------------------------------------------------------------------------(
  DATA = {}
  
  
  # )==========================================================================(
  # )--- Setup your enemy AI here.                                          ---(
  # )==========================================================================(
  
  # )--------------------------------------------------------------------------(
  # )--  DATA[ID] - which enemy AI will it be.                               --(
  # )--------------------------------------------------------------------------(
  # )--  DATA[1] - AI for Enemy with ID 1.                                   --(
  # )--------------------------------------------------------------------------(
  DATA[1] = {
  
    # )------------------------------------------------------------------------(
    # )-- Checks part.                                                       --(
    # )-- Runs through every Check in a row until non-nil Table is found.    --(
    # )-- Once it finds a non-nil Table, it will ignore other checks.        --(
    # )-- In this case, it will go to Check #2 unless both conditions are    --(
    # )--  fulfilled.                                                        --(
    # )------------------------------------------------------------------------(
    :checks => {
    
      # Check #1
      1 => {
      
        # )--------------------------------------------------------------------(
        # )-- Check Conditions                                               --(
        # )-- In this case, there are 2 conditions, and conditions always    --(
        # )-- return TRUE or FALSE. TRUE being 1 and FALSE being 0.          --(
        # )-- Meaning you can have combinations of 00, 01, 10 and 11.        --(
        # )--------------------------------------------------------------------(
        :conditions => [
          "$game_troop.turn_count % 2 == 0",
          "hp_rate <= 0.75"
        ],
        
        # )--------------------------------------------------------------------(
        # )--  Remember the 00, 01, 10 and 11 from last box? They pick which --(
        # )--  Attack Table to use!                                          --(
        # )--  Looking at the conditions up there, if the turn is even and   --(
        # )--  it has less or equal to 75% of his HP, it will use Attack     --(
        # )--  Table with ID 0. But in any other case, it will return nil,   --(
        # )--  meaning it will go to the next Check.                         --(
        # )--------------------------------------------------------------------(
        :tables => {
#   Condition Result => Attack Table ID
          "00" => nil,  #false && false
          "01" => nil,  #false && true
          "10" => nil,  #true && false
          "11" => 0     #true && true
        }
      }, # end of Check #1
      
      # Check #2
      2 => {
        # )--------------------------------------------------------------------(
        # )-- This case is 3 conditions, meaning the results can be:         --(
        # )-- 000, 001, 010, 011, 100, 101, 111                              --(
        # )--------------------------------------------------------------------(
        :conditions => [
          "states.include?(5)",
          "hp_rate > 0.75",
          "$game_troop.turn_count % 2 != 0"
        ],
        # )--------------------------------------------------------------------(
        # )-- Just tables, with 3 digits this time, since 3 conditions.      --(
        # )--------------------------------------------------------------------(
        :tables => {
          "000" => 1,
          "001" => 2,
          "010" => 3,
          "011" => 3, 
          "100" => 2,
          "101" => 4,
          "111" => 3
        }
      } # end of Check #2
    }, # checks end
    
    # )------------------------------------------------------------------------(
    # )-- This is where your enemy's Attack Tables are.                      --(
    # )------------------------------------------------------------------------(
    :attack_tables => {
      # )----------------------------------------------------------------------(
      # )-- The Attack Table ID refers to this. 0 => {, 1 => {, etc..        --(
      # )-- That's which table the enemy will use to get a weighted random   --(
      # )-- from.                                                            --(
      # )----------------------------------------------------------------------(
      
      # Attack Table ID 0
      0 => {
        # )--------------------------------------------------------------------(
        # )-- Structure for this is simple.                                  --(
        # )-- Attack ID => Attack Chance in %                                --(
        # )--------------------------------------------------------------------(
        1 => 20,
        2 => 80
      },
      
      # Attack Table ID 1
      1 => {
        1 => 50,
        3 => 25,
        4 => 25
      },
      
      # Attack Table ID 2
      2 => {
        1 => 80,
        2 => 10,
        3 => 10
      },
      
      # Attack Table ID 3
      3 => {
        1 => 100
      },
      
      # Attack Table ID 4
      4 => {
        1 => 50,
        2 => 50
      }
    } # attack_tables end
  }
  
  # )==========================================================================(
  # )--- Stop setting up your enemy AI here.                                ---(
  # )==========================================================================(
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Enemy < Game_Battler
  alias :mrts_enemy_ai_CAT_make_actions :make_actions
  
  # )--------------------------------------------------------------------------(
  # )--  Alias Method: make_actions                                          --(
  # )--------------------------------------------------------------------------(
  def make_actions
    if ATDATA::DATA[@enemy_id]
      super
      return if @actions.empty?
      
      attack_table = nil
      
      # Check loop
      ATDATA::DATA[@enemy_id][:checks].each { |check_id, check_val|
        evaluation = ""
        # condition loop
        check_val[:conditions].each { |condition|
          eval(condition) ? evaluation += "1" : evaluation += "0"
        }
        table = check_val[:tables][evaluation]
        if table != nil
          attack_table = table
          break
        end
      }
      
      return if attack_table == nil
      
      # select an action from attack table
      
      roll = rand(100)+1
      skill = nil
      ATDATA::DATA[@enemy_id][:attack_tables][attack_table].each { |skill_id, chance|
        if roll > chance
          roll -= chance
        else
          skill = skill_id
          break
        end
      }
      
      @actions.each do |action|
        action.set_enemy_action_from_table(skill)
      end
    else
      mrts_enemy_ai_CAT_make_actions
    end
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Action                                                     --(
# )---------------------------------------------------------------------=======(
class Game_Action
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: set_enemy_action_from_table                             --(
  # )--------------------------------------------------------------------------(
  def set_enemy_action_from_table(action)
    if action
      set_skill(action)
    else
      clear
    end
  end
end