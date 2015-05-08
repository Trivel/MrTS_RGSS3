#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr. Trivel                                             --(
# )--     NAME:       Roguelike Saving System                                --(
# )--     CREATED:    2015-05-08                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0  - Initial script.                                                --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  One slot per game save. Can only save when returning to title.        --(
# )--  Save is deleted on death.                                             --(
# )--  Infinite save files.                                                  --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--                          Plug && Play                                  --(
# )--                                                                        --(
# )--  You can forcefully save the game with a script call (in event or      --(
# )--  common event):                                                        --(
# )--  save_game                                                             --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

# )=======---------------------------------------------------------------------(
# )-- Module: RogueSaving                                                    --(
# )---------------------------------------------------------------------=======(
module RogueSaving
  
  # )--------------------------------------------------------------------------(
  # )-- How will Save & Quit be called in menu?                              --(
  # )--------------------------------------------------------------------------(
  SAVE_AND_QUIT_TEXT = "Save & Quit"
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_System                                                     --(
# )---------------------------------------------------------------------=======(
class Game_Interpreter
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: save_game                                                --(
  # )--------------------------------------------------------------------------(
  def save_game
    DataManager::save_game($game_system.get_save_index)
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_System                                                     --(
# )---------------------------------------------------------------------=======(
class Game_System
  alias :mrts_rssy_gs_initialize :initialize
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased Method: intialize                                            --(
  # )--------------------------------------------------------------------------(
  def initialize
    mrts_rssy_gs_initialize
    @save_file = DataManager.get_empty_save
    p @save_file
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: get_save_index                                           --(
  # )--------------------------------------------------------------------------(
  def get_save_index
    @save_file
  end
end

# )=======---------------------------------------------------------------------(
# )-- Module: DataManager                                                    --(
# )---------------------------------------------------------------------=======(
module DataManager
  
  # )--------------------------------------------------------------------------(
  # )-- Overwritten Method: savefile_max                                     --(
  # )--------------------------------------------------------------------------(
  def self.savefile_max
    get_existant_saves.size
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: get_existant_saves                                       --(
  # )--------------------------------------------------------------------------(
  def self.get_existant_saves
    Dir.glob("Save*.rvdata2")
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Overwritten Method: make_filename                                    --(
  # )--------------------------------------------------------------------------(
  def self.make_filename(index)
    sprintf("Save%d.rvdata2", index)
  end
  
  class << self
    alias :mrts_rss_dm_load_header :load_header
    alias :mrts_rss_dm_load_game :load_game
    
    # )------------------------------------------------------------------------(
    # )-- Aliased Method: load_header                                        --(
    # )------------------------------------------------------------------------(
    def load_header(index)
      index = get_existant_saves[index] =~ /Save(\d+)\.rvdata2/ ? $1.to_i : nil
      mrts_rss_dm_load_header(index)
    end
    
    # )------------------------------------------------------------------------(
    # )-- Aliased Method: load_game                                          --(
    # )------------------------------------------------------------------------(
    def load_game(index)
      index = get_existant_saves[index] =~ /Save(\d+)\.rvdata2/ ? $1.to_i : nil
      mrts_rss_dm_load_game(index)
    end
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: get_empty_save                                           --(
  # )--------------------------------------------------------------------------(
  def self.get_empty_save
    get_existant_saves[savefile_max-1] =~ /Save(\d+)\.rvdata2/ ? $1.to_i+1 : 1
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Window_MenuCommand                                              --(
# )---------------------------------------------------------------------=======(
class Window_MenuCommand < Window_Command
  
  # )--------------------------------------------------------------------------(
  # )-- Overwritten Method: add_save_command                                 --(
  # )--------------------------------------------------------------------------(
  def add_save_command
    add_command(RogueSaving::SAVE_AND_QUIT_TEXT, :save, save_enabled)
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Overwritten Method: add_game_end_command                             --(
  # )--------------------------------------------------------------------------(
  def add_game_end_command
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Scene_Menu                                                      --(
# )---------------------------------------------------------------------=======(
class Scene_Menu < Scene_MenuBase
  
  # )--------------------------------------------------------------------------(
  # )-- Overwritten Method: command_save                                     --(
  # )--------------------------------------------------------------------------(
  def command_save
    DataManager::save_game($game_system.get_save_index)
    fadeout_all
    SceneManager.goto(Scene_Title)
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Scene_Gameover                                                  --(
# )---------------------------------------------------------------------=======(
class Scene_Gameover < Scene_Base
  alias :mrts_rss_sg_goto_title :goto_title
  
  # )--------------------------------------------------------------------------(
  # )-- Aliased Method: goto_title                                           --(
  # )--------------------------------------------------------------------------(
  def goto_title
    DataManager::delete_save_file($game_system.get_save_index)
    mrts_rss_sg_goto_title
  end
end