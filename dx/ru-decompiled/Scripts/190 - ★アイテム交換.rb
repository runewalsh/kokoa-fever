#******************************************************************************
#
#    ＊ アイテム合成
#
#  --------------------------------------------------------------------------
#    バージョン ：  1.0.3
#    対      応 ：  RPGツクールVX Ace : RGSS3
#    制  作  者 ：  ＣＡＣＡＯ
#    配  布  元 ：  http://cacaosoft.web.fc2.com/
#  --------------------------------------------------------------------------
#   == 概    要 ==
#
#   ： 所持品を別のアイテムと交換する機能を追加します。
#
#  --------------------------------------------------------------------------
#   == 使用方法 ==
#
#    ★ アイテム合成の起動
#     start_item_make(book_id)
#
#    ★ レシピを隠す
#     CAO::ItemMake.activate_recipe(recipe_id)    # レシピ 有効化
#     CAO::ItemMake.deactivate_recipe(recipe_id)  # レシピ 無効化
#     CAO::ItemMake.activate_book(book_id)        # ブック内のレシピ 有効化
#     CAO::ItemMake.deactivate_book(book_id)      # ブック内のレシピ 無効化
#
#    ★ 合成した回数の取得
#     $game_imrecipes[recipe_id].count
#
#
#******************************************************************************


#==============================================================================
# ◆ 設定項目
#==============================================================================
module CAO
module ItemMake
  
  #--------------------------------------------------------------------------
  # ◇ ブック(カテゴリ)の名称を表示
  #--------------------------------------------------------------------------
  DISPLAY_BOOKNAME = false
  
  #--------------------------------------------------------------------------
  # ◇ レシピの番号を表示
  #--------------------------------------------------------------------------
  DISPLAY_NUBER = true
  
  #--------------------------------------------------------------------------
  # ◇ 増やすアイテムを上に表示
  #--------------------------------------------------------------------------
  PLUS_GA_UE = true
  
  #--------------------------------------------------------------------------
  # ◇ 隠し属性の設定
  #--------------------------------------------------------------------------
  ICON_SECRET = 16
  VACAB_SECRET_NAME   = " ---------------"
  VACAB_SECRET_PRICE  = "??????"
  VACAB_SECRET_NUMBER = "??"
  VACAB_SECRET_HELP   = ""
  
  #--------------------------------------------------------------------------
  # ◇ 用語設定
  #--------------------------------------------------------------------------
  VOCAB_GOLD = "所持金"
  VOCAB_PRICE = "価格"
  VOCAB_PLUS_ITEM = "増やすアイテム"
  VOCAB_MINUS_ITEM = "減らすアイテム"
  
  #--------------------------------------------------------------------------
  # ◇ デフォルトの背景画像
  #--------------------------------------------------------------------------
  FILE_BACKGROUND = ""
  FILE_FOREGROUND = ""
  
end # module ItemMake
end # module CAO


#/////////////////////////////////////////////////////////////////////////////#
#                                                                             #
#                下記のスクリプトを変更する必要はありません。                 #
#                                                                             #
#/////////////////////////////////////////////////////////////////////////////#


module CAO::ItemMake
  FILE_RECIPE = "imRecipes.rvdata2"
  FILE_BOOK = "imBooks.rvdata2"
  VOCAB_RECIPE_NUMBER = "%03d:"
  VOCAB_QUANTITY = "%1$02d(%2$02d)"
end

class << DataManager
  #--------------------------------------------------------------------------
  # ○ 通常のデータベースをロード
  #--------------------------------------------------------------------------
  alias _cao_item_make_load_normal_database load_normal_database
  def load_normal_database
    _cao_item_make_load_normal_database
    $data_imrecipes = load_data("Data/#{CAO::ItemMake::FILE_RECIPE}")
    $data_imbooks   = load_data("Data/#{CAO::ItemMake::FILE_BOOK}")
  end
  #--------------------------------------------------------------------------
  # ○ 各種ゲームオブジェクトの作成
  #--------------------------------------------------------------------------
  alias _cao_item_make_create_game_objects create_game_objects
  def create_game_objects
    _cao_item_make_create_game_objects
    $game_imrecipes = Game_ItemMakeRecipes.new
  end
  #--------------------------------------------------------------------------
  # ○ セーブ内容の作成
  #--------------------------------------------------------------------------
  alias _cao_item_make_make_save_contents make_save_contents
  def make_save_contents
    contents = _cao_item_make_make_save_contents
    contents[:imrecipes] = $game_imrecipes
    contents
  end
  #--------------------------------------------------------------------------
  # ○ セーブ内容の展開
  #--------------------------------------------------------------------------
  alias _cao_item_make_extract_save_contents extract_save_contents
  def extract_save_contents(contents)
    _cao_item_make_extract_save_contents(contents)
    if contents[:imrecipes]
      $game_imrecipes = contents[:imrecipes]
    else
      $game_imrecipes.init
    end
  end
  #--------------------------------------------------------------------------
  # ○ ニューゲームのセットアップ
  #--------------------------------------------------------------------------
  alias _cao_item_make_setup_new_game setup_new_game
  def setup_new_game
    _cao_item_make_setup_new_game
    $game_imrecipes.init
  end
end

class CustomizeError < Exception; end
module RPG::ItemMake; end

class RPG::ItemMake::Item
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  CLASS_ID_TABLE = {'i' => 0, 'I' => 0, 'w' => 1, 'W' => 1, 'a' => 2, 'A' => 2 }
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :class_id                 # アイテムの種類
  attr_accessor :item_id                  # アイテムのＩＤ
  attr_accessor :quantity                 # アイテムの個数
  #--------------------------------------------------------------------------
  # ● クラス判定
  #--------------------------------------------------------------------------
  def is_item?;   @class_id == 0; end     # 
  def is_weapon?; @class_id == 1; end     # 
  def is_armor?;  @class_id == 2; end     # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(param)
    case param
    when Integer
      case param
      when 1001..3999
        @class_id = param / 1000 - 1
        @item_id = param % 1000
        @quantity = 1
      when 100101..399999
        @class_id = param / 100000 - 1
        @item_id = param % 100000 / 100
        @quantity = param % 100
      else
        fail(param)
      end
    when String
      if param[/([IWA])(\d+)(?::(\d+))?/i]
        @class_id = CLASS_ID_TABLE[$1]
        @item_id = $2.to_i
        @quantity = $3 ? $3.to_i : 1
      else
        fail(param)
      end
    else
      raise "must not happen"
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの取得
  #--------------------------------------------------------------------------
  def object
    return $data_items[@item_id]   if is_item?
    return $data_weapons[@item_id] if is_weapon?
    return $data_armors[@item_id]  if is_armor?
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def fail(param)
    Kernel.raise(CustomizeError,
      "アイテムの定義が不正です。\n\n"\
      "スクリプト: #{$RGSS_SCRIPTS[__FILE__[/(\d+)/,1].to_i][1]}\n"\
      "パラメータ: #{param}", "")
  end
end

class RPG::ItemMake::Recipe
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :id                       # ID
  attr_accessor :name                     # 名前
  attr_accessor :icon_index               # アイコン番号
  attr_accessor :description              # 説明
  attr_accessor :price                    # 価格
  attr_accessor :plus_items               # 増やすアイテム
  attr_accessor :minus_items              # 減らすアイテム
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @id = 0
    @name = ""
    @icon_index = 0
    @description = ""
    @price = 0
    @plus_items = []
    @minus_items = []
  end
end

class RPG::ItemMake::Book
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :id                       # ID
  attr_accessor :name                     # 名前
  attr_accessor :icon_index               # アイコン番号
  attr_accessor :list                     # レシピの配列
  attr_accessor :display_price            # 価格を表示
  attr_accessor :plus_number              # 増加アイテムの表示数
  attr_accessor :minus_number             # 減少アイテムの表示数
  attr_accessor :plus_name                # 増やすアイテムの項目名
  attr_accessor :minus_name               # 減らすアイテムの項目名
  attr_accessor :background_name          # 背景画像のファイル名
  attr_accessor :foreground_name          # 前景画像のファイル名
  attr_accessor :visible_window           # ウィンドウの可視状態
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @id = 0
    @name = ""
    @icon_index = 0
    @list = []
    @display_price = true
    @plus_number = 4
    @minus_number = 4
    @fixed_display = true
    @plus_name = ""
    @minus_name = ""
    @background_name = ""
    @foreground_name = ""
    @visible_window = true
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def recipes
    return @list.map {|id| $game_imrecipes[id] }
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def each
    return unless block_given?
    @list.each {|id| yield $game_imrecipes[id] }
  end
end

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :item_make_books          # アイテム合成 ブックリスト
  attr_accessor :item_make_simplicial     # アイテム合成 カテゴリ表示の有無
end

class Game_ItemMakeRecipes
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def init
    @data.clear
    (1...$data_imrecipes.size).each {|i| @data[i] = Game_ItemMakeRecipe.new(i) }
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def [](id)
    return @data[id]
  end
end

class Game_ItemMakeRecipe
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :id                       # 
  attr_accessor :new                      # 新しい
  attr_accessor :secret                   # 隠し属性
  attr_accessor :count                    # 合成回数
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def initialize(id)
    @id = id
    @new = true
    @secret = false
    @count = 0
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def recipe
    return $data_imrecipes[@id]
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def plus_items
    return self.recipe.plus_items
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def minus_items
    return self.recipe.minus_items
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def name
    return self.recipe.name
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def icon_index
    return self.recipe.icon_index
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def price
    return self.recipe.price
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def description
    text = self.recipe.description
    if text.is_a?(Integer)
      item = RPG::ItemMake::Item.new(text).object
      return item ? item.description : ""
    else
      return text
    end
  end
end

class << CAO::ItemMake
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def create_book_object_list(*args)
    return listing_id(args).map {|id| $data_imbooks[id] }
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def can_change_item?(recipe)
    return false unless recipe
    return false if recipe.secret
    return false unless recipe.price <= $game_party.gold
    return false unless recipe.minus_items.all? do |item|
      item.quantity <= $game_party.item_number(item.object)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def change_item(recipe)
    $game_party.lose_gold(recipe.price)
    recipe.minus_items.each do |item|
      $game_party.lose_item(item.object, item.quantity)
    end
    recipe.plus_items.each do |item|
      $game_party.gain_item(item.object, item.quantity)
    end
    recipe.new = true
    recipe.count += 1
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def activate_recipe(*args)
    listing_id(args).each {|id| $game_imrecipes[id].secret = false }
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def activate_book(*args)
    listing_id(args).each do |id|
      $data_imbooks[id].recipes.each {|recipe| recipe.secret = false }
    end
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def deactivate_recipe(*args)
    listing_id(args).each {|id| $game_imrecipes[id].secret = true }
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def deactivate_book(*args)
    listing_id(args).each do |id|
      $data_imbooks[id].recipes.each {|recipe| recipe.secret = true }
    end
  end
  #--------------------------------------------------------------------------
  # ● レシピおよびブックの ID を配列に変換する
  #--------------------------------------------------------------------------
  def listing_id(list)
    case list
    when Integer
      return [list]
    when Range
      return list.to_a
    when Array
      return list.to_a.flatten.map {|o| o.is_a?(Range) ? o.to_a : o }.flatten
    else
      raise ArgumentError, "invalid value", caller(2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def display_price?
    return $game_temp.item_make_books[0].display_price
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def visible_window?
    return $game_temp.item_make_books[0].visible_window
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def background_name
    book = $game_temp.item_make_books[0]
    return book.background_name || CAO::ItemMake::FILE_BACKGROUND
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def foreground_name
    book = $game_temp.item_make_books[0]
    return book.foreground_name || CAO::ItemMake::FILE_FOREGROUND
  end
end

class Window_ItemMakeGold < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width / 2, fitting_height(1))
    self.x = Graphics.width - self.width
    self.y = Graphics.height - self.height
    hide unless CAO::ItemMake.display_price?
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(4, 0, contents.width - 8, line_height, CAO::ItemMake::VOCAB_GOLD)
    draw_currency_value(
      $game_party.gold, Vocab::currency_unit, 4, 0, contents.width - 8)
  end
end

class Window_ItemMakeBook < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width / 2, fitting_height(visible_line_number) + 8)
    if $game_temp.item_make_simplicial
      self.hide.deactivate
    else
      self.show.activate
    end
    select(0)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    last_index = @index
    super
    if @index != last_index
      draw_command_name
      call_handler(:reelected) 
    end
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def book
    return $game_temp.item_make_books[@index]
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = 28
    rect.height = item_height
    rect.x = index * (item_width + spacing) + (item_width - rect.width) / 2
    rect.y = CAO::ItemMake::DISPLAY_BOOKNAME ? 0 : 2
    rect
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    draw_icon($game_temp.item_make_books[index].icon_index,
      rect.x + 2, rect.y + 2)
  end
  #--------------------------------------------------------------------------
  # ● 選択項目名の描画
  #--------------------------------------------------------------------------
  def draw_command_name
    rect = Rect.new(0, item_height + 4, contents_width, line_height)
    self.contents.clear_rect(rect)
    change_color(normal_color)
    draw_text(rect, self.book.name, 1)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    draw_command_name
  end
  
  #--------------------------------------------------------------------------
  # ● 下端パディングの更新
  #--------------------------------------------------------------------------
  def update_padding_bottom
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    return $game_temp.item_make_books.size
  end
  #--------------------------------------------------------------------------
  # ● 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
    return line_height + 4
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return CAO::ItemMake::DISPLAY_BOOKNAME ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return $game_temp.item_make_books.size
  end
  #--------------------------------------------------------------------------
  # ● 横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def spacing
    return 0
  end
  #--------------------------------------------------------------------------
  # ● カーソルを下に移動
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
  end
  #--------------------------------------------------------------------------
  # ● カーソルを上に移動
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
  end
  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ後ろに移動
  #--------------------------------------------------------------------------
  def cursor_pagedown
  end
  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ前に移動
  #--------------------------------------------------------------------------
  def cursor_pageup
  end
  
  #--------------------------------------------------------------------------
  # ● 横選択判定
  #--------------------------------------------------------------------------
  def horizontal?
    return true
  end
end

class Window_ItemMakeRecipe < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(width, height)
    @data = []
    super(0, 0, width, height)
    activate
    select(0)
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    return @data.size
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    last_index = @index
    super
    call_handler(:reelected) if @index != last_index
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def book=(book)
    return if @book == book
    @book = book
    @data = @book.recipes
    select(0)
    create_contents
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    if CAO::ItemMake::DISPLAY_NUBER
      rect.x += 4
      rect.width -= 8
      change_color(normal_color)
      text = sprintf(CAO::ItemMake::VOCAB_RECIPE_NUMBER, index + 1)
      draw_text(rect, text)
      tw = self.contents.text_size(text).width
      rect.x += tw
      rect.width -= tw
    end
    draw_item_name(rect, @data[index])
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(rect, imitem)
    return unless imitem
    if imitem.secret
      icon_index = CAO::ItemMake::ICON_SECRET
      item_name = CAO::ItemMake::VACAB_SECRET_NAME
      enabled = false
    else
      icon_index = imitem.icon_index
      item_name = imitem.name
      enabled = make_item?(imitem)
    end
    draw_icon(icon_index, rect.x, rect.y, enabled)
    change_color(normal_color, enabled)
    draw_text(rect.x + 24, rect.y, rect.width, line_height, item_name)
  end
  #--------------------------------------------------------------------------
  # ● レシピの取得
  #--------------------------------------------------------------------------
  def recipe
    return @data && @index >= 0 ? @data[@index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 合成可能か判定
  #--------------------------------------------------------------------------
  def make_item?(imitem)
    return CAO::ItemMake.can_change_item?(imitem)
  end
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    return make_item?(@data[@index])
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    if self.recipe && self.recipe.secret
      @help_window.set_text(CAO::ItemMake::VACAB_SECRET_HELP)
    else
      @help_window.set_item(self.recipe)
    end
  end
end

class Window_ItemMakeStatus < Window_Base
  include CAO::ItemMake
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  NUM_SIZE = -6
  NUM_DOWN = 4
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  attr_writer :book
  attr_writer :recipe
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(width, height)
    super(0, 0, width, height)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return unless @recipe
    y = 0
    if CAO::ItemMake.display_price?
      draw_price(y)
      y += line_height + 8
    end
    if PLUS_GA_UE
      draw_plus_items(y)
      draw_minus_items(y += line_height * (@book.plus_number + 1))
    else
      draw_minus_items(y)
      draw_plus_items(y += line_height * (@book.minus_number + 1))
    end
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def draw_price(y)
    unit = Vocab.currency_unit
    change_color(system_color)
    draw_text(0, y, contents_width, line_height, VOCAB_PRICE)
    draw_text(0, y, contents_width, line_height, unit, 2)
    change_color(normal_color)
    draw_text(0, y, contents_width - text_size(unit).width - 2, line_height,
      @recipe.secret ? VACAB_SECRET_PRICE: @recipe.price, 2)
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(imitem, x, y, enabled = true)
    if @recipe.secret
      icon_index = ICON_SECRET
      item_name = VACAB_SECRET_NAME
      number = "#{VACAB_SECRET_NUMBER}(#{VACAB_SECRET_NUMBER})"
      enabled = true
    else
      return unless imitem
      icon_index = imitem.object.icon_index
      item_name = imitem.object.name
      stock = $game_party.item_number(imitem.object)
      number = sprintf(VOCAB_QUANTITY, imitem.quantity, stock)
    end
    draw_icon(icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, contents_width - x - 24, line_height, item_name)
    change_size(NUM_SIZE) do
      draw_text(contents_width - 48, y + NUM_DOWN, 48, line_height, number, 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 増やすアイテムの描画
  #--------------------------------------------------------------------------
  def draw_plus_items(y)
    change_color(system_color)
    draw_text(0, y, contents_width, line_height,
      @book.plus_name || VOCAB_PLUS_ITEM)
    @book.plus_number.times do |i|
      y += line_height
      draw_item_name(@recipe.plus_items[i], 8, y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 減らすアイテムの描画
  #--------------------------------------------------------------------------
  def draw_minus_items(y)
    change_color(system_color)
    draw_text(0, y, contents_width, line_height,
      @book.minus_name || VOCAB_MINUS_ITEM)
    @book.minus_number.times do |i|
      y += line_height
      imitem = @recipe.minus_items[i]
      draw_item_name(imitem, 8, y,
        imitem && (imitem.quantity <= $game_party.item_number(imitem.object)))
    end
  end
  #--------------------------------------------------------------------------
  # ● 描画文字のサイズを一時的に変更
  #--------------------------------------------------------------------------
  def change_size(size)
    self.contents.font.size += size
    yield
    self.contents.font.size -= size
  end
end

class Scene_ItemMake < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 準備
  #     category : レシピブック ID の配列
  #--------------------------------------------------------------------------
  def prepare(category)
    $game_temp.item_make_simplicial =
      category.size == 1 && category[0].is_a?(Integer)
    $game_temp.item_make_books =
      CAO::ItemMake.create_book_object_list(*category)
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    @help_window = Window_Help.new
    create_category_window
    create_gold_window
    create_recipe_window
    create_status_window
    create_foreground
    unless CAO::ItemMake.visible_window?
      @help_window.opacity = 0
      @category_window.opacity = 0
      @gold_window.opacity = 0
      @recipe_window.opacity = 0
      @status_window.opacity = 0
    end
    refresh_recipe
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_foreground
  end
  #--------------------------------------------------------------------------
  # ● 背景の作成
  #--------------------------------------------------------------------------
  def create_background
    super
    filename = CAO::ItemMake.background_name
    unless filename.empty?
      @background_sprite2 = Sprite.new
      @background_sprite2.bitmap = Cache.system(filename)
    end
  end
  #--------------------------------------------------------------------------
  # ● 背景の解放
  #--------------------------------------------------------------------------
  def dispose_background
    super
    @background_sprite2.dispose if @background_sprite2
  end
  #--------------------------------------------------------------------------
  # ● 前景の作成
  #--------------------------------------------------------------------------
  def create_foreground
    filename = CAO::ItemMake.foreground_name
    unless filename.empty?
      @foreground_sprite = Sprite.new
      @foreground_sprite.bitmap = Cache.system(filename)
      @foreground_sprite.z = @help_window.z
    end
  end
  #--------------------------------------------------------------------------
  # ● 前景の解放
  #--------------------------------------------------------------------------
  def dispose_foreground
    @foreground_sprite.dispose if @foreground_sprite
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemMakeBook.new
    @category_window.x = 0
    @category_window.y = @help_window.y + @help_window.height
    @category_window.select(0)
    @category_window.set_handler(:reelected, method(:refresh_recipe))
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_ItemMakeGold.new
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def create_recipe_window
    ww = Graphics.width / 2
    wh = Graphics.height - @help_window.height
    wh -= @category_window.height if @category_window.visible
    @recipe_window = Window_ItemMakeRecipe.new(ww, wh)
    @recipe_window.help_window = @help_window
    @recipe_window.x = 0
    @recipe_window.y = @help_window.y + @help_window.height
    if @category_window.visible
      @recipe_window.y += @category_window.height
    end
    @recipe_window.set_handler(:ok,     method(:on_recipe_ok))
    @recipe_window.set_handler(:cancel, method(:return_scene))
    
    @recipe_window.set_handler(:reelected, method(:refresh_status))
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def create_status_window
    ww = Graphics.width / 2
    wh = Graphics.height - @help_window.height
    wh -= @gold_window.height if @gold_window.visible
    @status_window = Window_ItemMakeStatus.new(ww, wh)
    @status_window.x = ww
    @status_window.y = @help_window.y + @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● レシピ［決定］
  #--------------------------------------------------------------------------
  def on_recipe_ok
    CAO::ItemMake.change_item(@recipe_window.recipe)
    @recipe_window.refresh
    @status_window.refresh
    @gold_window.refresh
    @recipe_window.activate
  end
  #--------------------------------------------------------------------------
  # ● レシピウィンドウのリフレッシュ
  #--------------------------------------------------------------------------
  def refresh_recipe
    @recipe_window.book = @category_window.book
    refresh_status
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウのリフレッシュ
  #--------------------------------------------------------------------------
  def refresh_status
    @status_window.book = @category_window.book
    @status_window.recipe = @recipe_window.recipe
    @status_window.refresh
  end
end

class << Scene_ItemMake
  #--------------------------------------------------------------------------
  # ● アイテム合成の起動
  #--------------------------------------------------------------------------
  def start(*params)
    SceneManager.call(Scene_ItemMake)
    SceneManager.scene.prepare(params)
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● アイテム合成の起動
  #--------------------------------------------------------------------------
  def start_item_make(*params)
    return if $game_party.in_battle
    Scene_ItemMake.start(*params)
    Fiber.yield
  end
end
