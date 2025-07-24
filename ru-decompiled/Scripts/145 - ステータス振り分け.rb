#==============================================================================
#  ■ステータス振り分け for RGSS3 Ver1.03-β5
#　□author kure
#
#　呼び出し方法 　SceneManager.call(Scene_Statusdivide)
#
#==============================================================================
module KURE
  module Statusdivide
  #基本設定---------------------------------------------------------------------
  PRAM = []
    
  #表示に関する項目
  #ゲームに使用する歩行グラフィックの高さ(RTPは32)
  GAME_CHARACTER_HEIGHT = 32
  
  #ステータスポイントの名前
  STATUS_POINT_NAME = "Status Point"
  
  #ステータスポイントの獲得に関する設定
  #LvUP時に獲得するステータスポイント
  LEVELUP_STATUS_POINT = 4
  
  #LvUPごとの獲得値補正(少数設定可)
  LEVELUP_STATUS_POINT_REVICE = 0.4
  
  
  #振り分けに関する設定---------------------------------------------------------
  #振り分けるパラメータID
  USE_DIVIDE_PARAM = [0,1,2,3,4,5,6,7]
  
  #PRAM[パラメータID] = [上昇量, 必要ポイント, ポイント上昇率, 振り分け上限]
  PRAM[0] = [4, 3, 0.13, 1000]
  PRAM[1] = [2, 2, 0.13, 1000]
  PRAM[2] = [1, 2, 0.06, 1000]
  PRAM[3] = [1, 1, 0.08, 1000]
  PRAM[4] = [1, 2, 0.04, 1000]
  PRAM[5] = [1, 1, 0.05, 1000]
  PRAM[6] = [1, 3, 0.13, 100]
  PRAM[7] = [1, 1, 0.13, 1000] 
  
  #巻き戻し(0=巻き戻しを許可しない 1=巻き戻しを許可する)
  POINT_BACK = 0
  
  end
end

#==============================================================================
# ●■ RPG::BaseItem(追加定義集積)
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 振り分けするステータスの種類設定(追加定義)
  #--------------------------------------------------------------------------  
  def divide_param_list
    save_list = Array.new
    return save_list unless @note
    list = @note.scan(/<振り分けパラメータ\s?(\d+(?:\s?*,\s?*\d+)*)>/)
    unless list == [] and list.empty? 
      list.flatten!
      for i in 0..list.size - 1
        list[i].scan(/\d+/).each { |num| save_list.push(num.to_i)}
      end
    end
    return save_list
  end
  #--------------------------------------------------------------------------
  # ● 振り分けするステータスの設定(追加定義)
  #--------------------------------------------------------------------------  
  def divide_param_setting
    param_setting = Array.new
    cheak_note = ""
    cheak_note = @note if @note
    
    #最大HP
    cheak_note.match(/<振り分け設定0\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[0] = nil
    param_setting[0] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4
    
    #最大MP
    cheak_note.match(/<振り分け設定1\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[1] = nil
    param_setting[1] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4
    
    #攻撃力
    cheak_note.match(/<振り分け設定2\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[2] = nil
    param_setting[2] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4
    
    #防御力
    cheak_note.match(/<振り分け設定3\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[3] = nil
    param_setting[3] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4    
    
    #魔法力
    cheak_note.match(/<振り分け設定4\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[4] = nil
    param_setting[4] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4
    
    #魔法防御力
    cheak_note.match(/<振り分け設定5\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[5] = nil
    param_setting[5] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4
    
    #敏捷性
    cheak_note.match(/<振り分け設定6\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[6] = nil
    param_setting[6] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4
    
    #運
    cheak_note.match(/<振り分け設定7\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?(\d+)\s?>/)
    param_setting[7] = nil
    param_setting[7] = [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if $1 && $2 && $3 && $4
    return param_setting
  end
end

#==============================================================================
# ■ Scene_Statusdivide
#==============================================================================
class Scene_Statusdivide < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super

    create_help_window
    create_ptm_window
    create_info_window
    create_param_window
    create_task_window
    
    window_setting
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text("ステータスを振り分けるキャラクターを選択してください")
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● パーティーメンバーウィンドウの作成
  #--------------------------------------------------------------------------
  def create_ptm_window
    @ptm_window = Window_ALLPartyMember_List.new(0,@help_window.height,Graphics.height - @help_window.height)
    
    #ハンドラのセット
    @ptm_window.set_handler(:cancel,   method(:ptm_cancel))
    @ptm_window.set_handler(:ok,   method(:ptm_ok))    
  end
  #--------------------------------------------------------------------------
  # ● インフォメーションウィンドウの作成
  #--------------------------------------------------------------------------
  def create_info_window
    wx = @ptm_window.width
    wy = @help_window.height
    ww = Graphics.width - @ptm_window.width
    wh = 48
    @info_window = Window_k_Statusdivide_InfoWindow.new(wx, wy, ww, wh)    
  end
  #--------------------------------------------------------------------------
  # ● パラメータウィンドウの作成
  #--------------------------------------------------------------------------
  def create_param_window
    wx = @ptm_window.width
    wy = @help_window.height + @info_window.height
    ww = Graphics.width - @ptm_window.width
    wh = Graphics.height - wy
    @param_window = Window_k_Statusdivide_ParamWindow.new(wx, wy, ww, wh)
    
    @devide_window = Window_k_Statusdivide_DivideWindow.new(wx, wy + 24, ww, wh - 72)
    @devide_window.unselect
    @devide_window.deactivate
    @devide_window.opacity = 0
    #ハンドラのセット
    @devide_window.set_handler(:cancel,   method(:devide_cancel))
    @devide_window.set_handler(:ok,   method(:devide_ok)) 
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウの作成
  #--------------------------------------------------------------------------
  def create_task_window
    wx = (Graphics.width - 180)/2
    wy = (Graphics.height - 180)/2
    @task_window = Window_k_Statusdivide_Task_Command.new(wx, wy)
    @task_window.unselect
    @task_window.deactivate
    @task_window.z  += 10
    @task_window.hide 
    #ハンドラのセット
    @task_window.set_handler(:cancel,   method(:task_cancel))
    @task_window.set_handler(:ok,   method(:task_ok)) 
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのセット
  #--------------------------------------------------------------------------
  def window_setting
    @ptm_window.param_window = @param_window
    @ptm_window.info_window = @info_window
    @ptm_window.devide_window = @devide_window
    @devide_window.param_window = @param_window
    @devide_window.info_window = @info_window
    @task_window.help_window = @help_window
     
    @info_window.actor = @ptm_window.current_ext
    @param_window.actor = @ptm_window.current_ext
    @devide_window.actor = @ptm_window.current_ext
    
    #セーブデータ作成
    @save_data_param = Array.new
    @save_data_point = 0
  end
  #--------------------------------------------------------------------------
  # ● パーティーメンバーウィンドウ[決定]
  #--------------------------------------------------------------------------
  def ptm_ok
    @ptm_window.deactivate
    @devide_window.activate
    @devide_window.select(0)
    @help_window.set_text("振り分けるステータスを選択してください")
    
    #セーブデータ作成
    @save_data_param = Marshal.load(Marshal.dump(@ptm_window.current_ext.divide_param))
    @save_data_point = @ptm_window.current_ext.status_point
    @save_data_counter = Marshal.load(Marshal.dump(@ptm_window.current_ext.status_divide_time_all))
    
    @devide_window.save_param = Marshal.load(Marshal.dump(@ptm_window.current_ext.status_divide_time_all))
  end
  #--------------------------------------------------------------------------
  # ● パーティーメンバーウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def ptm_cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● 振り分けウィンドウ[決定]
  #--------------------------------------------------------------------------
  def devide_ok
    @devide_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 振り分けウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def devide_cancel
    call_task
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ呼び出し
  #--------------------------------------------------------------------------
  def call_task
    @devide_window.deactivate
    @task_window.show
    @task_window.activate
    @task_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ
  #--------------------------------------------------------------------------
  def close_task
    @task_window.hide
    @task_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● リセット
  #--------------------------------------------------------------------------
  def reset
    @ptm_window.current_ext.set_divide_param = @save_data_param
    @ptm_window.current_ext.status_point = @save_data_point
    @ptm_window.current_ext.set_status_divide_time = @save_data_counter
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ[決定]
  #--------------------------------------------------------------------------
  def task_ok
    case @task_window.index
    when 0
      close_task
      @devide_window.unselect
      @ptm_window.activate
      @help_window.set_text("ステータスを振り分けるキャラクターを選択してください")
      
    when 1
      reset
      close_task
      @devide_window.unselect
      @ptm_window.activate
      @help_window.set_text("ステータスを振り分けるキャラクターを選択してください")
      
      @info_window.refresh
      @param_window.refresh
      @devide_window.refresh
    when 2
      task_cancel
    end
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def task_cancel
    close_task
    @devide_window.activate
    @help_window.set_text("振り分けるステータスを選択してください")
    @info_window.refresh
    @param_window.refresh
    @devide_window.refresh    
  end
end

#==============================================================================
# ■ Window_ALLPartyMember_List
#------------------------------------------------------------------------------
# 　全てのパーティーメンバーを表示するウィンドウです。
#==============================================================================
class Window_ALLPartyMember_List< Window_Command
  attr_accessor :param_window
  attr_accessor :devide_window
  attr_accessor :info_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x,y,height)
    @window_height = height
    super(x,y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    150
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    @window_height
  end
  #--------------------------------------------------------------------------
  # ● 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height    
    KURE::Statusdivide::GAME_CHARACTER_HEIGHT + 2
  end
  #--------------------------------------------------------------------------
  # ● カーソルの更新
  #--------------------------------------------------------------------------
  def update_cursor
    #カーソル描画フラグ
    @flag_cursor = 1
    
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end
    
    #カーソル描画フラグ
    @flag_cursor = 0
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    if @flag_cursor == 1
      draw_x = 0
    else  
      draw_x = 40
    end  
    rect = Rect.new
    rect.width = item_width - draw_x
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing) + draw_x
    rect.y = index / col_max * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    pt_member = $game_party.all_members
    
    pt_member.each do |ptm|
      add_command(ptm.name,  :ok, true, ptm)
    end

  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    @param_window.actor = current_ext if @param_window
    @devide_window.actor = current_ext if @devide_window
    @info_window.actor = current_ext if @info_window
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    clear_command_list
    make_command_list
    create_contents
    super
    draw_number
  end
  #--------------------------------------------------------------------------
  # ● 番号描画
  #--------------------------------------------------------------------------
  def draw_number
    pt_member = $game_party.all_members
    
    counter = 0
    pt_member.each do |ptm|
      draw_character(ptm.character_name, ptm.character_index , 20 + 4, item_height * (counter +1) - 1)
      counter += 1
    end
  end
end

#==============================================================================
# ■ Window_k_Statusdivide_InfoWindow
#==============================================================================
class Window_k_Statusdivide_InfoWindow < Window_Base
  attr_accessor :actor
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor
    draw_text(0, 0, contents.width / 3, line_height, @actor.name)
    
    change_color(system_color)
    draw_text(contents.width / 3, 0, contents.width / 2, line_height, KURE::Statusdivide::STATUS_POINT_NAME)
    
    change_color(normal_color)
    draw_text(contents.width / 3, 0, contents.width * 2 / 3, line_height, @actor.status_point, 2)
  end
end

#==============================================================================
# ■ Window_k_Statusdivide_DivideWindow
#==============================================================================
class Window_k_Statusdivide_DivideWindow< Window_Command
  attr_accessor :param_window
  attr_accessor :info_window
  attr_accessor :actor
  attr_accessor :max_pages
  attr_accessor :first_line
  attr_accessor :save_param
  attr_accessor :save_point
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @width = width
    @height = height
    @first_line = 0
    @max_pages = 1
    @make_list = []
    @save_param = []
    @save_point = 0
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
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
    
    @param_window.draw_index = -1 if @param_window
    return if index < 0
    @param_window.draw_index = current_ext if @param_window
  end
  #--------------------------------------------------------------------------
  # ● →キーの処理
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if @actor
      
      param_list = KURE::Statusdivide::PRAM[current_ext]
      param_list = @actor.actor.divide_param_setting[current_ext] if @actor.actor.divide_param_setting[current_ext]
      
      return unless pointcheack(current_ext)
      point = (param_list[1] + param_list[2] * @actor.status_divide_time(current_ext)).to_i
      @actor.status_divide(current_ext, param_list[0])
      @actor.use_status_point(point)
      
      @param_window.refresh if @param_window
      @info_window.refresh if @info_window
    end
  end
  #--------------------------------------------------------------------------
  # ● ←キーの処理
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if KURE::Statusdivide::POINT_BACK == 0
      return if @save_param[current_ext] == @actor.status_divide_time(current_ext)
    end
    if @actor
      
      param_list = KURE::Statusdivide::PRAM[current_ext]
      param_list = @actor.actor.divide_param_setting[current_ext] if @actor.actor.divide_param_setting[current_ext]
      
      return if @actor.status_divide_time(current_ext) == 0
      @actor.status_divide(current_ext, -1 * param_list[0])
      point = (param_list[1] + param_list[2] * @actor.status_divide_time(current_ext)).to_i
      @actor.add_status_point(point)      
    
      @param_window.refresh if @param_window
      @info_window.refresh if @info_window
    end
  end
  #--------------------------------------------------------------------------
  # ● ポイントチェック
  #--------------------------------------------------------------------------
  def pointcheack(param)
    case param
    when 0..7
      param_list = KURE::Statusdivide::PRAM[param]
      param_list = @actor.actor.divide_param_setting[param] if @actor.actor.divide_param_setting[param]
 
      return false if @actor.status_divide_time(param) >= param_list[3]
      point = (param_list[1] + param_list[2] * @actor.status_divide_time(param)).to_i
      return true if @actor.status_point >= point
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    
    command_list = KURE::Statusdivide::USE_DIVIDE_PARAM
    command_list = @actor.actor.divide_param_list if @actor.actor.divide_param_list != []
    
    for i in 0..7
      if command_list.include?(i)
        add_command(" ", :ok, pointcheack(i), i)
      end
    end
  end
end

#==============================================================================
# ■ Window_k_Statusdivide_ParamWindow
#==============================================================================
class Window_k_Statusdivide_ParamWindow < Window_Base
  attr_accessor :actor
  attr_accessor :draw_index
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 選択中の項目の設定
  #--------------------------------------------------------------------------
  def draw_index=(draw_index)
    return if @draw_index == draw_index
    @draw_index = draw_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ポイントチェック
  #--------------------------------------------------------------------------
  def pointcheack(param)
    case param
    when 0..7
      param_list = KURE::Statusdivide::PRAM[param]
      param_list = @actor.actor.divide_param_setting[param] if @actor.actor.divide_param_setting[param]
 
      return false if @actor.status_divide_time(param) >= param_list[3]
      point = (param_list[1] + param_list[2] * @actor.status_divide_time(param)).to_i
      return true if @actor.status_point >= point
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    
    #共通描画
    draw_gauge(0,0, contents.width - 105, 1, mp_gauge_color2,crisis_color)
    change_color(normal_color)
    draw_text(0,0, 200, line_height, "振分項目")

    draw_gauge(contents.width - 100,0, 100, 1, mp_gauge_color2,crisis_color)
    change_color(normal_color)
    draw_text(contents.width - 100,0, 100, line_height, "必要ポイント")
    
    return unless @actor
    
    command_list = KURE::Statusdivide::USE_DIVIDE_PARAM
    command_list = @actor.actor.divide_param_list if @actor.actor.divide_param_list != []
    
    draw_line = -1
    for param in 0..7
      param_list = KURE::Statusdivide::PRAM[param]
      param_list = @actor.actor.divide_param_setting[param] if @actor.actor.divide_param_setting[param]
 
      if command_list.include?(param)
        draw_line += 1 
        color = pointcheack(param)
        change_color(system_color, color)
        draw_text(0, line_height * (draw_line + 1), 90, line_height, Vocab.param(param))
        draw_text(145, line_height * (draw_line + 1), 25, line_height, "→", 1)
        change_color(normal_color, color)

      
        draw_text(95, line_height * (draw_line + 1), 50, line_height, @actor.param(param), 2)
        text = @actor.param(param)
        time = @actor.status_divide_time(param)
      
        time_str = "( " + time.to_s + ")" if time < 10
        time_str = "(" + time.to_s + ")" if time >= 10
      
        if @draw_index == param
          text += param_list[0]
          change_color(param_change_color(1), color)
        end
        draw_text(175, line_height * (draw_line + 1), contents.width - 275, line_height, text.to_s + time_str, 2)
        change_color(normal_color, color)
      
        point = (param_list[1] + param_list[2] * @actor.status_divide_time(param)).to_i
        draw_text(contents.width - 85, line_height * (draw_line + 1), 50, line_height, point.to_s, 2)
      
        change_color(system_color, color)
        draw_text(contents.width - 30, line_height * (draw_line + 1), 30, line_height, "P", 2)
        change_color(normal_color, color)
      end
    end

  end
end

#==============================================================================
# ■ Window_CharaMake_Task_Command
#------------------------------------------------------------------------------
# 　選択肢を表示するウィンドウです。
#==============================================================================
class Window_k_Statusdivide_Task_Command < Window_Command
  attr_accessor :actor_id
  attr_accessor :help_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 180
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプの設定
  #--------------------------------------------------------------------------
  def call_update_help
    return unless @help_window
    case current_ext
    when 1
      @help_window.set_text("振り分けを確定します。")
    when 2
      @help_window.set_text("振り分けをリセットします。")      
    when 3
      @help_window.set_text("振り分け画面に戻ります。")    
    end    
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("振り分け確定", :ok, true, 1)
    add_command("振り分け中止", :ok, true, 2)
    add_command("キャンセル", :ok, true, 3)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    clear_command_list
    make_command_list
    create_contents
    self.height = window_height
    select(0)
    super
  end
end

