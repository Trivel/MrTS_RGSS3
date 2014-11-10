#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Multi Layer Boss HP Bar                                --(
# )--     CREATED:    2014-10-31                                             --(
# )--     VERSION:    1.2                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0  - Initial script.                                                --(
# )--  1.1  - Crash fix.                                                     --(
# )--  1.1a - Small code change.                                             --(
# )--  1.2  - Boss Health bar is now in it's own class. Added a switch to    --(
# )--          hide boss health bar.                                         --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Boss can now have a multi-layer health bar. Meaning it won't just go  --(
# )--  to empty, the layers will deplete 1 by 1 until the bar is completely  --(
# )--  empty.                                                                --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  #1 Set up images carefully:                                           --(
# )--  Place 7 images in Graphics/System folder with these names -           --(
# )--  boss_hp_bar_borders - this is the frame of the health bar             --(
# )--  boss_hp_bar_bcg - background of health bar, this is what player will  --(
# )--    as the last layer is depleting.                                     --(
# )--  boss_hp_bar1   \                                                      --(
# )--  boss_hp_bar2    \                                                     --(
# )--  boss_hp_bar3     - Health Layers.                                     --(
# )--  boss_hp_bar4    /                                                     --(
# )--  boss_hp_bar5   /                                                      --(
# )--                                                                        --(
# )--  #2 Find your boss enemy and add this note tag to it:                  --(
# )--  <boss: X> - X is how many health layers the boss will have.           --(
# )--  In the video example I used <boss: 10>                                --(
# )--                                                                        --(
# )--  #3 Set up the BHP module below to fit your HP bar's needs.            --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

module BHP
  # )--------------------------------------------------------------------------(
  # )--  Because HP bar is not sometimes from the start of the image to the  --(
  # )--  end of it, you might need to offset some unneeded pixels.           --(
  # )--  The numbers here are taken from the video example, HP bar there is  --(
  # )--  far from both sides of the image.                                   --( 
  # )--------------------------------------------------------------------------(
  
  # )--------------------------------------------------------------------------(
  # )-- Offset from the left in pixels                                       --(
  # )---------------------------------------------------------------------------
  FILL_X_OFFSET_LEFT = 93
  
  # )--------------------------------------------------------------------------(
  # )-- Offset from the right in pixels                                      --(
  # )---------------------------------------------------------------------------
  FILL_X_OFFSET_RIGHT = 76
  
  
  # )--------------------------------------------------------------------------(
  # )--  By default the text that shows how many layers are left is shown    --(
  # )--  in the middle of the HP bar. You can offset it's X position and Y   --(
  # )--  positions. Number is in pixels.                                     --(
  # )--------------------------------------------------------------------------(
  TIMES_X_OFFSET = 230
  TIMES_Y_OFFSET = 0
  
  # )--------------------------------------------------------------------------(
  # )--  How low should the HP bar be                                        --(
  # )--------------------------------------------------------------------------(
  BAR_Y = 40
  
  # )--------------------------------------------------------------------------(
  # )--  Switch to show/hide the boss HP bar. In case of cutscenes in battle.--(
  # )--  Set it to 0 if you do not wish to use this.                         --(
  # )--------------------------------------------------------------------------(
  HIDE_SWITCH = 5
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class Game_Enemy < Game_Battler
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :bosses_initialize :initialize
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: initialize                                                   --(
  # )--------------------------------------------------------------------------(
  def initialize(index, enemy_id)
    bosses_initialize(index, enemy_id)
    enemy = $data_enemies[@enemy_id]
    @boss = enemy.boss
    @boss_bars = enemy.boss_bars
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: boss                                                    --(
  # )--------------------------------------------------------------------------(
  def boss
    @boss
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: boss_bars                                               --(
  # )--------------------------------------------------------------------------(
  def boss_bars
    @boss_bars
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Temp                                                       --(
# )---------------------------------------------------------------------=======(
class Game_Temp
  
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :bosses_initialize :initialize
  
  # )--------------------------------------------------------------------------(
  # )--  Public Instance Variables                                           --(
  # )--------------------------------------------------------------------------(
  attr_accessor :bhp_frame
  attr_accessor :bhp_background
  attr_accessor :bhp_fill
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: initialize                                                   --(
  # )--------------------------------------------------------------------------(
  def initialize
    bosses_initialize
    @bhp_frame = Cache.system("boss_hp_bar_borders")
    @bhp_background = Cache.system("boss_hp_bar_bcg")
    @bhp_fill = []
    5.times { |time|
      @bhp_fill.push(Cache.system("boss_hp_bar#{time+1}"))
    }
  end
  
end # Game_Temp

# )=======---------------------------------------------------------------------(
# )-- Class: Sprite_Boss_bar                                                 --(
# )---------------------------------------------------------------------=======(
class Sprite_Boss_bar
  
  # )--------------------------------------------------------------------------(
  # )--  Method: initialize                                                  --(
  # )--------------------------------------------------------------------------(
  def initialize
    @boss = $game_troop.members.find { |e| e.boss }
    return unless @boss
    
    @current_bar = @boss.boss_bars
    @confusing_bar = -1
    @per_bar = 1.0 / @current_bar
    @current_rate = @boss.hp_rate
    
    @bhpb_frame = Sprite.new(@viewport2)
    @bhpb_frame.bitmap = $game_temp.bhp_frame
    @bhpb_frame.x = Graphics.width/2 - @bhpb_frame.bitmap.width/2
    @bhpb_frame.y = BHP::BAR_Y
    @bhpb_frame.z = @current_bar + 1
    
    @bhpb_bcg = Sprite.new(@viewport2)
    @bhpb_bcg.bitmap = $game_temp.bhp_background
    @bhpb_bcg.x = Graphics.width/2 - @bhpb_bcg.bitmap.width/2
    @bhpb_bcg.y = @bhpb_frame.y
    @bhpb_bcg.z = 0
    
    @bhpb_bars = []
    @current_bar.times do |bar|
      tmp = Sprite.new(@viewport2)
      tmp.bitmap = $game_temp.bhp_fill[bar % 5]
      tmp.x = Graphics.width/2 - tmp.bitmap.width/2
      tmp.y = @bhpb_frame.y
      tmp.z = @current_bar-bar
      @bhpb_bars.push(tmp)
    end
    
    @bhpb_x = Sprite.new(@viewport2)
    @bhpb_x.bitmap = Bitmap.new(@bhpb_frame.width, @bhpb_frame.height)
    @bhpb_x.x = Graphics.width/2 - @bhpb_x.bitmap.width/2
    @bhpb_x.y = @bhpb_frame.y + BHP::TIMES_Y_OFFSET
    @bhpb_x.z = @current_bar + 2
    txt = "x" + @current_bar.to_s
    @bhpb_x.bitmap.draw_text(BHP::TIMES_X_OFFSET, 0, @bhpb_x.width, @bhpb_x.height, txt)
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Method: update                                                      --(
  # )--------------------------------------------------------------------------(
  def update
    return unless @bhpb_frame && @bhpb_bcg && @bhpb_bars
    
    @bhpb_frame.update
    @bhpb_bcg.update
    
    i = 0
    @bhpb_bars.each { |b|
      max_rate = (@current_bar - i).to_f * @per_bar
      empty_rate = max_rate - @per_bar
      if @current_rate >= max_rate
        b.src_rect.width = b.bitmap.width
        b.wave_amp = 0
      elsif @current_rate < empty_rate
        b.src_rect.width = 0.0
        b.wave_amp = 0
      else
        max_rate = (max_rate - empty_rate) - (@current_rate - empty_rate)        
        max_rate = 1.0 - (max_rate * 100.0 / @per_bar) / 100.0
        
        b.src_rect.width = ((b.bitmap.width - BHP::FILL_X_OFFSET_LEFT - BHP::FILL_X_OFFSET_RIGHT) * max_rate) + BHP::FILL_X_OFFSET_LEFT
      end
      b.update
      
      i += 1
    }
    
    if @current_rate != @boss.hp_rate
      @current_rate -= 0.0045 if @current_rate > @boss.hp_rate
      @current_rate += 0.0045 if @current_rate < @boss.hp_rate
    end
    
    if @confusing_bar != (@current_rate / @per_bar).ceil
      @confusing_bar = (@current_rate / @per_bar).ceil
      txt = "x" + @confusing_bar.to_s
      @bhpb_x.bitmap.clear
      @bhpb_x.bitmap.draw_text(BHP::TIMES_X_OFFSET, 0, @bhpb_x.width, @bhpb_x.height, txt)
    end
    
    @bhpb_x.update
    
    return if BHP::HIDE_SWITCH == 0 || ($game_switches[BHP::HIDE_SWITCH] && @bhpb_frame.opacity == 0) || (!$game_switches[BHP::HIDE_SWITCH] && @bhpb_frame.opacity == 255)
    if $game_switches[BHP::HIDE_SWITCH] && @bhpb_frame.opacity != 0
      @bhpb_frame.opacity = 0
      @bhpb_bcg.opacity = 0 
      @bhpb_bars.each { |b|  b.opacity = 0  }
      @bhpb_x.opacity = 0
    elsif !$game_switches[BHP::HIDE_SWITCH] && @bhpb_frame.opacity != 255
      @bhpb_frame.opacity = 255
      @bhpb_bcg.opacity = 255
      @bhpb_bars.each { |b|  b.opacity = 255  }
      @bhpb_x.opacity = 255
    end
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Method: dispose                                                     --(
  # )--------------------------------------------------------------------------(
  def dispose
    @bhpb_frame.dispose if @bhpb_frame
    @bhpb_bcg.dispose if @bhpb_bcg
    @bhpb_bars.each { |b|  b.dispose if b }
    @bhpb_x.dispose if @bhpb_x
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Spriteset_Battle                                                --(
# )---------------------------------------------------------------------=======(
class Spriteset_Battle
  
  # )--------------------------------------------------------------------------(
  # )--  Aliased methods                                                     --(
  # )--------------------------------------------------------------------------(
  alias :bosses_initialize :initialize
  alias :bosses_update :update
  alias :bosses_dispose :dispose
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: initialize                                                   --(
  # )--------------------------------------------------------------------------(
  def initialize
    create_boss_hp_bar 
    bosses_initialize   
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: update                                                       --(
  # )--------------------------------------------------------------------------(
  def update
    bosses_update
    update_boss_hp_bar
  end
  
  # )--------------------------------------------------------------------------(
  # )--  Alias: dispose                                                      --(
  # )--------------------------------------------------------------------------(
  def dispose
    dispose_boss_hp_bar
    bosses_dispose    
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: create_boss_hp_bar                                      --(
  # )--------------------------------------------------------------------------(
  def create_boss_hp_bar
    @boss_hp_bar = Sprite_Boss_bar.new
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: update_boss_hp_bar                                      --(
  # )--------------------------------------------------------------------------(
  def update_boss_hp_bar
    return unless @boss_hp_bar
    @boss_hp_bar.update
  end
  
  # )--------------------------------------------------------------------------(
  # )--  New Method: dispose_boss_hp_bar                                     --(
  # )--------------------------------------------------------------------------(
  def dispose_boss_hp_bar
    return unless @boss_hp_bar
    @boss_hp_bar.dispose    
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: RPG::Enemy                                                      --(
# )---------------------------------------------------------------------=======(
class RPG::Enemy < RPG::BaseItem
  
  # )--------------------------------------------------------------------------(
  # )--  Public Instance Variables                                           --(
  # )--------------------------------------------------------------------------(
  attr_accessor :boss
  attr_accessor :boss_bars
  
  # )--------------------------------------------------------------------------(
  # )-- Method: parse_bosses                                                 --(
  # )--------------------------------------------------------------------------(
  def parse_bosses
    @boss_bars = note =~ /<boss:[ ]*(\d+)>/i ? $1.to_i : nil
    @boss = @boss_bars ? true : false
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
    alias :bosses_game_objects    :create_game_objects
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: create_game_objects                                           --(
  # )--------------------------------------------------------------------------(
  def self.create_game_objects
    bosses_game_objects
    parse_bosses
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: self.parse_bosses                                        --(
  # )--------------------------------------------------------------------------(
  def self.parse_bosses
    enemies = $data_enemies
    for enemy in enemies
      next if enemy.nil?
      enemy.parse_bosses
    end
  end
end
