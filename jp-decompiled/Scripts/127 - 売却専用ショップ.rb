class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 売却ショップの処理
  #--------------------------------------------------------------------------
  def only_sell_shop(sell_rate = 50)
    return if $game_party.in_battle
    SceneManager.call(Scene_Sell_Shop)
    SceneManager.scene.prepare(sell_rate)
    Fiber.yield
  end
end

class Window_Sell_ShopCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(window_width)
    @window_width = window_width
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopSell,   :sell)
    add_command(Vocab::ShopCancel, :cancel)
  end
end

class Scene_Sell_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 準備
  #--------------------------------------------------------------------------
  def prepare(sell_rate)
    @sell_rate = sell_rate
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_gold_window
    create_command_window
    create_dummy_window
    create_number_window
    create_status_window
    create_category_window
    create_sell_window
  end
  #--------------------------------------------------------------------------
  # ● ゴールドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_Sell_ShopCommand.new(@gold_window.x)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:sell,   method(:command_sell))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● ダミーウィンドウの作成
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● 個数入力ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_number_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @number_window = Window_ShopNumber.new(0, wy, wh)
    @number_window.viewport = @viewport
    @number_window.hide
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    wx = @number_window.width
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @status_window = Window_ShopStatus.new(wx, wy, ww, wh)
    @status_window.viewport = @viewport
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ● カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @dummy_window.y
    @category_window.hide.deactivate
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 売却ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_sell_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @sell_window = Window_ShopSell.new(0, wy, Graphics.width, wh)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.hide
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
    @category_window.item_window = @sell_window
  end
  #--------------------------------------------------------------------------
  # ● 売却ウィンドウのアクティブ化
  #--------------------------------------------------------------------------
  def activate_sell_window
    @category_window.show
    @sell_window.refresh
    @sell_window.show.activate
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ● コマンド［売却する］
  #--------------------------------------------------------------------------
  def command_sell
    @dummy_window.hide
    @category_window.show.activate
    @sell_window.show
    @sell_window.unselect
    @sell_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok
    activate_sell_window
    @sell_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ［キャンセル］
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    @dummy_window.show
    @category_window.hide
    @sell_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 売却［決定］
  #--------------------------------------------------------------------------
  def on_sell_ok
    @item = @sell_window.item
    @status_window.item = @item
    @category_window.hide
    @sell_window.hide
    @number_window.set(@item, max_sell, selling_price, currency_unit)
    @number_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● 売却［キャンセル］
  #--------------------------------------------------------------------------
  def on_sell_cancel
    @sell_window.unselect
    @category_window.activate
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 個数入力［決定］
  #--------------------------------------------------------------------------
  def on_number_ok
    Sound.play_shop
    do_sell(@number_window.number)
    end_number_input
    @gold_window.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 個数入力［キャンセル］
  #--------------------------------------------------------------------------
  def on_number_cancel
    Sound.play_cancel
    end_number_input
  end
  #--------------------------------------------------------------------------
  # ● 売却の実行
  #--------------------------------------------------------------------------
  def do_sell(number)
    $game_party.gain_gold(number * selling_price)
    $game_party.lose_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # ● 個数入力の終了
  #--------------------------------------------------------------------------
  def end_number_input
    @number_window.hide
    activate_sell_window 
  end
  #--------------------------------------------------------------------------
  # ● 最大売却可能個数の取得
  #--------------------------------------------------------------------------
  def max_sell
    $game_party.item_number(@item)
  end
  #--------------------------------------------------------------------------
  # ● 所持金の取得
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
  #--------------------------------------------------------------------------
  # ● 通貨単位の取得
  #--------------------------------------------------------------------------
  def currency_unit
    @gold_window.currency_unit
  end
  #--------------------------------------------------------------------------
  # ● 売値の取得
  #--------------------------------------------------------------------------
  def selling_price
    @item.price * @sell_rate / 100
  end
end