#==============================================================================
# ■ RGSS3 アイテム図鑑 ver 1.01　本体プログラム
#------------------------------------------------------------------------------
# 　配布元:
#     白の魔 http://izumiwhite.web.fc2.com/
#
# 　利用規約:
#     RPGツクールVX Aceの正規の登録者のみご利用になれます。
#     利用報告・著作権表示とかは必要ありません。
#     改造もご自由にどうぞ。
#     何か問題が発生しても責任は持ちません。
#==============================================================================

#==============================================================================
# ■ WD_itemdictionary
#------------------------------------------------------------------------------
# 　アイテム図鑑用の共通メソッドです。
#==============================================================================

module WD_itemdictionary
  def i_dictionary_switch_on(id)
    $game_system.i_dic_sw = [] if $game_system.i_dic_sw == nil
    $game_system.i_dic_sw[id] = false if $game_system.i_dic_sw[id] == nil
    $game_system.i_dic_sw[id] = true
  end
  def i_dictionary_switch_off(id)
    $game_system.i_dic_sw = [] if $game_system.i_dic_sw == nil
    $game_system.i_dic_sw[id] = false if $game_system.i_dic_sw[id] == nil
    $game_system.i_dic_sw[id] = false
  end
  def i_dictionary_switch_on?(id)
    $game_system.i_dic_sw = [] if $game_system.i_dic_sw == nil
    $game_system.i_dic_sw[id] = false if $game_system.i_dic_sw[id] == nil
    return $game_system.i_dic_sw[id]
  end
  def w_dictionary_switch_on(id)
    $game_system.w_dic_sw = [] if $game_system.w_dic_sw == nil
    $game_system.w_dic_sw[id] = false if $game_system.w_dic_sw[id] == nil
    $game_system.w_dic_sw[id] = true
  end
  def w_dictionary_switch_off(id)
    $game_system.w_dic_sw = [] if $game_system.w_dic_sw == nil
    $game_system.w_dic_sw[id] = false if $game_system.w_dic_sw[id] == nil
    $game_system.w_dic_sw[id] = false
  end
  def w_dictionary_switch_on?(id)
    $game_system.w_dic_sw = [] if $game_system.w_dic_sw == nil
    $game_system.w_dic_sw[id] = false if $game_system.w_dic_sw[id] == nil
    return $game_system.w_dic_sw[id]
  end
  def a_dictionary_switch_on(id)
    $game_system.a_dic_sw = [] if $game_system.a_dic_sw == nil
    $game_system.a_dic_sw[id] = false if $game_system.a_dic_sw[id] == nil
    $game_system.a_dic_sw[id] = true
  end
  def a_dictionary_switch_off(id)
    $game_system.a_dic_sw = [] if $game_system.a_dic_sw == nil
    $game_system.a_dic_sw[id] = false if $game_system.a_dic_sw[id] == nil
    $game_system.a_dic_sw[id] = false
  end
  def a_dictionary_switch_on?(id)
    $game_system.a_dic_sw = [] if $game_system.a_dic_sw == nil
    $game_system.a_dic_sw[id] = false if $game_system.a_dic_sw[id] == nil
    return $game_system.a_dic_sw[id]
  end
  def t_dictionary_switch_on(item)
    if item.is_a?(RPG::Item)
      i_dictionary_switch_on(item.id)
    end
    if item.is_a?(RPG::Weapon)
      w_dictionary_switch_on(item.id)
    end
    if item.is_a?(RPG::Armor)
      a_dictionary_switch_on(item.id)
    end
  end
  def t_dictionary_switch_on?(item)
    if item.is_a?(RPG::Item)
      return i_dictionary_switch_on?(item.id)
    end
    if item.is_a?(RPG::Weapon)
      return w_dictionary_switch_on?(item.id)
    end
    if item.is_a?(RPG::Armor)
      return a_dictionary_switch_on?(item.id)
    end
  end
  def print_dictionary?(item)
    if item != nil
      if item.name.size > 0
        hantei = /<図鑑無効>/ =~ item.note
        if hantei == nil
          return true
        end
      end
    end
    return false
  end
  def item_dictionary_perfection
    dic_max = 0
    dic_num = 0
    $data_items.each do |item|
      if print_dictionary?(item)
        dic_max += 1
        if i_dictionary_switch_on?(item.id) == true
          dic_num += 1
        end
      end
    end
    $data_weapons.each do |item|
      if print_dictionary?(item)
        dic_max += 1
        if w_dictionary_switch_on?(item.id) == true
          dic_num += 1
        end
      end
    end
    $data_armors.each do |item|
      if print_dictionary?(item)
        dic_max += 1
        if a_dictionary_switch_on?(item.id) == true
          dic_num += 1
        end
      end
    end
    return (100*dic_num)/dic_max
  end
end

class Game_Interpreter
  include WD_itemdictionary
end

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :i_dic_sw
  attr_accessor :w_dic_sw
  attr_accessor :a_dic_sw
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias wd_orig_initialize001 initialize
  def initialize
    wd_orig_initialize001
    @i_dic_sw = []
    @w_dic_sw = []
    @a_dic_sw = []
  end
end

class Game_Party < Game_Unit
  include WD_itemdictionary
  #--------------------------------------------------------------------------
  # ● アイテムの増加（減少）
  #     include_equip : 装備品も含める
  #--------------------------------------------------------------------------
  alias wd_orig_gain_item001 gain_item
  def gain_item(item, amount, include_equip = false)    
    wd_orig_gain_item001(item, amount, include_equip)
    if amount > 0
      t_dictionary_switch_on(item)
    end
  end
end


#==============================================================================
# ■ Scene_ItemDictionary
#------------------------------------------------------------------------------
# 　アイテム図鑑画面の処理を行うクラスです。
#==============================================================================

class Scene_ItemDictionary < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_category_window
    create_status_window
    create_item_window
    create_perfection_window
  end
  #--------------------------------------------------------------------------
  # ● カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @help_window.height
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy - 48
    @item_window = Window_ItemDictionaryList.new(Graphics.width-172-48, wy, 172+48, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # ● アイテムステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @status_window = Window_ItemDictionaryStatus.new(0, wy, Graphics.width-172-48, wh)
    @status_window.viewport = @viewport
    @status_window.set_item(nil)
  end
  #--------------------------------------------------------------------------
  # ● 図鑑完成度ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_perfection_window
    wy = @item_window.y + @item_window.height
    wh = 48
    @perfection_window = Window_ItemDictionaryPerfection.new(Graphics.width-172-48, wy, 172+48, wh)
    @perfection_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    @category_window.activate
    @status_window.set_item(nil)
  end
end


#==============================================================================
# ■ Window_ItemDictionaryList
#------------------------------------------------------------------------------
# 　アイテム図鑑画面で、アイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_ItemDictionaryList < Window_Selectable
  include WD_itemdictionary
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @category = :none
    @data = []
  end
  #--------------------------------------------------------------------------
  # ● カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● アイテムの取得
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :key_item
      item.is_a?(RPG::Item) && item.key_item?
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    $data_items.each do |item|
      if print_dictionary?(item)
        @data.push(item) if include?(item)
      end
    end
    $data_weapons.each do |item|
      if print_dictionary?(item)
        @data.push(item) if include?(item)
      end
    end
    $data_armors.each do |item|
      if print_dictionary?(item)
        @data.push(item) if include?(item)
      end
    end
    @data.push(nil) if include?(nil)
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select(0)
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      if t_dictionary_switch_on?(item)
        change_color(normal_color, true)
        draw_item_name(item, rect.x, rect.y, true)
      else
        change_color(normal_color, false)
        draw_text(rect.x + 24, rect.y, 172, line_height, "？？？？？？？")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    if t_dictionary_switch_on?(item)
      @help_window.set_item(item)
      @status_window.set_item(item, @index, true)
    else
      @help_window.set_text("？？？？？？？")
      @status_window.set_item(item, @index, false)
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
  end
end

#==============================================================================
# ■ Window_ItemDictionaryPerfection
#------------------------------------------------------------------------------
# 　アイテム図鑑画面で、図鑑の完成度を表示するウィンドウです。
#==============================================================================

class Window_ItemDictionaryPerfection < Window_Selectable
  include WD_itemdictionary
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    refresh(width)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(width)
    contents.clear
    draw_text(0, 0, width-24, line_height, "図鑑完成度: #{item_dictionary_perfection} %", 1)
  end
end


#==============================================================================
# ■ Window_ItemDictionaryStatus
#------------------------------------------------------------------------------
# 　アイテム図鑑画面で、アイテムの詳細を表示するウィンドウです。
#==============================================================================

class Window_ItemDictionaryStatus < Window_Selectable
  include WD_itemdictionary
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @item = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #--------------------------------------------------------------------------
  def set_item(item, index=-1, print=false)
    return if ((@item == item) and (@index == index))
    @item = item
    @index = index
    @print = print
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.size = 24

    if @print

      if @item.is_a?(RPG::Item)
        if WD_itemdictionary_layout::I_id_display
          text1  = sprintf("%0#{WD_itemdictionary_layout::I_id_display_digit}d",@index+1)
          x      = WD_itemdictionary_layout::I_id_display_x
          y      = WD_itemdictionary_layout::I_id_display_y
          width  = WD_itemdictionary_layout::I_id_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
        if WD_itemdictionary_layout::I_name_display
          x      = WD_itemdictionary_layout::I_name_display_x
          y      = WD_itemdictionary_layout::I_name_display_y
          draw_item_name(@item, x, y, true)
        end
        font_size = WD_itemdictionary_layout::C_font_size
        contents.font.size = font_size
        if WD_itemdictionary_layout::I_price_display
          text1  = WD_itemdictionary_layout::I_price_display_text1
          text2  = @item.price
          text3  = Vocab::currency_unit
          x      = WD_itemdictionary_layout::I_price_display_x
          y      = WD_itemdictionary_layout::I_price_display_y
          width  = WD_itemdictionary_layout::I_price_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          cx = text_size(Vocab::currency_unit).width
          change_color(normal_color)
          draw_text(x, y, width - cx - 2, font_size, text2, 2)
          change_color(system_color)
          draw_text(x, y, width, font_size, text3, 2)
          change_color(normal_color)
        end
        if WD_itemdictionary_layout::I_occasion_display
          text1  = WD_itemdictionary_layout::I_occasion_display_text1
          text2  = WD_itemdictionary_layout::I_occasion_display_text2
          text3  = WD_itemdictionary_layout::I_occasion_display_text3
          text4  = WD_itemdictionary_layout::I_occasion_display_text4
          text5  = WD_itemdictionary_layout::I_occasion_display_text5
          x      = WD_itemdictionary_layout::I_occasion_display_x
          y      = WD_itemdictionary_layout::I_occasion_display_y
          width  = WD_itemdictionary_layout::I_occasion_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          case @item.occasion
          when 0
            draw_text(x, y, width, font_size, text2, 2)
          when 1
            draw_text(x, y, width, font_size, text3, 2)
          when 2
            draw_text(x, y, width, font_size, text4, 2)
          when 3
            draw_text(x, y, width, font_size, text5, 2)
          end
        end
        if WD_itemdictionary_layout::I_consumable_display
          text1  = WD_itemdictionary_layout::I_consumable_display_text1
          text2  = WD_itemdictionary_layout::I_consumable_display_text2
          text3  = WD_itemdictionary_layout::I_consumable_display_text3
          x      = WD_itemdictionary_layout::I_consumable_display_x
          y      = WD_itemdictionary_layout::I_consumable_display_y
          width  = WD_itemdictionary_layout::I_consumable_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          if @item.consumable
            draw_text(x, y, width, font_size, text2, 2)
          else
            draw_text(x, y, width, font_size, text3, 2)
          end
        end  
        if WD_itemdictionary_layout::I_option_display
          text1  = WD_itemdictionary_layout::I_option_display_text1
          text2  = WD_itemdictionary_layout::I_option_display_text2
          x      = WD_itemdictionary_layout::I_option_display_x
          y      = WD_itemdictionary_layout::I_option_display_y
          width  = WD_itemdictionary_layout::I_option_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          i = 0
          @item.note.scan(/<図鑑特徴:(.*)>/){|matched|
            i += 1
            self.contents.draw_text(x + font_size, y + font_size * i, width - font_size, font_size, matched[0], 0)
           }
          if i == 0
            self.contents.draw_text(x + font_size, y + font_size, width - font_size, font_size, text2, 0)
          end
        end

      elsif @item.is_a?(RPG::Weapon)
        if WD_itemdictionary_layout::W_id_display
          text1  = sprintf("%0#{WD_itemdictionary_layout::W_id_display_digit}d",@index+1)
          x      = WD_itemdictionary_layout::W_id_display_x
          y      = WD_itemdictionary_layout::W_id_display_y
          width  = WD_itemdictionary_layout::W_id_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
        if WD_itemdictionary_layout::W_name_display
          x      = WD_itemdictionary_layout::W_name_display_x
          y      = WD_itemdictionary_layout::W_name_display_y
          draw_item_name(@item, x, y, true)
        end
        font_size = WD_itemdictionary_layout::C_font_size
        contents.font.size = font_size
        if WD_itemdictionary_layout::W_type_display
          text1  = WD_itemdictionary_layout::W_type_display_text1
          text2  = $data_system.weapon_types[@item.wtype_id]
          x      = WD_itemdictionary_layout::W_type_display_x
          y      = WD_itemdictionary_layout::W_type_display_y
          width  = WD_itemdictionary_layout::W_type_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_price_display
          text1  = WD_itemdictionary_layout::W_price_display_text1
          text2  = @item.price
          text3  = Vocab::currency_unit
          x      = WD_itemdictionary_layout::W_price_display_x
          y      = WD_itemdictionary_layout::W_price_display_y
          width  = WD_itemdictionary_layout::W_price_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          cx = text_size(Vocab::currency_unit).width
          change_color(normal_color)
          draw_text(x, y, width - cx - 2, font_size, text2, 2)
          change_color(system_color)
          draw_text(x, y, width, font_size, text3, 2)
          change_color(normal_color)
        end
        if WD_itemdictionary_layout::W_atk_display
          text1  = Vocab::param(2)
          text2  = @item.params[2]
          x      = WD_itemdictionary_layout::W_atk_display_x
          y      = WD_itemdictionary_layout::W_atk_display_y
          width  = WD_itemdictionary_layout::W_atk_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_def_display
          text1  = Vocab::param(3)
          text2  = @item.params[3]
          x      = WD_itemdictionary_layout::W_def_display_x
          y      = WD_itemdictionary_layout::W_def_display_y
          width  = WD_itemdictionary_layout::W_def_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_mat_display
          text1  = Vocab::param(4)
          text2  = @item.params[4]
          x      = WD_itemdictionary_layout::W_mat_display_x
          y      = WD_itemdictionary_layout::W_mat_display_y
          width  = WD_itemdictionary_layout::W_mat_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_mdf_display
          text1  = Vocab::param(5)
          text2  = @item.params[5]
          x      = WD_itemdictionary_layout::W_mdf_display_x
          y      = WD_itemdictionary_layout::W_mdf_display_y
          width  = WD_itemdictionary_layout::W_mdf_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_agi_display
          text1  = Vocab::param(6)
          text2  = @item.params[6]
          x      = WD_itemdictionary_layout::W_agi_display_x
          y      = WD_itemdictionary_layout::W_agi_display_y
          width  = WD_itemdictionary_layout::W_agi_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_luk_display
          text1  = Vocab::param(7)
          text2  = @item.params[7]
          x      = WD_itemdictionary_layout::W_luk_display_x
          y      = WD_itemdictionary_layout::W_luk_display_y
          width  = WD_itemdictionary_layout::W_luk_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_mhp_display
          text1  = Vocab::param(0)
          text2  = @item.params[0]
          x      = WD_itemdictionary_layout::W_mhp_display_x
          y      = WD_itemdictionary_layout::W_mhp_display_y
          width  = WD_itemdictionary_layout::W_mhp_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_mmp_display
          text1  = Vocab::param(1)
          text2  = @item.params[1]
          x      = WD_itemdictionary_layout::W_mmp_display_x
          y      = WD_itemdictionary_layout::W_mmp_display_y
          width  = WD_itemdictionary_layout::W_mmp_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::W_option_display
          text1  = WD_itemdictionary_layout::W_option_display_text1
          text2  = WD_itemdictionary_layout::W_option_display_text2
          x      = WD_itemdictionary_layout::W_option_display_x
          y      = WD_itemdictionary_layout::W_option_display_y
          width  = WD_itemdictionary_layout::W_option_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          i = 0
          @item.note.scan(/<図鑑特徴:(.*)>/){|matched|
            i += 1
            self.contents.draw_text(x + font_size, y + font_size * i, width - font_size, font_size, matched[0], 0)
           }
          if i == 0
            self.contents.draw_text(x + font_size, y + font_size, width - font_size, font_size, text2, 0)
          end
        end

      elsif @item.is_a?(RPG::Armor)
        if WD_itemdictionary_layout::A_id_display
          text1  = sprintf("%0#{WD_itemdictionary_layout::A_id_display_digit}d",@index+1)
          x      = WD_itemdictionary_layout::A_id_display_x
          y      = WD_itemdictionary_layout::A_id_display_y
          width  = WD_itemdictionary_layout::A_id_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
        if WD_itemdictionary_layout::A_name_display
          x      = WD_itemdictionary_layout::A_name_display_x
          y      = WD_itemdictionary_layout::A_name_display_y
          draw_item_name(@item, x, y, true)
        end
        font_size = WD_itemdictionary_layout::C_font_size
        contents.font.size = font_size
        if WD_itemdictionary_layout::A_type_display
          text1  = WD_itemdictionary_layout::A_type_display_text1
          text2  = $data_system.armor_types[@item.atype_id]
          x      = WD_itemdictionary_layout::A_type_display_x
          y      = WD_itemdictionary_layout::A_type_display_y
          width  = WD_itemdictionary_layout::A_type_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_price_display
          text1  = WD_itemdictionary_layout::A_price_display_text1
          text2  = @item.price
          text3  = Vocab::currency_unit
          x      = WD_itemdictionary_layout::A_price_display_x
          y      = WD_itemdictionary_layout::A_price_display_y
          width  = WD_itemdictionary_layout::A_price_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          cx = text_size(Vocab::currency_unit).width
          change_color(normal_color)
          draw_text(x, y, width - cx - 2, font_size, text2, 2)
          change_color(system_color)
          draw_text(x, y, width, font_size, text3, 2)
          change_color(normal_color)
        end
        if WD_itemdictionary_layout::A_atk_display
          text1  = Vocab::param(2)
          text2  = @item.params[2]
          x      = WD_itemdictionary_layout::A_atk_display_x
          y      = WD_itemdictionary_layout::A_atk_display_y
          width  = WD_itemdictionary_layout::A_atk_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_def_display
          text1  = Vocab::param(3)
          text2  = @item.params[3]
          x      = WD_itemdictionary_layout::A_def_display_x
          y      = WD_itemdictionary_layout::A_def_display_y
          width  = WD_itemdictionary_layout::A_def_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_mat_display
          text1  = Vocab::param(4)
          text2  = @item.params[4]
          x      = WD_itemdictionary_layout::A_mat_display_x
          y      = WD_itemdictionary_layout::A_mat_display_y
          width  = WD_itemdictionary_layout::A_mat_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_mdf_display
          text1  = Vocab::param(5)
          text2  = @item.params[5]
          x      = WD_itemdictionary_layout::A_mdf_display_x
          y      = WD_itemdictionary_layout::A_mdf_display_y
          width  = WD_itemdictionary_layout::A_mdf_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_agi_display
          text1  = Vocab::param(6)
          text2  = @item.params[6]
          x      = WD_itemdictionary_layout::A_agi_display_x
          y      = WD_itemdictionary_layout::A_agi_display_y
          width  = WD_itemdictionary_layout::A_agi_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_luk_display
          text1  = Vocab::param(7)
          text2  = @item.params[7]
          x      = WD_itemdictionary_layout::A_luk_display_x
          y      = WD_itemdictionary_layout::A_luk_display_y
          width  = WD_itemdictionary_layout::A_luk_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_mhp_display
          text1  = Vocab::param(0)
          text2  = @item.params[0]
          x      = WD_itemdictionary_layout::A_mhp_display_x
          y      = WD_itemdictionary_layout::A_mhp_display_y
          width  = WD_itemdictionary_layout::A_mhp_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_mmp_display
          text1  = Vocab::param(1)
          text2  = @item.params[1]
          x      = WD_itemdictionary_layout::A_mmp_display_x
          y      = WD_itemdictionary_layout::A_mmp_display_y
          width  = WD_itemdictionary_layout::A_mmp_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          draw_text(x, y, width, font_size, text2, 2)
        end
        if WD_itemdictionary_layout::A_option_display
          text1  = WD_itemdictionary_layout::A_option_display_text1
          text2  = WD_itemdictionary_layout::A_option_display_text2
          x      = WD_itemdictionary_layout::A_option_display_x
          y      = WD_itemdictionary_layout::A_option_display_y
          width  = WD_itemdictionary_layout::A_option_display_width
          change_color(system_color)
          draw_text(x, y, width, font_size, text1, 0)
          change_color(normal_color)
          i = 0
          @item.note.scan(/<図鑑特徴:(.*)>/){|matched|
            i += 1
            self.contents.draw_text(x + font_size, y + font_size * i, width - font_size, font_size, matched[0], 0)
           }
          if i == 0
            self.contents.draw_text(x + font_size, y + font_size, width - font_size, font_size, text2, 0)
          end
        end

      end

    elsif @item != nil
      if @item.is_a?(RPG::Item)
        if WD_itemdictionary_layout::I_id_display
          text1  = sprintf("%0#{WD_itemdictionary_layout::I_id_display_digit}d",@index+1)
          x      = WD_itemdictionary_layout::I_id_display_x
          y      = WD_itemdictionary_layout::I_id_display_y
          width  = WD_itemdictionary_layout::I_id_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
        if WD_itemdictionary_layout::I_name_display
          text1  = "- No Data -"
          x      = WD_itemdictionary_layout::I_name_display_x
          y      = WD_itemdictionary_layout::I_name_display_y
          width  = WD_itemdictionary_layout::I_name_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
      end
      if @item.is_a?(RPG::Weapon)
        if WD_itemdictionary_layout::W_id_display
          text1  = sprintf("%0#{WD_itemdictionary_layout::W_id_display_digit}d",@index+1)
          x      = WD_itemdictionary_layout::W_id_display_x
          y      = WD_itemdictionary_layout::W_id_display_y
          width  = WD_itemdictionary_layout::W_id_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
        if WD_itemdictionary_layout::W_name_display
          text1  = "- No Data -"
          x      = WD_itemdictionary_layout::W_name_display_x
          y      = WD_itemdictionary_layout::W_name_display_y
          width  = WD_itemdictionary_layout::W_name_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
      end
      if @item.is_a?(RPG::Armor)
        if WD_itemdictionary_layout::A_id_display
          text1  = sprintf("%0#{WD_itemdictionary_layout::A_id_display_digit}d",@index+1)
          x      = WD_itemdictionary_layout::A_id_display_x
          y      = WD_itemdictionary_layout::A_id_display_y
          width  = WD_itemdictionary_layout::A_id_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
        if WD_itemdictionary_layout::A_name_display
          text1  = "- No Data -"
          x      = WD_itemdictionary_layout::A_name_display_x
          y      = WD_itemdictionary_layout::A_name_display_y
          width  = WD_itemdictionary_layout::A_name_display_width
          height = line_height
          draw_text(x, y, width, height, text1, 0)
        end
      end

    end
  end
end