#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr. Trivel                                             --(
# )--     NAME:       Shop Items in Stacks                                  --(
# )--     CREATED:    2015-10-26                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )--                         VERSION HISTORY                                --(
# )--  1.0  - Initial script.                                                --(
#===============================================================================
# )--                          DESCRIPTION                                   --(
# )--  Allows buying special items which give multiples. E.g. "Arrows (x64)  --(
# )--  item would give 64 arrows.                                            --(
#===============================================================================
# )--                          INSTRUCTIONS                                  --(
# )--  Use the following tag in item note fields:                            --(
# )--  <stack: type, ID, Amount>                                             --(
# )--  E.g. <stack: i, 17, 64>                                               --(
# )--  The tag above would mean if you bought item which had, you'd get 64   --(
# )--  of item with ID 17 instead.                                           --(
# )--  type - i, a, w (item, armor, weapon)                                  --(
# )--  ID - item, armor or weapon ID                                         --(
# )--  Amount - how many will it give                                        --(
#===============================================================================
# )--                          LICENSE INFO                                  --(
# )--  Free for non-commercial & commercial games if credit was given to     --(
# )--  Mr Trivel.                                                            --(
# )----------------------------------------------------------------------------(
#===============================================================================

# )----------------------------------------------------------------------------(
# )-- Class: RPG::BaseItem                                                   --(
# )----------------------------------------------------------------------------(
class RPG::BaseItem
  
  # )--------------------------------------------------------------------------(
  # )-- Public Instance Variables                                            --(
  # )--------------------------------------------------------------------------(
  attr_accessor :stack_type
  attr_accessor :stack_item
  attr_accessor :stack_amount
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: is_stacked?                                              --(
  # )--------------------------------------------------------------------------(
  def is_stacked?
    @is_stacked ||= self.note =~ /<stack:[ ]*([iaw])[,][ ]*(\d+),[ ]*(\d+)>/i ? true : false
    if  @is_stacked && (!@stack_type || !@stack_item || !@stack_amount)
      @stack_type = $1
      @stack_item = $2.to_i
      @stack_amount = $3.to_i
    end
    @is_stacked
  end
  
end
# )----------------------------------------------------------------------------(
# )-- Class: Scene_Shop                                                      --(
# )----------------------------------------------------------------------------(
class Scene_Shop < Scene_MenuBase
  alias :mrts_siis_do_buy :do_buy
  
  # )--------------------------------------------------------------------------(
  # )-- Alias Method: do_buy                                                 --(
  # )--------------------------------------------------------------------------(
  def do_buy(number)
    mrts_siis_do_buy(number)
    if @item.is_stacked?
      $game_party.lose_item(@item, number)
      new_item = nil
      case @item.stack_type
      when "i"
        new_item = $data_items[@item.stack_item]
      when "a"
        new_item = $data_armors[@item.stack_item]
      when "w"
        new_item = $data_weapons[@item.stack_item]
      end
      
      $game_party.gain_item(new_item, number*@item.stack_amount)
    end
  end
end
