# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr. Trivel                                             --(
# )--     NAME:       Variable Shops                                         --(
# )--     CREATED:    2014-12-17                                             --(
# )--     VERSION:    1.1                                                    --(
# )----------------------------------------------------------------------------(
# )--                         VERSION HISTORY                                --(
# )--  v1.1 - Bugfix -- max buyable amout was defaulting to 99.              --(
# )--  v1.0 - Initial release.                                               --(
# )----------------------------------------------------------------------------(
# )--                          DESCRIPTION                                   --(
# )--  Allows shops to have variables as currencies. Shops can take multiple --(
# )--  currencies.                                                           --(
# )----------------------------------------------------------------------------(
# )--                          INSTRUCTIONS                                  --(
# )--  Set up module belowo and call the shop by using                       --(
# )--   call_var_shop(ID, [CURRENCY_IDs])                                    --(
# )--  ID being the Shop ID from the module below.                           --(
# )--  CURRENCY_IDs being what currencies does the shop take.                --(
# )--  Example:                                                              --(
# )--   call_var_shop(2, [1, 2, 5])                                          --(
# )--  That would mean to call a shop of ID 2 which takes currencies 1, 2    --(
# )--  and 5.                                                                --(
# )----------------------------------------------------------------------------(
# )--                          LICENSE INFO                                  --(
# )--    Free for non-commercial and commercial games if credit was          --(
# )--    given to Mr. Trivel.                                                --(
# )----------------------------------------------------------------------------(

module Shop_Currencies
  CURRENCIES = {
  # )--------------------------------------------------------------------------(
  # )-- Setup your currencies here                                           --(
  # )--------------------------------------------------------------------------(
  # )--  ID => [VARIABLE_ID, ICON_INDEX]                                     --(
  # )--------------------------------------------------------------------------(
    1 => [10, 15],
    2 => [11, 20],
    3 => [12, 30],
    4 => [13, 45],
    5 => [14, 44],
    6 => [15, 59]
  }
  
  SHOPS = {
  # )--------------------------------------------------------------------------(
  # )--  Setup your shops here.                                              --(
  # )--------------------------------------------------------------------------(
  # )--  ID => [                                                             --(
  # )--        [ITEM],                                                       --(
  # )--        [ITEM],                                                       --(
  # )--        ],                                                            --(
  # )--------------------------------------------------------------------------(
  # )--  ITEM is:                                                            --(
  # )--  TYPE, ID, [[CURRENCY_ID, AMOUNT], [ANOTHER_CURRENCY_ID, AMOUNT]]    --(
  # )--  TYPE : :item or :armor or :weapon                                   --(
  # )--------------------------------------------------------------------------(
    1 => [
         [:item, 1, [[1, 3], [2, 4]]],
         [:item, 2, [[1,10], [3, 1]]]
         ],
    2 => [
         [:armor, 1, [[1, 1]]]
         ]
  }
end

# )=======---------------------------------------------------------------------(
# )-- Class: Game_Interpreter                                                --(
# )-------------------------------------------------------------------=========(
class Game_Interpreter
  
  # )--------------------------------------------------------------------------(
  # )-- Method: call_var_shop                                                --(
  # )--------------------------------------------------------------------------(
  def call_var_shop(id, curr)
    SceneManager.call(Scene_Variable_Shop)
    SceneManager.scene.prepare(id, curr)
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Scene_Variable_Shop                                             --(
# )-------------------------------------------------------------------=========(
class Scene_Variable_Shop < Scene_Shop
  
  # )--------------------------------------------------------------------------(
  # )-- Method: prepare                                                      --(
  # )--------------------------------------------------------------------------(
  def prepare(id, currencies)
    @shop_id = id
    @goods = Shop_Currencies::SHOPS[@shop_id]
    @currencies = currencies
    @purchase_only = true
  end
  
  def create_gold_window
  # )--------------------------------------------------------------------------(
  # )-- Method: create_gold_window                                           --(
  # )--------------------------------------------------------------------------(
    @gold_window = Window_Gold_Currencies.new(@currencies)
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end

  def create_command_window
  # )--------------------------------------------------------------------------(
  # )-- Method: create_command_window                                        --(
  # )--------------------------------------------------------------------------(
    @command_window = Window_ShopCommand_Currencies.new(@gold_window.x, @purchase_only)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Method: create_number_window                                         --(
  # )--------------------------------------------------------------------------(
  def create_number_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @number_window = Window_ShopNumber_Currencies.new(0, wy, wh)
    @number_window.viewport = @viewport
    @number_window.hide
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Method: create_buy_window                                            --(
  # )--------------------------------------------------------------------------(
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @buy_window = Window_ShopBuy_Currency.new(0, wy, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Method: do_buy                                                       --(
  # )--------------------------------------------------------------------------(
  def do_buy(number)
    price = buying_price.collect { |p| [p[0], p[1] * number] }
    price.each { |p| $game_variables[Shop_Currencies::CURRENCIES[p[0]][0]] -= p[1] }
    $game_party.gain_item(@item, number)
  end
  

  # )--------------------------------------------------------------------------(
  # )-- Method: max_buy                                                      --(
  # )--------------------------------------------------------------------------(
  def max_buy
    max = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    available = 99
    @buy_window.price(@item).each { |p| 
      math = ($game_variables[Shop_Currencies::CURRENCIES[p[0]][0]] / p[1]).floor
      available = math if available > math
    }
    return available if max >= available
    return max
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Method: money                                                        --(
  # )--------------------------------------------------------------------------(
  def money
    0
  end

  # )--------------------------------------------------------------------------(
  # )-- Method: currency_unit                                                --(
  # )--------------------------------------------------------------------------(
  def currency_unit
    "g"
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Window_Gold_Currencies                                          --(
# )-------------------------------------------------------------------=========(
class Window_Gold_Currencies < Window_Base

  # )--------------------------------------------------------------------------(
  # )-- Method: initialize                                                   --(
  # )--------------------------------------------------------------------------(
  def initialize(currencies)
    @currencies = currencies
    super(0, 0, window_width, fitting_height(1))
    refresh
  end

  # )--------------------------------------------------------------------------(
  # )-- Method: window_width                                                 --(
  # )--------------------------------------------------------------------------(
  def window_width
    return 240
  end

  # )--------------------------------------------------------------------------(
  # )-- Method: refresh                                                      --(
  # )--------------------------------------------------------------------------(
  def refresh
    contents.clear
    @currencies.size.times { |c| 
      where = contents.width/@currencies.size*c
      draw_icon(Shop_Currencies::CURRENCIES[@currencies[c]][1], where, 0)
      draw_text(where + 25, 0, contents.width/@currencies.size-25, line_height, $game_variables[Shop_Currencies::CURRENCIES[@currencies[c]][0]])
    }
  end

  # )--------------------------------------------------------------------------(
  # )-- Method: open                                                         --(
  # )--------------------------------------------------------------------------(
  def open
    refresh
    super
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Window_ShopCommand_Currencies                                   --(
# )-------------------------------------------------------------------=========(
class Window_ShopCommand_Currencies < Window_ShopCommand
  # )--------------------------------------------------------------------------(
  # )-- Method: make_command_list                                            --(
  # )--------------------------------------------------------------------------(
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopCancel, :cancel)
  end
  # )--------------------------------------------------------------------------(
  # )-- Method: col_max                                                      --(
  # )--------------------------------------------------------------------------(
  def col_max
    return 2
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Window_ShopBuy_Currency                                         --(
# )-------------------------------------------------------------------=========(
class Window_ShopBuy_Currency < Window_ShopBuy

  # )--------------------------------------------------------------------------(
  # )-- Method: enable?                                                      --(
  # )--------------------------------------------------------------------------(
  def enable?(item)
    item && price(item).all? { |p| $game_variables[Shop_Currencies::CURRENCIES[p[0]][0]] >= p[1] } && !$game_party.item_max?(item)
  end

  # )--------------------------------------------------------------------------(
  # )-- Method: make_item_list                                               --(
  # )--------------------------------------------------------------------------(
  def make_item_list
    @data = []
    @price = {}
    @shop_goods.each do |goods|
      case goods[0]
      when :item;  item = $data_items[goods[1]]
      when :weapon;  item = $data_weapons[goods[1]]
      when :armor;  item = $data_armors[goods[1]]
      end
      if item
        @data.push(item)
        @price[item] = goods[2]
      end
    end
  end

  # )--------------------------------------------------------------------------(
  # )-- Method: draw_item                                                    --(
  # )--------------------------------------------------------------------------(
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    w = 0
    price(item).each { |p|
      n_rect = rect
      n_rect.width -= w
      draw_text(n_rect, p[1], 2)
      draw_icon(Shop_Currencies::CURRENCIES[p[0]][1], n_rect.width-50, n_rect.y)
      w += 50
    }
  end
end

# )=======---------------------------------------------------------------------(
# )-- Class: Window_ShopNumber_Currencies                                    --(
# )-------------------------------------------------------------------=========(
class Window_ShopNumber_Currencies < Window_ShopNumber

  # )--------------------------------------------------------------------------(
  # )-- Method: draw_total_price                                             --(
  # )--------------------------------------------------------------------------(
  def draw_total_price
    width = contents_width - 8
    total_price = @price.collect { |p| [p[0], p[1] * @number] }
    w = 0
    total_price.each { |p|
      txtw = text_size(p[1]).width
      draw_text(4, price_y, width-w, line_height, p[1], 2)
      draw_icon(Shop_Currencies::CURRENCIES[p[0]][1], width-txtw-24-w, price_y)
      w += txtw+28
    }
  end
end
