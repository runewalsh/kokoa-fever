#==============================================================================
# ■カスタムメニューコマンド for RGSS3 Ver1.02
# □author kure
#===============================================================================
module KURE
  module Custom_Menu
    #初期設定(変更しない事)
    ADD_MENU = []
    
    #メニューコマンド順の設定---------------------------------------------------
    MENU_COMMAND = [0,1,2,3,7,8,4,5,6]
    
    #メニューのアイコンの設定---------------------------------------------------
    #アイコンの使用(0=使わない 1=使う)
    USE_ICON = 0
    
    #使用するアイコンのID配列
    USE_LIST = [261,232,170,233,0,229,0,261,232,0,0]
    
    #追加コマンドの設定
    #追加コマンドはADD_MENU[7]以降から追加してください。
    #ADD_MENU[7以降の数字] = [コマンド名,呼び出し方法,呼び出し名,表示スイッチ,有効スイッチ,呼び出し方法]
      #コマンド名　　メニューに表示されれる文字列
      #呼び出し方法　0=シーン呼び出し　1=コモンイベント呼び出し
      #呼び出し名　　シーン名(""で囲うこと)または、コモンイベントID
      #表示スイッチ　メニューに表示するためにONであるスイッチ、0なら常時表示
      #有効スイッチ　メニューを有効にするためのスイッチ、0なら常時有効
      #呼び出し方法　0=直接呼び出し　1=アクター選択
    
    #見本設定
    ADD_MENU[7] = ["Выбрать навыки", 0, "Scene_SkillMemorize", 0, 0, 1]
    ADD_MENU[8] = ["Распред. статы", 0, "Scene_Statusdivide", 0, 0, 0]
    

 
  end
end

#==============================================================================
# ■ Scene_Menu
#==============================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
    create_gold_window
    create_status_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window__k_Custom_MenuCommand.new
    @command_window.set_handler(:item,        method(:command_item))
    @command_window.set_handler(:skill,       method(:command_personal))
    @command_window.set_handler(:equip,       method(:command_personal))
    @command_window.set_handler(:status,      method(:command_personal))
    @command_window.set_handler(:formation,   method(:command_formation))
    @command_window.set_handler(:save,        method(:command_save))
    @command_window.set_handler(:game_end,    method(:command_game_end))
    @command_window.set_handler(:add_command, method(:command_add))
    @command_window.set_handler(:cancel,      method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● 呼び出し元のシーンへ戻る
  #--------------------------------------------------------------------------
  def return_scene
    $last_command_index = 0
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # ● コマンド［アイテム］
  #--------------------------------------------------------------------------
  def command_add
    #設定により呼び出し方法を変更
    add_data = KURE::Custom_Menu::ADD_MENU[@command_window.current_ext]
    
    #シーンの呼び出し
    if add_data[1] == 0
      #直接呼び出し
      if add_data[5] == 0
        call = "SceneManager.call(" + add_data[2] +")"
        eval(call)
      end
      #アクターを選択して呼び出し
      if add_data[5] == 1
        command_personal
      end
    end
    
    #コモンイベント呼び出し
    if add_data[1] == 1
      common_event = add_data[2]
      $game_temp.reserve_common_event(common_event) if common_event
      SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
    end  
  end
  #--------------------------------------------------------------------------
  # ● コマンド［スキル］［装備］［ステータス］
  #--------------------------------------------------------------------------
  def command_personal
    @status_window.select_last
    @status_window.activate
    @status_window.set_handler(:ok,     method(:on_personal_ok))
    @status_window.set_handler(:cancel, method(:on_personal_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 個人コマンド［決定］
  #--------------------------------------------------------------------------
  def on_personal_ok
    case @command_window.current_symbol
    when :skill
      SceneManager.call(Scene_Skill)
    when :equip
      SceneManager.call(Scene_Equip)
    when :status
      SceneManager.call(Scene_Status)
    when :add_command
      add_data = KURE::Custom_Menu::ADD_MENU[@command_window.current_ext]
      call = "SceneManager.call(" + add_data[2] +")"
      eval(call)
    end
  end
end


#==============================================================================
# ■ Window_k_Custom_MenuCommand(新規)
#==============================================================================
class Window__k_Custom_MenuCommand < Window_MenuCommand
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    $last_command_index = index
    super
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select($last_command_index)
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_commands
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def add_commands
    for command in 0..KURE::Custom_Menu::MENU_COMMAND.size - 1
      case KURE::Custom_Menu::MENU_COMMAND[command]
      when 0
        add_command(Vocab::item,   :item,   main_commands_enabled, 0)
      when 1
        add_command(Vocab::skill,  :skill,  main_commands_enabled, 1)
      when 2
        add_command(Vocab::equip,  :equip,  main_commands_enabled, 2)
      when 3
        add_command(Vocab::status, :status, main_commands_enabled, 3)
      when 4
        add_command(Vocab::formation, :formation, formation_enabled, 4)
      when 5
        add_command(Vocab::save, :save, save_enabled, 5)
      when 6
        add_command(Vocab::game_end, :game_end, true ,6)
      when 7..KURE::Custom_Menu::ADD_MENU.size
        vocab = KURE::Custom_Menu::ADD_MENU[KURE::Custom_Menu::MENU_COMMAND[command]][0]
        view_swith_id = KURE::Custom_Menu::ADD_MENU[KURE::Custom_Menu::MENU_COMMAND[command]][3]
        enabled_swith_id = KURE::Custom_Menu::ADD_MENU[KURE::Custom_Menu::MENU_COMMAND[command]][4]
        select_type = KURE::Custom_Menu::ADD_MENU[KURE::Custom_Menu::MENU_COMMAND[command]][5]
        
        if $game_switches[view_swith_id] or view_swith_id == 0
          if $game_switches[enabled_swith_id] == true or enabled_swith_id == 0
            if select_type == 1
              add_command(vocab, :add_command, main_commands_enabled, KURE::Custom_Menu::MENU_COMMAND[command])
            else
              add_command(vocab, :add_command, true, KURE::Custom_Menu::MENU_COMMAND[command])
            end
          else
            add_command(vocab, :add_command, false, KURE::Custom_Menu::MENU_COMMAND[command])
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    if KURE::Custom_Menu::USE_ICON == 1
      draw_icon(KURE::Custom_Menu::USE_LIST[@list[index][:ext]], 0, line_height * index)
    end
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得（テキスト用）
  #--------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 4
    rect.x += 24 if KURE::Custom_Menu::USE_ICON == 1
    rect.width -= (rect.x + 4)
    rect
  end
end

