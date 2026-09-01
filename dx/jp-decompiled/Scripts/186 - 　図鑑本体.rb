#==============================================================================
# ■ RGSS3 魔物図鑑 ver 1.01　本体プログラム
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
# ■ WD_monsterdictionary
#------------------------------------------------------------------------------
# 　魔物図鑑用の共通メソッドです。
#==============================================================================

module WD_monsterdictionary
  def m_dictionary_encount_switch_on(id)
    $game_system.m_dic_encount_sw = [] if $game_system.m_dic_encount_sw == nil
    $game_system.m_dic_encount_sw[id] = false if $game_system.m_dic_encount_sw[id] == nil
    $game_system.m_dic_encount_sw[id] = true
  end
  def m_dictionary_encount_switch_off(id)
    $game_system.m_dic_encount_sw = [] if $game_system.m_dic_encount_sw == nil
    $game_system.m_dic_encount_sw[id] = false if $game_system.m_dic_encount_sw[id] == nil
    $game_system.m_dic_encount_sw[id] = false
  end
  def m_dictionary_encount_switch_on?(id)
    $game_system.m_dic_encount_sw = [] if $game_system.m_dic_encount_sw == nil
    $game_system.m_dic_encount_sw[id] = false if $game_system.m_dic_encount_sw[id] == nil
    return $game_system.m_dic_encount_sw[id]
  end
  def m_dictionary_victory_switch_on(id)
    $game_system.m_dic_victory_sw = [] if $game_system.m_dic_victory_sw == nil
    $game_system.m_dic_victory_sw[id] = false if $game_system.m_dic_victory_sw[id] == nil
    $game_system.m_dic_victory_sw[id] = true
  end
  def m_dictionary_victory_switch_off(id)
    $game_system.m_dic_victory_sw = [] if $game_system.m_dic_victory_sw == nil
    $game_system.m_dic_victory_sw[id] = false if $game_system.m_dic_victory_sw[id] == nil
    $game_system.m_dic_victory_sw[id] = false
  end
  def m_dictionary_victory_switch_on?(id)
    $game_system.m_dic_victory_sw = [] if $game_system.m_dic_victory_sw == nil
    $game_system.m_dic_victory_sw[id] = false if $game_system.m_dic_victory_sw[id] == nil
    return $game_system.m_dic_victory_sw[id]
  end
  def m_dictionary_drop_switch_on(id, n)
    $game_system.m_dic_drop_sw = [] if $game_system.m_dic_drop_sw == nil
    $game_system.m_dic_drop_sw[id] = [] if $game_system.m_dic_drop_sw[id] == nil
    $game_system.m_dic_drop_sw[id][n] = false if $game_system.m_dic_drop_sw[id][n] == nil
    $game_system.m_dic_drop_sw[id][n] = true
  end
  def m_dictionary_drop_switch_off(id, n)
    $game_system.m_dic_drop_sw = [] if $game_system.m_dic_drop_sw == nil
    $game_system.m_dic_drop_sw[id] = [] if $game_system.m_dic_drop_sw[id] == nil
    $game_system.m_dic_drop_sw[id][n] = false if $game_system.m_dic_drop_sw[id][n] == nil
    $game_system.m_dic_drop_sw[id][n] = false
  end
  def m_dictionary_drop_switch_on?(id, n)
    $game_system.m_dic_drop_sw = [] if $game_system.m_dic_drop_sw == nil
    $game_system.m_dic_drop_sw[id] = [] if $game_system.m_dic_drop_sw[id] == nil
    $game_system.m_dic_drop_sw[id][n] = false if $game_system.m_dic_drop_sw[id][n] == nil
    return $game_system.m_dic_drop_sw[id][n]
  end
  def m_dictionary_genoside_number_add(id, n)
    $game_system.m_dic_genoside_num = [] if $game_system.m_dic_genoside_num == nil
    $game_system.m_dic_genoside_num[id] = 0 if $game_system.m_dic_genoside_num[id] == nil
    $game_system.m_dic_genoside_num[id] += n
  end
  def m_dictionary_genoside_number(id)
    $game_system.m_dic_genoside_num = [] if $game_system.m_dic_genoside_num == nil
    $game_system.m_dic_genoside_num[id] = 0 if $game_system.m_dic_genoside_num[id] == nil
    return $game_system.m_dic_genoside_num[id]
  end

  def print_dictionary?(enemy)
    if enemy != nil
      if enemy.name.size > 0
        hantei = /<図鑑無効>/ =~ enemy.note
        if hantei == nil
          return true
        end
      end
    end
    return false
  end
  def monster_dictionary_perfection
    dic_max = 0
    dic_num = 0
    $data_enemies.each do |enemy|
      if print_dictionary?(enemy)
        dic_max += 1
        if WD_monsterdictionary_layout::Perfection_timing == 1
          if m_dictionary_encount_switch_on?(enemy.id) == true
            dic_num += 1
          end
        elsif WD_monsterdictionary_layout::Perfection_timing == 2
          if m_dictionary_victory_switch_on?(enemy.id) == true
            dic_num += 1
          end
        end
      end
    end
    return (100*dic_num)/dic_max
  end
end

class Game_Interpreter
  include WD_monsterdictionary
end

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :m_dic_encount_sw
  attr_accessor :m_dic_victory_sw
  attr_accessor :m_dic_drop_sw
  attr_accessor :m_dic_genoside_num
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias wd_orig_initialize002 initialize
  def initialize
    wd_orig_initialize002
    @m_dic_encount_sw = []
    @m_dic_victory_sw = []
    @m_dic_drop_sw = []
    @m_dic_genoside_num = []
  end
end

class Game_Troop < Game_Unit
  include WD_monsterdictionary
  #--------------------------------------------------------------------------
  # ● 図鑑への登録(遭遇済み判定)
  #--------------------------------------------------------------------------
  def dictionary1
    for enemy in members
      m_dictionary_encount_switch_on(enemy.enemy_id) unless enemy.hidden? #遭遇済み図鑑登録
    end
  end
  #--------------------------------------------------------------------------
  # ● 図鑑への登録(撃破済み判定)
  #--------------------------------------------------------------------------
  def dictionary2
    for enemy in dead_members
      m_dictionary_victory_switch_on(enemy.enemy_id) unless enemy.hidden? #撃破済み図鑑登録
      m_dictionary_genoside_number_add(enemy.enemy_id, 1) unless enemy.hidden? #撃破数カウント
    end
  end
end

class << BattleManager
  #--------------------------------------------------------------------------
  # ● 戦闘開始
  #--------------------------------------------------------------------------
  alias wd_orig_battle_start002 battle_start
  def battle_start
    wd_orig_battle_start002
    $game_troop.dictionary1 #図鑑への登録(遭遇済み判定)
  end
  #--------------------------------------------------------------------------
  # ● 勝利の処理
  #--------------------------------------------------------------------------
  alias wd_orig_process_victory002 process_victory
  def process_victory
    $game_troop.dictionary2 #図鑑への登録(撃破済み判定)
    wd_orig_process_victory002
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 敵キャラの出現
  #--------------------------------------------------------------------------
  alias wd_orig_command_335_002 command_335
  def command_335
    wd_orig_command_335_002
    $game_troop.dictionary1 #図鑑への登録(遭遇済み判定)
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラの変身
  #--------------------------------------------------------------------------
  alias wd_orig_command_336_002 command_336
  def command_336
    wd_orig_command_336_002
    $game_troop.dictionary1 #図鑑への登録(遭遇済み判定)
  end 
end

class Game_Enemy < Game_Battler
  include WD_monsterdictionary
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの配列作成(再定義)
  #--------------------------------------------------------------------------
  def make_drop_items
    n = -1
    enemy.drop_items.inject([]) do |r, di|
      n += 1
      if di.kind > 0 && rand * di.denominator < drop_item_rate
        m_dictionary_drop_switch_on(@enemy_id, n)
        r.push(item_object(di.kind, di.data_id))
      else
        r
      end
    end
  end
end

#==============================================================================
# ■ Scene_MonsterDictionary
#------------------------------------------------------------------------------
# 　魔物図鑑画面の処理を行うクラスです。
#==============================================================================

class Scene_MonsterDictionary < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_status_window
    create_item_window
    create_perfection_window
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wy = 0
    wh = Graphics.height- 48
    @item_window = Window_MonsterDictionaryList.new(Graphics.width-172-48, wy, 172+48, wh)
    @item_window.viewport = @viewport
    @item_window.status_window = @status_window
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● アイテムステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    wy = 0
    wh = Graphics.height
    @status_window = Window_MonsterDictionaryStatus.new(0, wy, Graphics.width-172-48, wh)
    @status_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● 図鑑完成度ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_perfection_window
    wy = @item_window.y + @item_window.height
    wh = 48
    @perfection_window = Window_MonsterDictionaryPerfection.new(Graphics.width-172-48, wy, 172+48, wh)
    @perfection_window.viewport = @viewport
  end
end


#==============================================================================
# ■ Window_MonsterDictionaryList
#------------------------------------------------------------------------------
# 　魔物図鑑画面で、魔物の一覧を表示するウィンドウです。
#==============================================================================

class Window_MonsterDictionaryList < Window_Selectable
  include WD_monsterdictionary
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @data = []
    refresh
    activate
    select(0)
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
  def enemy
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    $data_enemies.each do |enemy|
      if print_dictionary?(enemy)
        @data.push(enemy)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    enemy = @data[index]
    if enemy
      rect = item_rect(index)
      rect.width -= 4
      if m_dictionary_encount_switch_on?(enemy.id)
        change_color(normal_color, true)
        draw_text(rect.x, rect.y, 172, line_height, enemy.name)
      else
        change_color(normal_color, false)
        draw_text(rect.x, rect.y, 172, line_height, "？？？？？？？")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    update_help if active
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    if @status_window
      if m_dictionary_encount_switch_on?(enemy.id)
        @status_window.set_item(enemy, @index, true)
      else
        @status_window.set_item(enemy, @index, false)
      end
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
# ■ Window_MonsterDictionaryPerfection
#------------------------------------------------------------------------------
# 　魔物図鑑画面で、図鑑の完成度を表示するウィンドウです。
#==============================================================================

class Window_MonsterDictionaryPerfection < Window_Selectable
  include WD_monsterdictionary
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
    draw_text(0, 0, width-24, line_height, "図鑑完成度: #{monster_dictionary_perfection} %", 1)
  end
end


#==============================================================================
# ■ Window_MonsterDictionaryStatus
#------------------------------------------------------------------------------
# 　魔物図鑑画面で、エネミーの詳細を表示するウィンドウです。
#==============================================================================

class Window_MonsterDictionaryStatus < Window_Selectable
  include WD_monsterdictionary
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @enemy = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #--------------------------------------------------------------------------
  def set_item(enemy, index=-1, print=false)
    return if ((@enemy == enemy) and (@index == index))
    @enemy = enemy
    @index = index
    @print = print
    refresh
  end
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの取得
  #--------------------------------------------------------------------------
  def item_object(kind, data_id)
    return $data_items  [data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors [data_id] if kind == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.size = 24

    if @print

      if WD_monsterdictionary_layout::M_id_display
        text1  = sprintf("%0#{WD_monsterdictionary_layout::M_id_display_digit}d",@index+1)
        x      = WD_monsterdictionary_layout::M_id_display_x
        y      = WD_monsterdictionary_layout::M_id_display_y
        width  = WD_monsterdictionary_layout::M_id_display_width
        height = line_height
        draw_text(x, y, width, height, text1, 0)
      end
      if WD_monsterdictionary_layout::M_name_display
        text1  = @enemy.name
        x      = WD_monsterdictionary_layout::M_name_display_x
        y      = WD_monsterdictionary_layout::M_name_display_y
        width  = WD_monsterdictionary_layout::M_name_display_width
        height = line_height
        draw_text(x, y, width, height, text1, 0)
      end
      if WD_monsterdictionary_layout::M_pic_display
        pic_name = @enemy.battler_name 
        pic_hue  = @enemy.battler_hue
        x      = WD_monsterdictionary_layout::M_pic_display_x
        y      = WD_monsterdictionary_layout::M_pic_display_y
        opacity= WD_monsterdictionary_layout::M_pic_display_opacity
        bitmap = Cache.battler(pic_name, pic_hue)
        rect = Rect.new(0, 0, bitmap.width, bitmap.height)
        contents.blt(x - rect.width/2, y - rect.height, bitmap, rect, opacity)
      end

      font_size = WD_monsterdictionary_layout::C_font_size
      contents.font.size = font_size
      if WD_monsterdictionary_layout::M_mhp_display
        text1  = Vocab::param(0)
        text2  = "？"
        text2  = @enemy.params[0] if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_mhp_display_x
        y      = WD_monsterdictionary_layout::M_mhp_display_y
        width  = WD_monsterdictionary_layout::M_mhp_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_mmp_display
        text1  = Vocab::param(1)
        text2  = "？"
        text2  = @enemy.params[1] if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_mmp_display_x
        y      = WD_monsterdictionary_layout::M_mmp_display_y
        width  = WD_monsterdictionary_layout::M_mmp_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_atk_display
        text1  = Vocab::param(2)
        text2  = "？"
        text2  = @enemy.params[2] if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_atk_display_x
        y      = WD_monsterdictionary_layout::M_atk_display_y
        width  = WD_monsterdictionary_layout::M_atk_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_def_display
        text1  = Vocab::param(3)
        text2  = "？"
        text2  = @enemy.params[3] if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_def_display_x
        y      = WD_monsterdictionary_layout::M_def_display_y
        width  = WD_monsterdictionary_layout::M_def_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_mat_display
        text1  = Vocab::param(4)
        text2  = "？"
        text2  = @enemy.params[4] if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_mat_display_x
        y      = WD_monsterdictionary_layout::M_mat_display_y
        width  = WD_monsterdictionary_layout::M_mat_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_mdf_display
        text1  = Vocab::param(5)
        text2  = "？"
        text2  = @enemy.params[5] if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_mdf_display_x
        y      = WD_monsterdictionary_layout::M_mdf_display_y
        width  = WD_monsterdictionary_layout::M_mdf_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, "魔法防御", 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_agi_display
        text1  = Vocab::param(6)
        text2  = "？"
        text2  = @enemy.params[6] 
        x      = WD_monsterdictionary_layout::M_agi_display_x
        y      = WD_monsterdictionary_layout::M_agi_display_y
        width  = WD_monsterdictionary_layout::M_agi_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_luk_display
        text1  = Vocab::param(7)
        text2  = "？"
        text2  = @enemy.params[7] 
        x      = WD_monsterdictionary_layout::M_luk_display_x
        y      = WD_monsterdictionary_layout::M_luk_display_y
        width  = WD_monsterdictionary_layout::M_luk_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_feature_display
        text1  = WD_monsterdictionary_layout::M_feature_display_text1
        text2  = "？"
        text2  = WD_monsterdictionary_layout::M_feature_display_text2 if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_feature_display_x
        y      = WD_monsterdictionary_layout::M_feature_display_y
        width  = WD_monsterdictionary_layout::M_feature_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        i = 0
        if m_dictionary_victory_switch_on?(@enemy.id)
          @enemy.note.scan(/<図鑑特徴:(.*)>/){|matched|
            i += 1
            self.contents.draw_text(x + font_size, y + font_size * i, width - font_size, font_size, matched[0], 0)
          }
        end
        if i == 0
          self.contents.draw_text(x + font_size, y + font_size, width - font_size, font_size, text2, 0)
        end
      end
      if WD_monsterdictionary_layout::M_exp_display
        text1  = WD_monsterdictionary_layout::M_exp_display_text1
        text2  = "？"
        text2  = @enemy.exp if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_exp_display_x
        y      = WD_monsterdictionary_layout::M_exp_display_y
        width  = WD_monsterdictionary_layout::M_exp_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
      if WD_monsterdictionary_layout::M_gold_display
        text1  = WD_monsterdictionary_layout::M_gold_display_text1
        text2  = "？"
        text2  = @enemy.gold if m_dictionary_victory_switch_on?(@enemy.id)
        text3  = Vocab::currency_unit
        x      = WD_monsterdictionary_layout::M_gold_display_x
        y      = WD_monsterdictionary_layout::M_gold_display_y
        width  = WD_monsterdictionary_layout::M_gold_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        cx = text_size(Vocab::currency_unit).width
        change_color(normal_color)
        draw_text(x, y, width - cx - 2, font_size, text2, 2)
        change_color(system_color)
        draw_text(x, y, width, font_size, text3, 2)
        change_color(normal_color)
      end
      if WD_monsterdictionary_layout::M_drop_display
        text1  = WD_monsterdictionary_layout::M_drop_display_text1
        text2  = WD_monsterdictionary_layout::M_drop_display_text2 if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_drop_display_x
        y      = WD_monsterdictionary_layout::M_drop_display_y
        width  = WD_monsterdictionary_layout::M_drop_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        i = 0
        @enemy.drop_items.each do |di|
          if di.kind > 0
            i += 1
            item = item_object(di.kind, di.data_id)
            n = i -1
            if m_dictionary_drop_switch_on?(@enemy.id, n)
              text2 = item.name
              text3 = "1/#{di.denominator}"
            else
              text2  = "？？？？？？？"
              text3  = ""
            end
            self.contents.draw_text(x + font_size, y + font_size * i, width - font_size, font_size, text2, 0)
            self.contents.draw_text(x + font_size, y + font_size * i, width - font_size, font_size, text3, 2)
          end
        end
        if i == 0
          self.contents.draw_text(x + font_size, y + font_size, width - font_size, font_size, text2, 0)
        end
      end
      if WD_monsterdictionary_layout::M_help_display
        text1  = WD_monsterdictionary_layout::M_help_display_text1
        text2  = "？"
        text2  = WD_monsterdictionary_layout::M_help_display_text2 if m_dictionary_victory_switch_on?(@enemy.id)
        x      = WD_monsterdictionary_layout::M_help_display_x
        y      = WD_monsterdictionary_layout::M_help_display_y
        width  = WD_monsterdictionary_layout::M_help_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        i = 0
        if m_dictionary_victory_switch_on?(@enemy.id)
          @enemy.note.scan(/<図鑑説明:(.*)>/){|matched|
            i += 1
            self.contents.draw_text(x + font_size, y + font_size * i, width - font_size, font_size, matched[0], 0)
          }
        end
        if i == 0
          self.contents.draw_text(x + font_size, y + font_size, width - font_size, font_size, text2, 0)
        end
      end
      if WD_monsterdictionary_layout::M_geno_display
        text1  = WD_monsterdictionary_layout::M_geno_display_text1
        text2  = "#{m_dictionary_genoside_number(@enemy.id)}"
        x      = WD_monsterdictionary_layout::M_geno_display_x
        y      = WD_monsterdictionary_layout::M_geno_display_y
        width  = WD_monsterdictionary_layout::M_geno_display_width
        change_color(system_color)
        draw_text(x, y, width, font_size, text1, 0)
        change_color(normal_color)
        draw_text(x, y, width, font_size, text2, 2)
      end
 
    elsif @enemy != nil
 
      if WD_monsterdictionary_layout::M_id_display
        text1  = sprintf("%0#{WD_monsterdictionary_layout::M_id_display_digit}d",@index+1)
        x      = WD_monsterdictionary_layout::M_id_display_x
        y      = WD_monsterdictionary_layout::M_id_display_y
        width  = WD_monsterdictionary_layout::M_id_display_width
        height = line_height
        draw_text(x, y, width, height, text1, 0)
      end
      if WD_monsterdictionary_layout::M_name_display
        text1  = "- No Data -"
        x      = WD_monsterdictionary_layout::M_name_display_x
        y      = WD_monsterdictionary_layout::M_name_display_y
        width  = WD_monsterdictionary_layout::M_name_display_width
        height = line_height
        draw_text(x, y, width, height, text1, 0)
      end

    end
  end
end