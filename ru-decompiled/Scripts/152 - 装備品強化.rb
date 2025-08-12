#==============================================================================
# ■装備品強化システム for RGSS3 Ver2.00-β9
# □author kure
#
#　呼び出し方法 　SceneManager.call(Scene_Custom_Equip)
#
#===============================================================================
module KURE
  module Custom_Equip
    #初期設定(変更しない事)-----------------------------------------------------
    VIEW_LIST = []
    
    #表示に関する項目-----------------------------------------------------------
    #スロットタイプの表示名設定
    #SLOT_TYPE_NAME_LIST = [タイプ0,タイプ1,タイプ2,…]
    SLOT_TYPE_NAME_LIST = ["Оружие","盾","頭","体","Аксессуар","Значок"]
    
    #表示するスロットタイプリストを保存している変数(設定しない場合は0)
    VIEW_SLOT_LIST_NUM = 0
    
    #表示するリスト(VIEW_LIST[0]はVIEW_SLOT_LIST_NUMが0の時にも呼び出されます)
    VIEW_LIST[0] = [0,1,2,3,4,5]
    
    #スロットタイプの１ページ表示項目数
    VIEW_1PAGE_ITEM = 5
    
    #強化項目の表示内容
    #強化値の名称
    REIN_FORCED_NAME = "精錬"
  end
end

#==============================================================================
# ●■ RPG::EquipItem(追加定義集積)
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ◇ 強化コストの定義(追加定義)
  #--------------------------------------------------------------------------  
  def reinforce_cost
    cheack_note = base_note
    base_list = Array.new
    base_list[0] = [0,1000]
    for i in 1..8
      base_list[i] = [0,100]
    end
    #メモ欄から配列を作成
    cheack_note.match(/<強化コスト強化値\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[0] = [0,$2.to_i]
      when "G"
        base_list[0] = [1,$2.to_i]
      when "I"
        base_list[0] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト0\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[1] = [0,$2.to_i]
      when "G"
        base_list[1] = [1,$2.to_i]
      when "I"
        base_list[1] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト1\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[2] = [0,$2.to_i]
      when "G"
        base_list[2] = [1,$2.to_i]
      when "I"
        base_list[2] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト2\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[3] = [0,$2.to_i]
      when "G"
        base_list[3] = [1,$2.to_i]
      when "I"
        base_list[3] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト3\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[4] = [0,$2.to_i]
      when "G"
        base_list[4] = [1,$2.to_i]
      when "I"
        base_list[4] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト4\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[5] = [0,$2.to_i]
      when "G"
        base_list[5] = [1,$2.to_i]
      when "I"
        base_list[5] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト5\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[6] = [0,$2.to_i]
      when "G"
        base_list[6] = [1,$2.to_i]
      when "I"
        base_list[6] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト6\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[7] = [0,$2.to_i]
      when "G"
        base_list[7] = [1,$2.to_i]
      when "I"
        base_list[7] = [2,$2.to_i]
      end
    end
    
    cheack_note.match(/<強化コスト7\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        base_list[8] = [0,$2.to_i]
      when "G"
        base_list[8] = [1,$2.to_i]
      when "I"
        base_list[8] = [2,$2.to_i]
      end
    end

    return base_list  
  end
  #--------------------------------------------------------------------------
  # ◇ 特徴付与の定義(追加定義)
  #--------------------------------------------------------------------------  
  def reinforce_feature
    save_list = Array.new
    cheack_note = base_note
    while cheack_note do
      cheack_note.match(/<特徴付与\s?(\d+)\s?,\s?(\d+),\s?\s?([1-9]\d*|0)(\.\d+)?\s?,\s?([EGI])\s?,\s?(\d+)\s?>/)
      if $1 && $2 && $3 && $5 && $6
        code = $1.to_i
        data_id = $2.to_i
        value = $3.to_f
        value += $4.to_f if $4
        
        case $5.upcase
        when "E"
          cost_tyape = 0
        when "G"
          cost_tyape = 1
        when "I"
          cost_tyape = 2
        end
        
        cost = $6.to_i
      
        save_list.push([code, data_id, value, cost_tyape, cost])
      end
      cheack_note = $'
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ◇ 接頭語付与の定義(追加定義)
  #--------------------------------------------------------------------------  
  def reinforce_name_value
    save_list = Array.new
    cheack_note = base_note
    while cheack_note do
      cheack_note.match(/<接頭語付与\s?(\d+)\s?,\s?(\d+)\s?,\s?([EGI])\s?,\s?(\d+)\s?>/)
      if $1 && $2 && $3 && $4
        list = $1.to_i
        code = $2.to_i
        
        case $3.upcase
        when "E"
          cost_tyape = 0
        when "G"
          cost_tyape = 1
        when "I"
          cost_tyape = 2
        end
        
        cost = $4.to_i
      
        save_list.push([list, code, cost_tyape, cost])
      end
      cheack_note = $'
    end
    return save_list    
  end
  #--------------------------------------------------------------------------
  # ◇ スロット追加の定義(追加定義)
  #--------------------------------------------------------------------------  
  def reinforce_slot
    save_list = Array.new
    cheack_note = base_note
      
    cheack_note.match(/<スロット追加\s?([EGI])\s?,\s?(\d+)\s?>/)
    if $1 && $2
      case $1.upcase
      when "E"
        save_list[0] = 0
      when "G"
        save_list[0] = 1
      when "I"
        save_list[0] = 2
      end
      
      save_list[1] = $2.to_i
    end
    return save_list    
  end
end

#==============================================================================
# ■ Scene_Custom_Equip
#==============================================================================
class Scene_Custom_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_pop_window
    create_equip_type_window
    create_gold_window
    create_equip_list_window
    create_select_window
    
    set_window_task
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text("装備品カテゴリを選択してください")
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_pop_window
    wx = Graphics.width / 4 - 10
    wy = Graphics.height / 3
    width = Graphics.width / 2 + 20
    height = 24 * 6
    @pop_up_window = Window_k_Custom_Equip_PopupWindow.new(wx,wy,width,height)
    @pop_up_window.z += 150
    @pop_up_window.back_opacity = 255
    @pop_up_window.refresh
    @pop_up_window.hide
    
    @decide_window = Window_k_Custom_Equip_DecideCommand.new(wx,wy + height - 48,width,48)
    @decide_window.opacity = 0
    @decide_window.z += 150
    @decide_window.deactivate
    @decide_window.hide
    
    #ハンドラのセット
    @decide_window.set_handler(:cancel,   method(:pop_up_cancel))
    @decide_window.set_handler(:ok,   method(:pop_up_ok))    
  end
  #--------------------------------------------------------------------------
  # ● 装備タイプ選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_equip_type_window   
    @equip_type_window = Window_k_Custom_Equip_Type_Command.new(0, @help_window.height)
    @equip_type_window.viewport = @viewport
    
    @equip_type_window.deactivate
    @equip_type_window.unselect
    #呼び出しのハンドラをセット
    @equip_type_window.set_handler(:cancel,method(:on_equip_type_cancel))
    @equip_type_window.set_handler(:ok,method(:select_equip_type))
  end
  #--------------------------------------------------------------------------
  # ● 所持金ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gold_window  
    @gold_window = Window_k_Custom_Equip_Gold.new(0, Graphics.height - 48, 225)
  end
  #--------------------------------------------------------------------------
  # ● 装備リストウィンドウの作成
  #--------------------------------------------------------------------------
  def create_equip_list_window
    wy = @help_window.height + @equip_type_window.height
    @equip_list_window = Window_k_Custom_Equip_EquipList_Command.new(0, wy)
    @equip_list_window.height = Graphics.height - wy - @gold_window.height
    @equip_list_window.deactivate
    @equip_list_window.unselect
    @equip_list_window.viewport = @viewport    
    #呼び出しのハンドラをセット
    @equip_list_window.set_handler(:ok,method(:equip_list_command))
    @equip_list_window.set_handler(:cancel,method(:on_equip_list_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 強化ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_select_window
    wx = @equip_list_window.width
    wy = @help_window.height + @equip_type_window.height
    ww = Graphics.width - wx
    wh = Graphics.height - wy
    
    @back_ground_window = Window_k_Custom_Equip_Background.new(wx,wy,ww,wh)
    @reinforced_window = Window_k_Custom_Equip_Reinforced_Window.new(wx, wy + 48, ww, wh - 72)
    @reinforced_window.deactivate
    @reinforced_window.unselect
    @reinforced_window.opacity = 0
    @reinforced_window.z += 100 
    @reinforced_window.viewport = @viewport    
    #呼び出しのハンドラをセット
    @reinforced_window.set_handler(:ok,method(:reinforced_window_command))
    @reinforced_window.set_handler(:cancel,method(:on_reinforced_window_cancel))
  end  
  #--------------------------------------------------------------------------
  # ● ウィンドウのセッティング処理
  #--------------------------------------------------------------------------
  def set_window_task
    @equip_type_window.equip_list_window = @equip_list_window
    @equip_list_window.back_ground_window = @back_ground_window
    @equip_list_window.reinforced_window = @reinforced_window
    @reinforced_window.back_ground_window = @back_ground_window
    @pop_up_window.back_ground_window = @back_ground_window
    
    
    @equip_type_window.activate
    @equip_type_window.select(0)    
  end
  #--------------------------------------------------------------------------
  # ● 装備タイプ選択ウィンドウ[決定]
  #--------------------------------------------------------------------------
  def select_equip_type
    @equip_type_window.deactivate
    @equip_list_window.activate
    @equip_list_window.select(0)
    @help_window.set_text("装備品を選択してください")
  end
  #--------------------------------------------------------------------------
  # ● 装備タイプ選択ウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def on_equip_type_cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● 装備選択ウィンドウ[決定]
  #--------------------------------------------------------------------------
  def equip_list_command
    @equip_list_window.deactivate
    @reinforced_window.activate
    @reinforced_window.select(0)
    @help_window.set_text("強化する項目を選択してください")
  end
  #--------------------------------------------------------------------------
  # ● 装備選択ウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def on_equip_list_cancel
    @equip_type_window.activate
    @equip_list_window.deactivate
    @equip_list_window.unselect
    @reinforced_window.command_index = 1
    @help_window.set_text("装備品カテゴリを選択してください")
  end
  #--------------------------------------------------------------------------
  # ● 強化ウィンドウ[決定]
  #--------------------------------------------------------------------------
  def reinforced_window_command
    view_pop_up
  end
  #--------------------------------------------------------------------------
  # ● 強化ウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def on_reinforced_window_cancel
    @equip_list_window.activate
    @reinforced_window.deactivate
    @reinforced_window.unselect
    @help_window.set_text("装備品を選択してください")
  end
  #--------------------------------------------------------------------------
  # ● ポップアップを表示する
  #--------------------------------------------------------------------------
  def view_pop_up
    @reinforced_window.deactivate
    @pop_up_window.refresh
    @pop_up_window.show
    @decide_window.show
    @decide_window.activate
    @decide_window.select(1)
  end
  #--------------------------------------------------------------------------
  # ● ポップアップを閉じる
  #--------------------------------------------------------------------------
  def pop_up_close
    @pop_up_window.hide
    @decide_window.hide
    @decide_window.unselect
    @decide_window.deactivate
    @reinforced_window.activate
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[決定]
  #--------------------------------------------------------------------------
  def pop_up_ok
    case @decide_window.index
    when 0
      reinforced_item
      pop_up_close
    when 1
      pop_up_close
    end    
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def pop_up_cancel
    pop_up_close
  end
  #--------------------------------------------------------------------------
  # ● アイテムの強化処理
  #--------------------------------------------------------------------------
  def reinforced_item
    item = @back_ground_window.item
    param = @reinforced_window.current_ext
    master_container = $game_party.item_master_container(item.class)
    edit_item = master_container[item.identify_id]
    return unless edit_item
    
    #強化処理
    case param
    when 0..8
      edit_item.custom_param[param] += 1
      case edit_item.reinforce_cost[param][0]
      when 0
        edit_item.equip_exp = -1 * edit_item.reinforce_cost[param][1]
      when 1
        $game_party.lose_gold(edit_item.reinforce_cost[param][1])
        @gold_window.refresh
      when 2
        $game_party.lose_item($data_items[edit_item.reinforce_cost[param][1]], 1)
      end
    when 9..109
      code = edit_item.reinforce_feature[param - 9][0]
      data_id = edit_item.reinforce_feature[param - 9][1]
      value = edit_item.reinforce_feature[param - 9][2]
      edit_item.push_add_features(code, data_id, value)
      case edit_item.reinforce_feature[param - 9][3]
      when 0
        edit_item.equip_exp = -1 * edit_item.reinforce_feature[param - 9][4]
      when 1
        $game_party.lose_gold(edit_item.reinforce_feature[param - 9][4])
        @gold_window.refresh
      when 2
        $game_party.lose_item($data_items[edit_item.reinforce_feature[param - 9][4]], 1)
      end
      edit_item.reinforced_feature_list = param - 9
    when 110..210
      list = edit_item.reinforce_name_value[param - 110][0]
      code = edit_item.reinforce_name_value[param - 110][1]
      case edit_item.reinforce_name_value[param - 110][2]
      when 0
        edit_item.equip_exp = -1 * edit_item.reinforce_name_value[param - 110][3]
      when 1
        $game_party.lose_gold(edit_item.reinforce_name_value[param - 110][3])
        @gold_window.refresh
      when 2
        $game_party.lose_item($data_items[edit_item.reinforce_name_value[param - 110][3]], 1)
      end
      
      edit_item.add_name_value(list, code) if code != 0
      edit_item.delete_all_name_value if code == 0
    when 211
      case edit_item.reinforce_slot[0]
      when 0
        edit_item.equip_exp = -1 * edit_item.reinforce_slot[1]
      when 1
        $game_party.lose_gold(edit_item.reinforce_slot[1])
        @gold_window.refresh
      when 2
        $game_party.lose_item($data_items[edit_item.reinforce_slot[1]], 1)
      end
      edit_item.gain_slot_number
    end
    
    @reinforced_window.refresh
    @reinforced_window.activate
    @equip_list_window.refresh
    @back_ground_window.refresh
  end
end

#==============================================================================
# ■ Window_k_Custom_Equip_Type_Command
#==============================================================================
class Window_k_Custom_Equip_Type_Command < Window_HorzCommand
  attr_accessor :equip_list_window
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return KURE::Custom_Equip::VIEW_1PAGE_ITEM
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    return if index < 0
    @equip_list_window.equip_type = current_ext if @equip_list_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    if KURE::Custom_Equip::VIEW_SLOT_LIST_NUM == 0
      use_list = 0
    else
      use_list = $game_variables[KURE::Custom_Equip::VIEW_SLOT_LIST_NUM]
      use_list = 0 unless KURE::Custom_Equip::VIEW_LIST[use_list]
    end
    
    for i in 0..KURE::Custom_Equip::VIEW_LIST[use_list].size - 1
      add_command(KURE::Custom_Equip::SLOT_TYPE_NAME_LIST[KURE::Custom_Equip::VIEW_LIST[use_list][i]], :ok, true, KURE::Custom_Equip::VIEW_LIST[use_list][i])
    end
  end
end

#==============================================================================
# ■ Window_k_Custom_Equip_EquipList_Command
#==============================================================================
class Window_k_Custom_Equip_EquipList_Command < Window_Command
  attr_accessor :back_ground_window
  attr_accessor :reinforced_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    @equip_type = 0
    super(x,y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 225
  end
  #--------------------------------------------------------------------------
  # ◎ 装備タイプの設定
  #--------------------------------------------------------------------------
  def equip_type=(equip_type)
    return if @equip_type == equip_type
    @equip_type = equip_type
    refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_commands
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    @back_ground_window.item = current_ext if @back_ground_window
    @back_ground_window.command_index = 1 if @back_ground_window
    @reinforced_window.item = current_ext if @reinforced_window
    return if index < 0
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得（テキスト用）
  #--------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 28
    rect.width -= 32
    rect
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    change_color(power_up_color, command_enabled?(index)) if members_equip_include?(@list[index][:ext])
    draw_icon(@icon_list[index], 0, contents.font.size * index)
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # ● 指定アイテムがPT外メンバーの装備品に含まれているかを判定
  #--------------------------------------------------------------------------
  def other_members_equip_include?(item)
    all_actor = $data_actors.compact.collect {|obj| $game_actors[obj.id] }
    party_actor = $game_party.all_members
    cheacker_list = all_actor - party_actor
    
    return true if cheacker_list.any? {|actor| actor.equips.include?(item) }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 指定アイテムをPTメンバーが装備しているかを判定
  #--------------------------------------------------------------------------
  def members_equip_include?(item)
    party_actor = $game_party.all_members    
    return true if party_actor.any? {|actor| actor.equips.include?(item) }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 装備をリストに追加
  #--------------------------------------------------------------------------
  def add_commands
    master_w_list = $game_party.master_weapons_list
    master_a_list = $game_party.master_armors_list
    equip_list = Array.new
    
    for obj in 1..master_w_list.size - 1
      if master_w_list[obj]
        if other_members_equip_include?(master_w_list[obj]) == false
          equip_list.push(master_w_list[obj])
        end
      end
    end
    
    for obj in 1..master_a_list.size - 1
      if master_a_list[obj]
        if other_members_equip_include?(master_a_list[obj]) == false
          equip_list.push(master_a_list[obj])
        end
      end
    end
    
    equip_list.sort!{|a, b|
      a1 = $game_party.turn_item_id(a.id)
      b1 = $game_party.turn_item_id(b.id)
      if a1 != b1
        ret = a1 <=> b1
      else
        ret = a.identify_id <=> b.identify_id
      end
    }
    
    
    @icon_list = Array.new
    for item in 0..equip_list.size - 1
      if equip_list[item]
        if equip_list[item].etype_id == @equip_type
          add_command(equip_list[item].name, :ok, true, equip_list[item])
          @icon_list.push(equip_list[item].icon_index)
        end
      end
    end
  end
end

#==============================================================================
# ■ Window_k_Custom_Equip_Reinforced_Window(新規)
#==============================================================================
class Window_k_Custom_Equip_Reinforced_Window < Window_Command
  attr_accessor :back_ground_window
  attr_accessor :item
  attr_accessor :command_index
  attr_accessor :max_pages
  attr_accessor :first_line
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @width = width
    @height = height
    @identify_id = 0
    @first_line = 0
    @command_index = 1
    @max_pages = 1
    @make_list = []
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 描画するクラス の設定
  #--------------------------------------------------------------------------
  def identify_id=(identify_id)
    return if @identify_id == identify_id
    @identify_id = identify_id
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画するアイテムの設定
  #--------------------------------------------------------------------------
  def item=(item)
    return if @item == item
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画ページのINDEXの設定
  #--------------------------------------------------------------------------
  def command_index=(command_index)
    return if @command_index == command_index
    @command_index = command_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return @width
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return @height
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    return if index < 0
    @back_ground_window.draw_index = current_ext if @back_ground_window
  end
  #--------------------------------------------------------------------------
  # ● →キーの処理
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    @command_index += 1
    @command_index = 1 if @command_index > @max_pages
    @back_ground_window.command_index = @command_index if @back_ground_window
    self.index = 0
    refresh
    @back_ground_window.draw_index = current_ext if @back_ground_window
  end
  #--------------------------------------------------------------------------
  # ● ←キーの処理
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    @command_index -= 1
    @command_index = @max_pages if @command_index < 1
    @back_ground_window.command_index = @command_index if @back_ground_window
    self.index = 0
    refresh
    @back_ground_window.draw_index = current_ext if @back_ground_window
  end
  #--------------------------------------------------------------------------
  # ● 改造条件判定を持っているか
  #--------------------------------------------------------------------------
  def can_custom_exp(param)
    #存在判定
    return false unless @item
    
    case param
    when 0
      #判定
      case @item.reinforce_cost[param][0]
      when 0
        return false if @item.reinforce_cost[param][1] > @item.equip_exp
      when 1
        return false if @item.reinforce_cost[param][1] > $game_party.gold
      when 2
        return false if $game_party.item_number($data_items[@item.reinforce_cost[param][1]]) == 0
      end
      #上限判定
      return false if @item.custom_param[param] >= @item.add_plus_limit
    when 1..8
      #装備EXP判定
      case @item.reinforce_cost[param][0]
      when 0
        return false if @item.reinforce_cost[param][1] > @item.equip_exp
      when 1
        return false if @item.reinforce_cost[param][1] > $game_party.gold
      when 2
        return false if $game_party.item_number($data_items[@item.reinforce_cost[param][1]]) == 0
      end
      #上限判定
      return false if @item.custom_param[param] >= @item.add_plus_revise_limit[param - 1]
    when 9..109
      return false if @item.reinforced_feature_list.include?(param - 9)
      #装備EXP判定
      case @item.reinforce_feature[param - 9][3]
      when 0
        return false if @item.reinforce_feature[param - 9][4] > @item.equip_exp
      when 1
        return false if @item.reinforce_feature[param - 9][4] > $game_party.gold
      when 2
        return false if $game_party.item_number($data_items[@item.reinforce_feature[param - 9][4]]) == 0 
      end
    when 110..210
      case @item.reinforce_name_value[param - 110][2]
      when 0
        return false if @item.reinforce_name_value[param - 110][3] > @item.equip_exp
      when 1
        return false if @item.reinforce_name_value[param - 110][3] > $game_party.gold
      when 2
        return false if $game_party.item_number($data_items[@item.reinforce_name_value[param - 110][3]]) == 0 
      end
    when 211
      case @item.reinforce_slot[0]
      when 0
        return false if @item.reinforce_slot[1] > @item.equip_exp
      when 1
        return false if @item.reinforce_slot[1] > $game_party.gold
      when 2
        return false if $game_party.item_number($data_items[@item.reinforce_slot[1]]) == 0 
      end
      #上限判定
      return @item.gain_slot?
    end
    
    return true
  end
  #--------------------------------------------------------------------------
  # ● 付与済み判定
  #--------------------------------------------------------------------------
  def used_custom(param)
    #存在判定
    return false unless @item
    case param
    when 9..109
      return true if @item.reinforced_feature_list.include?(param - 9)
      return false
    when 211
      return true unless @item.gain_slot?
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    @max_line = (@height / 24).to_i - 1
    draw_line = 0
    @first_line = @max_line * (@command_index - 1) 
    @make_list = []
    
    if @item
      #強化判定
      if @item.add_plus_limit != 0
        @make_list.push([can_custom_exp(0) , 0])
        draw_line += 1
      end
      
      #ステータスの存在判定
      for i in 1..8
        if @item.reinforce_param.include?(i - 1)
          @make_list.push([can_custom_exp(i) , i])
          draw_line += 1
        end
        if @item.reinforce_param == ([] or empty?)
          @make_list.push([can_custom_exp(i) , i])
          draw_line += 1
        end
      end
      
      #特徴の付与判定
      feature_list = @item.reinforce_feature
      if feature_list != ([] or empty?)
        for f in 0..feature_list.size - 1
          if f < 101
            @make_list.push([can_custom_exp(9 + f), 9 + f, feature_list[f], used_custom(9 + f)])
            draw_line += 1
          end
        end
      end
      
      #接頭語の付与判定
      name_value_list = @item.reinforce_name_value
      if name_value_list != ([] or empty?)
        for n in 0..name_value_list.size - 1
          if n < 101
            @make_list.push([can_custom_exp(110 + n), 110 + n, name_value_list[n]])
            draw_line += 1
          end
        end
      end
      
      #スロット付与の判定
      slot_list = @item.reinforce_slot
      if slot_list != ([] or empty?)
        @make_list.push([can_custom_exp(211), 211, slot_list, used_custom(211)])
        draw_line += 1
      end
      
    end
    
    last_line = [@first_line + @max_line - 1, @make_list.size - 1].min
    for i in @first_line..last_line
      add_command(" ", :ok, @make_list[i][0], @make_list[i][1])
    end
    
    #最大ページ数とリストを更新する
    @max_pages = 1
    if draw_line > @max_line
      #最初のページの項目数を引く
      draw_line -= @max_line
      
      #項目が残っていればページを追加
      while draw_line > 0 do
        draw_line -= @max_line
        @max_pages += 1
      end
    end
    
    @back_ground_window.first_line = @first_line if @back_ground_window
    @back_ground_window.max_pages = @max_pages if @back_ground_window
    @back_ground_window.make_list = @make_list if @back_ground_window
    @back_ground_window.max_line = @max_line if @back_ground_window
  end
end

#==============================================================================
# ■ Window_k_Custom_Equip_Background
#==============================================================================
class Window_k_Custom_Equip_Background < Window_Base
  attr_accessor :item
  attr_accessor :draw_index
  attr_accessor :command_index
  attr_accessor :max_pages
  attr_accessor :make_list
  attr_accessor :first_line
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @item = nil
    @draw_index = 0
    @first_line = 0
    @command_index = 1
    @max_pages = 1
    @max_line = 9
    @make_list = []
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画するアイテムの設定
  #--------------------------------------------------------------------------
  def item=(item)
    return if @item == item
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画するINDEXの設定
  #--------------------------------------------------------------------------
  def draw_index=(draw_index)
    return if @draw_index == draw_index
    @draw_index = draw_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画ページのINDEXの設定
  #--------------------------------------------------------------------------
  def command_index=(command_index)
    return if @command_index == command_index
    @command_index = command_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 最大ページ数の設定
  #--------------------------------------------------------------------------
  def max_pages=(max_pages)
    return if @max_pages == max_pages
    @max_pages = max_pages
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 最大ライン数の設定
  #--------------------------------------------------------------------------
  def max_line=(max_line)
    return if @max_line == max_line
    @max_line = max_line
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画する項目の設定
  #--------------------------------------------------------------------------
  def make_list=(make_list)
    return if @make_list == make_list
    @make_list = make_list
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 最初に描画する項目の設定
  #--------------------------------------------------------------------------
  def first_line=(first_line)
    return if @first_line == first_line
    @first_line = first_line
    refresh
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    
    #共通描画
    draw_gauge(0,0, contents.width, 1, mp_gauge_color2,crisis_color)
    change_color(normal_color)
    draw_text(0,0, 200, line_height, "強化項目")
        
    draw_text(0, contents.height - line_height , contents.width, line_height, "←　→: Страница (" + (@command_index).to_s + " / " + @max_pages.to_s + ")" ,1)
    
    #ステータスの表記
    if @make_list != ([] or empty?)
      draw_line = 0
      last_line = [@first_line + @max_line - 1, @make_list.size - 1].min
      for list in @first_line..last_line
        #ハッシュされた追加データにより描画内容を変更
        if @make_list[list][1]
          case @make_list[list][1]
          when 0
            change_color(system_color,@make_list[list][0])
            draw_text(0,line_height * (2 + draw_line), 70, line_height, KURE::Custom_Equip::REIN_FORCED_NAME)
            draw_text(115, line_height * (2 + draw_line), 25, line_height, "→", 1)
            change_color(normal_color)
            draw_line += 1
          when 1..8
            change_color(system_color,@make_list[list][0])
            draw_text(0,line_height * (2 + draw_line), 70, line_height, Vocab::param(@make_list[list][1] - 1))
            draw_text(115, line_height * (2 + draw_line), 25, line_height, "→", 1)
            change_color(normal_color)
            draw_line += 1
          when 9..109
            draw_list_name = "特徴"
            if @make_list[list][2]
              case @make_list[list][2][0]
              when 41
                draw_list_name = "許可"
              when 42
                draw_list_name = "封印"
              when 43
                draw_list_name = "追加"
              when 44
                draw_list_name = "削除"
              end
            end
            
            change_color(system_color,@make_list[list][0])
            draw_text(0,line_height * (2 + draw_line), 40, line_height, draw_list_name)
            change_color(normal_color)
            draw_line += 1
          when 110..210
            draw_list_name = "付与"
            if @make_list[list][2]
              draw_list_name = "消去" if @make_list[list][2][1] == 0
            end
            
            change_color(system_color,@make_list[list][0])
            draw_text(0,line_height * (2 + draw_line), 40, line_height, draw_list_name)
            change_color(normal_color)
            draw_line += 1
          when 211
            draw_list_name = "付与"            
            change_color(system_color,@make_list[list][0])
            draw_text(0,line_height * (2 + draw_line), 40, line_height, draw_list_name)
            change_color(normal_color)
            draw_line += 1
          end
        end
      end
    end
    
    return unless @item
    return unless @draw_index
    #以下アイテムがある場合の描画
    
    #アイテムの描画
    master_container = $game_party.item_master_container(item.class)
    draw_item = master_container[@item.identify_id]
    draw_item_name(draw_item, 4, line_height)
    
    #アイテムのExpを描画
    change_color(system_color)
    draw_text(contents.width - 90, line_height, 30, line_height, "EXP",1)
    change_color(normal_color)
    draw_text(contents.width - 60, line_height, 60, line_height, draw_item.equip_exp, 2)
    
    #項目の描画
    rein_force_all = draw_item.add_plus_revise_all
    rein_force_param = draw_item.add_plus_revise
    
    #ステータスの表記
    if @make_list != ([] or empty?)
      draw_line = 0
      last_line = [@first_line + @max_line - 1, @make_list.size - 1].min
      for list in @first_line..last_line
        #ハッシュされた追加データにより描画内容を変更
        if @make_list[list][1]
          case @make_list[list][1]
          when 0
            text = draw_item.custom_num
            text2 = draw_item.custom_num
            if @draw_index == 0
              text2 = text + 1 if draw_item.add_plus_limit >= draw_item.custom_num
            end
            change_color(normal_color,@make_list[list][0])
            draw_text(75,line_height * (2 + draw_line), 35, line_height, text, 2)
      
            change_color(param_change_color(text2 - text),@make_list[list][0])
            draw_text(145,line_height * (2 + draw_line), 35, line_height, text2, 2)
      
            case draw_item.reinforce_cost[@make_list[list][1]][0]
            when 0
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 100, line_height * (2 + draw_line), 60, line_height, draw_item.reinforce_cost[@make_list[list][1]][1], 2)
              change_color(system_color,@make_list[list][0])
              draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, "Exp", 1)
            when 1
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 100, line_height * (2 + draw_line), 60, line_height, draw_item.reinforce_cost[@make_list[list][1]][1], 2)
              change_color(system_color,@make_list[list][0])
              draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, Vocab::currency_unit, 1)
            when 2
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 100, line_height * (2 + draw_line), 100, line_height, $data_items[draw_item.reinforce_cost[@make_list[list][1]][1]].name, 2)
            end
            draw_line += 1
          when 1..8
            text = draw_item.params[@make_list[list][1] - 1]
            add = 0
            if @draw_index == 0
              add = rein_force_all
              add = rein_force_param[@make_list[list][1] - 1] if rein_force_param[@make_list[list][1] - 1]
              add = 0 if @item.custom_param[0] >= @item.add_plus_limit
            else
              add = 1 if @draw_index == @make_list[list][1]
              add = 0 if @item.custom_param[@make_list[list][1] - 1] >= @item.add_plus_revise_limit[@make_list[list][1] - 1]
            end
            text2 = text + add    
            
            change_color(normal_color,@make_list[list][0])
            draw_text(75,line_height * (2 + draw_line), 35, line_height, text, 2)
      
            change_color(param_change_color(text2 - text),@make_list[list][0])
            draw_text(145,line_height * (2 + draw_line), 35, line_height, text2, 2)
      
            case draw_item.reinforce_cost[@make_list[list][1]][0]
            when 0
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 100, line_height * (2 + draw_line), 60, line_height, draw_item.reinforce_cost[@make_list[list][1]][1], 2)
              change_color(system_color,@make_list[list][0])
              draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, "Exp", 1)
            when 1
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 100, line_height * (2 + draw_line), 60, line_height, draw_item.reinforce_cost[@make_list[list][1]][1], 2)
              change_color(system_color,@make_list[list][0])
              draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, Vocab::currency_unit, 1)
            when 2
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 100, line_height * (2 + draw_line), 100, line_height, $data_items[draw_item.reinforce_cost[@make_list[list][1]][1]].name, 2)
            end
            draw_line += 1
          when 9..109
            rein_forace = draw_item.reinforce_feature[@make_list[list][1] - 9]
            return unless rein_forace
            code = rein_forace[0]
            data_id = rein_forace[1]
            value = rein_forace[2]
            cost_type = rein_forace[3]
            cost = rein_forace[4]
            
            case code
            when 11
              draw_str = $data_system.elements[data_id]+ "耐性"
              value = (100 - (value * 100).to_i).to_s + "%"
            when 12
              draw_str = Vocab::param(data_id)+ "減少耐性"
              value = (100 - (value * 100).to_i).to_s + "%"        
            when 13
              draw_str = $data_states[data_id].name+ "耐性"
              value = (100 - (value * 100).to_i).to_s + "%"   
            when 14
              draw_str = $data_states[data_id].name+ "無効"
              value = ""
            when 21
              draw_str = Vocab::param(data_id)
              value = (value * 100).to_i - 100
              if value > 0
                value = "+" + value.to_s
              end
              value = value.to_s + "%"
            when 22
              draw_str = data_id
              case draw_str
              when 0
                draw_str = "Меткость"
              when 1
                draw_str = "Уворот"
              when 2
                draw_str = "Крит. шанс"
              when 3
                draw_str = "会心回避"             
              when 4
                draw_str = "魔法回避"
              when 5
                draw_str = "魔法反射"
              when 6
                draw_str = "反撃率"
              when 7
                draw_str = "毎ﾀｰﾝHP回復"
              when 8
                draw_str = "毎ﾀｰﾝMP回復"
              when 9
                draw_str = "毎ﾀｰﾝTP回復"
              end
              value = (value * 100).to_i
              if value > 0
                value = "+" + value.to_s
              end
              value = value.to_s + "%"
            when 23  
              draw_str = data_id
              case draw_str
              when 0
                draw_str = "狙われ率" 
              when 1
                draw_str = "防御効果"
              when 2
                draw_str = "回復効果"
              when 3
                draw_str = "薬知識"
              when 4
                draw_str = "MP消費率"
              when 5
                draw_str = "TP上昇率"
              when 6
                draw_str = "被物理Dmg"
              when 7
                draw_str = "被魔法Dmg"
              when 8
                draw_str = "床Dmg"
              when 9
                draw_str = "経験値"
              end
              value = (value * 100).to_i - 100
              if value > 0
                value = "+" + value.to_s
              end
              value = value.to_s + "%"
            when 31
              draw_str  = $data_system.elements[data_id] + "属性付与"
              value = ""
            when 32
              draw_str = $data_states[data_id].name + "追加"
              value = ((value * 100).to_i).to_s + "%"
            when 34
              draw_str = "攻撃追加"
              value = (value.to_i).to_s + "回" 
            when 41
              draw_str = $data_system.skill_types[data_id]
              value = ""
            when 42
              draw_str = $data_system.skill_types[data_id]
              value = ""
            when 43
              draw_str = $data_skills[data_id].name 
              value = ""
            when 44  
              draw_str = $data_skills[data_id].name
              value = ""
            when 61
              draw_str = "行動追加" + ((value * 100).to_i).to_s + "%"
              value = ""
            when 62
              case data_id
              when 0
                draw_str = "自動戦闘"
              when 1
                draw_str = "自動防御"
              when 2
                draw_str = "自動献身"
              when 3
                draw_str = "TP持ち越し"
              end
              value = ""
            when 64
              case data_id 
              when 0
                draw_str = "エンカウント半減"
              when 1
                draw_str = "エンカウント無効"
              when 2
                draw_str = "不意打ち無効"
              when 3
                draw_str = "先制率上昇"
              when 4
                draw_str = "獲得金額2倍"              
              when 5
                draw_str = "アイテム獲得率2倍"              
              when 6
              end
              value = ""
            end  
            
            change_color(normal_color,@make_list[list][0])
            draw_text(45,line_height * (2 + draw_line), contents.width - 170, line_height, draw_str + value)                  
            
            if @make_list[list][3]
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 140, line_height * (2 + draw_line), 140, line_height, "付与済み", 2)
            else
              case cost_type
              when 0
                change_color(normal_color,@make_list[list][0])
                draw_text(contents.width - 140, line_height * (2 + draw_line), 100, line_height, cost, 2)
                change_color(system_color,@make_list[list][0])
                draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, "Exp", 1)
              when 1
                change_color(normal_color,@make_list[list][0])
                draw_text(contents.width - 140, line_height * (2 + draw_line), 100, line_height, cost, 2)
                change_color(system_color,@make_list[list][0])
                draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, Vocab::currency_unit, 1)
              when 2
                change_color(normal_color,@make_list[list][0])
                draw_text(contents.width - 140, line_height * (2 + draw_line), 140, line_height, $data_items[cost].name, 2)
              end
            end
            

            draw_line += 1
          when 110..210
            name_value = draw_item.reinforce_name_value[@make_list[list][1] - 110]
            return unless name_value
            list = name_value[0]
            code = name_value[1]
            cost_type = name_value[2]
            cost = name_value[3]
            
            draw_str = "能力消去" if code == 0
            
            if code != 0
              case KURE::SortOut::NAME_VALUE_LIST[list][code][0]
              when "W"
                draw_str = $data_weapons[KURE::SortOut::NAME_VALUE_LIST[list][code][1]].name
              when "A"
                draw_str = $data_armors[KURE::SortOut::NAME_VALUE_LIST[list][code][1]].name
              end
            end
          
            change_color(normal_color,@make_list[list][0])
            draw_text(45,line_height * (2 + draw_line), contents.width - 170, line_height, draw_str)
            
            case cost_type
            when 0
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 140, line_height * (2 + draw_line), 100, line_height, cost, 2)
              change_color(system_color,@make_list[list][0])
              draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, "Exp", 1)
            when 1
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 140, line_height * (2 + draw_line), 100, line_height, cost, 2)
              change_color(system_color,@make_list[list][0])
              draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, Vocab::currency_unit, 1)
            when 2
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 140, line_height * (2 + draw_line), 140, line_height, $data_items[cost].name, 2)
            end
            draw_line += 1
          when 211
            add_slot = draw_item.reinforce_slot
            return unless add_slot
            
            draw_str = "スロット追加"
            change_color(normal_color,@make_list[list][0])
            draw_text(45,line_height * (2 + draw_line), contents.width - 170, line_height, draw_str)
            
            cost_type = add_slot[0]
            cost = add_slot[1]
            
            if @make_list[list][3]
              change_color(normal_color,@make_list[list][0])
              draw_text(contents.width - 140, line_height * (2 + draw_line), 140, line_height, "拡張不可", 2)
            else
              case cost_type
              when 0
                change_color(normal_color,@make_list[list][0])
                draw_text(contents.width - 140, line_height * (2 + draw_line), 100, line_height, cost, 2)
                change_color(system_color,@make_list[list][0])
                draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, "Exp", 1)
              when 1
                change_color(normal_color,@make_list[list][0])
                draw_text(contents.width - 140, line_height * (2 + draw_line), 100, line_height, cost, 2)
                change_color(system_color,@make_list[list][0])
                draw_text(contents.width - 40, line_height * (2 + draw_line), 40, line_height, Vocab::currency_unit, 1)
              when 2
                change_color(normal_color,@make_list[list][0])
                draw_text(contents.width - 140, line_height * (2 + draw_line), 140, line_height, $data_items[cost].name, 2)
              end
            end
            draw_line += 1
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目描画パターン１(強化)
  #--------------------------------------------------------------------------
  def draw_pattern
    
  end
end


#==============================================================================
# ■ Window_k_Custom_Equip_PopupWindow
#==============================================================================
class Window_k_Custom_Equip_PopupWindow < Window_Base
  attr_accessor :back_ground_window
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    item = @back_ground_window.item if @back_ground_window
    draw_index = @back_ground_window.draw_index if @back_ground_window
    
    draw_gauge(5, 0, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, 0, contents.width, line_height, "強化項目確認")
    
    if item
      draw_item_name(item, 5, line_height)
      
      #描画用のLv設定
      case draw_index
      when 0
        param_name = KURE::Custom_Equip::REIN_FORCED_NAME + "強化"
        exp_value = item.reinforce_cost[draw_index][1]
        cost_text = item.reinforce_cost[draw_index][0]
      when 1..8
        param_name = Vocab::param(draw_index - 1) + "強化"
        exp_value = item.reinforce_cost[draw_index][1]
        cost_text = item.reinforce_cost[draw_index][0]
      when 9..109
        list = item.reinforce_feature
        cost_text = list[draw_index - 9][3]
        param_name = "特徴付与"
        case list[draw_index - 9][0]
        when 41
          param_name = "使用許可"
        when 42
          param_name = "使用封印"
        when 43
          param_name = "スキル追加"
        when 44
          param_name = "スキル削除"
        end
        exp_value = list[draw_index - 9][4]
        
        cost = list[draw_index - 9][0]
        data_id = list[draw_index - 9][1]
        value = list[draw_index - 9][2]
        case list[draw_index - 9][0]
        when 11
          draw_str = $data_system.elements[data_id]+ "耐性"
          value = (100 - (value * 100).to_i).to_s + "%"
        when 12
          draw_str = Vocab::param(data_id)+ "減少耐性"
          value = (100 - (value * 100).to_i).to_s + "%"        
        when 13
          draw_str = $data_states[data_id].name+ "耐性"
          value = (100 - (value * 100).to_i).to_s + "%"   
        when 14
          draw_str = $data_states[data_id].name+ "無効"
          value = ""
        when 21
          draw_str = Vocab::param(data_id)
          value = (value * 100).to_i - 100
          if value > 0
            value = "+" + value.to_s
          end
          value = value.to_s + "%"
        when 22
          draw_str = data_id
          case draw_str
          when 0
            draw_str = "Меткость"
          when 1
            draw_str = "Уворот"
          when 2
            draw_str = "Крит. шанс"
          when 3
            draw_str = "会心回避"             
          when 4
            draw_str = "魔法回避"
          when 5
            draw_str = "魔法反射"
          when 6
            draw_str = "反撃率"
          when 7
            draw_str = "毎ﾀｰﾝHP回復"
          when 8
            draw_str = "毎ﾀｰﾝMP回復"
          when 9
            draw_str = "毎ﾀｰﾝTP回復"
          end
          value = (value * 100).to_i
          if value > 0
            value = "+" + value.to_s
          end
          value = value.to_s + "%"
        when 23  
          draw_str = data_id
          case draw_str
          when 0
            draw_str = "狙われ率" 
          when 1
            draw_str = "防御効果"
          when 2
            draw_str = "回復効果"
          when 3
            draw_str = "薬知識"
          when 4
            draw_str = "MP消費率"
          when 5
            draw_str = "TP上昇率"
          when 6
            draw_str = "被物理Dmg"
          when 7
            draw_str = "被魔法Dmg"
          when 8
            draw_str = "床Dmg"
          when 9
            draw_str = "経験値"
          end
          value = (value * 100).to_i - 100
          if value > 0
            value = "+" + value.to_s
          end
          value = value.to_s + "%"
        when 31
          draw_str  = $data_system.elements[data_id] + "属性付与"
          value = ""
        when 32
          draw_str = $data_states[data_id].name + "追加"
          value = ((value * 100).to_i).to_s + "%"
        when 34
          draw_str = "攻撃追加"
          value = (value.to_i).to_s + "回" 
        when 41
          draw_str = $data_system.skill_types[data_id]
          value = ""
        when 42
          draw_str = $data_system.skill_types[data_id]
          value = ""
        when 43
          draw_str = $data_skills[data_id].name 
          value = ""
        when 44  
          draw_str = $data_skills[data_id].name
          value = ""
        when 61
          draw_str = "行動追加" + ((value * 100).to_i).to_s + "%"
          value = ""
        when 62
          case data_id
          when 0
            draw_str = "自動戦闘"
          when 1
            draw_str = "自動防御"
          when 2
            draw_str = "自動献身"
          when 3
            draw_str = "TP持ち越し"
          end
          value = ""
        when 64
          case data_id 
          when 0
            draw_str = "エンカウント半減"
          when 1
            draw_str = "エンカウント無効"
          when 2
            draw_str = "不意打ち無効"
          when 3
            draw_str = "先制率上昇"
          when 4
            draw_str = "獲得金額2倍"              
          when 5
            draw_str = "アイテム獲得率2倍"              
          when 6
          end
          value = ""
        end
        draw_text(85, line_height * 2, contents.width - 105, line_height, draw_str + value)
      when 110..210
        param_name = "接頭語"
        list = item.reinforce_name_value
        use_list = list[draw_index - 110][0]
        code = list[draw_index - 110][1]
        cost_text = list[draw_index - 110][2]
        exp_value = list[draw_index - 110][3]
        draw_str = "能力消去" if code == 0
        
        if code != 0
          case KURE::SortOut::NAME_VALUE_LIST[use_list][code][0]
          when "W"
            draw_str = $data_weapons[KURE::SortOut::NAME_VALUE_LIST[use_list][code][1]].name
          when "A"
            draw_str = $data_armors[KURE::SortOut::NAME_VALUE_LIST[use_list][code][1]].name
          end
        end
        
        draw_text(85, line_height * 2, contents.width - 105, line_height, draw_str)
      when 211
        param_name = "スロット追加"
        list = item.reinforce_slot
        cost_text = list[0]
        exp_value = list[1]
        
        draw_text(85, line_height * 2, contents.width - 105, line_height, draw_str)
      end
      draw_text(5, line_height * 2, 95, line_height, param_name)
      
      case cost_text
      when 0
        draw_text(5, line_height * 3, contents.width - 5, line_height, "必要武器Exp")
        draw_text(5, line_height * 3, contents.width - 5, line_height, exp_value, 2)
      when 1
        draw_text(5, line_height * 3, contents.width - 5, line_height, "必要" + Vocab::currency_unit)
        draw_text(5, line_height * 3, contents.width - 5, line_height, exp_value, 2)
      when 2
        draw_text(5, line_height * 3, contents.width - 5, line_height, "必要アイテム")
        draw_text(5, line_height * 3, contents.width - 5, line_height, $data_items[exp_value].name, 2)
      end
        
    end  
  end
end

#==============================================================================
# ■ Window_k_Custom_Equip_DecideCommand
#==============================================================================
class Window_k_Custom_Equip_DecideCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @width = width
    @height = height
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return @height
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return @width
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("強化する" , :ok ,true)
    add_command("やめる" , :ok ,true)
  end
end

#==============================================================================
# ■ Window_k_Custom_Equip_Gold
#==============================================================================
class Window_k_Custom_Equip_Gold < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, fitting_height(1))
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_currency_value(value, currency_unit, 4, 0, contents.width - 8)
  end
  #--------------------------------------------------------------------------
  # ● 所持金の取得
  #--------------------------------------------------------------------------
  def value
    $game_party.gold
  end
  #--------------------------------------------------------------------------
  # ● 通貨単位の取得
  #--------------------------------------------------------------------------
  def currency_unit
    Vocab::currency_unit
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを開く
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end