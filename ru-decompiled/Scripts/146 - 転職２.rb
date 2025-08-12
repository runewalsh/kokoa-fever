#==============================================================================
#  ■転職画面 for RGSS3 Ver2.15-β10
#　□author kure
#
#　呼び出し方法 　SceneManager.call(Scene_JobChange)
#
#==============================================================================

module KURE
  module JobChange
    #スクリプトの初期設定(ここは変更しない事)-----------------------------------
    STATUS_VALUATION = []
    
    #動作に関する設定項目-------------------------------------------------------
    #転職時、スキル設定
    #DELETE_SKILL_MODE(0=そのまま、1=削除する)
    DELETE_SKILL_MODE = 1
    #基本レベルの保持設定(0=維持しない 1=維持する)
    BASE_LV_KEEP = 1
    #メインクラス選択を非表示にするスイッチ(0=常時表示)
    LOCK_MAIN_CLASS_SYSTEM = 0
    #サブクラスシステム選択を表示するスイッチ(0=常時許可)
    UNLOCK_SUB_CLASS_SYSTEM = 42
    #転職可能職だけを表示(0=OFF、1=ON)
    VIEW_ONLY_CAN_CHANGE = 1
    #存在する履歴のみを描画(0=OFF、1=ON)
    VIEW_ONLY_IS_RECORD = 1
    
    #キャラクターに関する設定項目-----------------------------------------------
    #未登録と判別するキャラ名
    NO_REGIST_Name = ""
    
    #職業グレードに関する設定項目----------------------------------------------
    #●がついた項目は項目数を同じにしてください
    #●JOB_GRADE_LIST = [グレード1,グレード2,…]
    JOB_GRADE_LIST = ["Новичок","Любитель","Профи","Разное"]
    #選択開放スイッチ(常時許可は0)
    #●UNLOCK_JOB_GRADE = [スイッチID,スイッチID,…]
    UNLOCK_JOB_GRADE = [0,0,0,0,]
    
    #職業説明画面に関する設定項目----------------------------------------------
    #■がついた項目は項目数を同じにしてください
    #評価設定するレベル(指定Lvの時のステータスで以下を評価する)
    VALUATION_LEVEL = 1
    #評価方法([評価1,評価2,評価3,評価4,評価5,評価外])
    VALUATION = ["Ｓ","Ａ","Ｂ","Ｃ","Ｄ","Ｅ"]
    #■MAXHP([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[0] = [129,119,109,99,89]
    #■MAXMP([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[1] = [64,59,54,49,44]
    #■攻撃力([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[2] = [31,28,26,24,22]
    #■防御力([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[3] = [25,23,21,19,17]
    #■魔法力([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[4] = [12,11,10,9,8]
    #■魔法防御([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[5] = [14,13,12,11,10]
    #■敏捷性([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[6] = [12,11,10,9,8]
    #■運([評価1,評価2,評価3,評価4,評価5])
    STATUS_VALUATION[7] = [14,13,12,11,10]
  end
end

#==============================================================================
# ■ Scene_JobChange
#------------------------------------------------------------------------------
# 　キャラクターメイキングの処理を行うクラスです。
#==============================================================================
class Scene_JobChange < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_command_window
    create_status_window
    create_job_grade_window
    create_popup_window
    create_task_window
    
    set_window_task
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text("Выберите персонажа для смены рода деятельности.")
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    #キャラクター選択ウィンドウを作成
    @charactor_list_window = Window_k_Jobchange_Name_Job_Command.new(0, @help_window.height)
    @charactor_list_window.height = Graphics.height - @help_window.height
    @charactor_list_window.activate
    @charactor_list_window.viewport = @viewport    
    #呼び出しのハンドラをセット
    @charactor_list_window.set_handler(:ok,method(:select_command))
    @charactor_list_window.set_handler(:cancel,method(:on_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 職業選択用の選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_job_grade_window    
    #職業選択用の選択ウィンドウを作成
    @job_grade_window = Window_k_Jobchange_Job_Grade_Command.new(0, @help_window.height)
    @job_grade_window.hide
    @job_grade_window.deactivate
    @job_grade_window.viewport = @viewport     
    #呼び出しのハンドラをセット
    @job_grade_window.set_handler(:cancel,method(:on_job_grade_cancel))
    @job_grade_window.set_handler(:ok,method(:select_job_grade))
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    #ステータスウィンドウを作成
    @charactor_status_window = Window_k_Jobchange_Status_Jobexp.new(@charactor_list_window.width,@help_window.height,Graphics.width - @charactor_list_window.width, Graphics.height - @help_window.height)
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_popup_window
    #ポップアップウィンドウを作成
    @popup_window = Window_k_Jobchange_Popup.new( Graphics.width / 4 ,Graphics.height / 4 )
    @popup_window.z += 100
    @popup_window.unselect
    @popup_window.deactivate
    @popup_window.back_opacity = 255
    @popup_window.hide
    
    #呼び出しのハンドラをセット
    @popup_window.set_handler(:ok,method(:pop_ok))
    @popup_window.set_handler(:cancel,method(:pop_cancel))
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウの作成
  #--------------------------------------------------------------------------
  def create_task_window
    #ポップアップウィンドウを作成
    @task_window = Window__k_Jobchange_Task_Command.new( Graphics.width / 4 ,Graphics.height / 2 - 40 )
    @task_window.z += 100
    @task_window.unselect
    @task_window.deactivate
    @task_window.back_opacity = 255
    @task_window.hide
    
    #呼び出しのハンドラをセット
    @task_window.set_handler(:ok,method(:task_ok))
    @task_window.set_handler(:cancel,method(:task_cancel))
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのセッティング処理
  #--------------------------------------------------------------------------
  def set_window_task
    @edit_character_id = 0
    @edit_actor_class_kind = 0
    @charactor_list_window.status_window = @charactor_status_window
    @charactor_list_window.popup_window = @popup_window
    @charactor_list_window.task_window = @task_window
    @job_grade_window.status_window = @charactor_status_window
    @charactor_status_window.charactor_list_window = @charactor_list_window
    @actor = $game_actors[@charactor_list_window.current_ext]
    @charactor_status_window.actor = @actor
    @task_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウサイズ更新(職業グレードオープン)
  #--------------------------------------------------------------------------
  def resize
    #上級職選択ウィンドウのための追加処理
    y = @help_window.height
    height = Graphics.height - @help_window.height

    @job_grade_window.show
    @charactor_status_window.draw_index = 0
    @charactor_list_window.y = @help_window.height + @job_grade_window.height
    @charactor_list_window.height = Graphics.height - @charactor_list_window.y
    @charactor_list_window.create_contents
    @charactor_list_window.view_index = -1
    
    @charactor_status_window.y = y + @job_grade_window.height
    @charactor_status_window.height = height - @job_grade_window.height
    @charactor_status_window.create_contents
    @charactor_status_window.view_index = -1
    
    @charactor_list_window.unselect
    @charactor_list_window.deactivate
    @job_grade_window.activate
    @job_grade_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウサイズ更新(職業グレードクローズ)
  #--------------------------------------------------------------------------
  def resize2
    #上級職選択ウィンドウのための追加処理
    y = @help_window.height
    height = Graphics.height - @help_window.height

    @job_grade_window.hide
    @charactor_status_window.draw_index = 0
    @charactor_list_window.y = @help_window.height
    @charactor_list_window.height = Graphics.height - @help_window.height
    @charactor_list_window.create_contents
    @charactor_list_window.view_index = 0
    @charactor_status_window.y = y
    @charactor_status_window.height = height
    @charactor_status_window.create_contents
    @charactor_status_window.view_index = 0
    @job_grade_window.deactivate
    @job_grade_window.unselect
    @charactor_list_window.activate
    @charactor_list_window.select(@edit_character_id)    
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウ[決定]
  #--------------------------------------------------------------------------
  def select_command
    if @charactor_list_window.view_index_num == 0
      if KURE::JobChange::UNLOCK_SUB_CLASS_SYSTEM == 0 or $game_switches[KURE::JobChange::UNLOCK_SUB_CLASS_SYSTEM] == true 
        task_open
      else
        if KURE::JobChange::LOCK_MAIN_CLASS_SYSTEM == 0 or $game_switches[KURE::JobChange::LOCK_MAIN_CLASS_SYSTEM] == false
          actor_to_grade_window
        else
          @charactor_list_window.activate
        end
      end
    else
      pop_open
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def on_cancel
    if @charactor_list_window.view_index_num == 0
      return_scene
    else
      grade_window_set_focus
    end
  end 
  #--------------------------------------------------------------------------
  # ● 職業グレード選択ウィンドウ[決定]
  #--------------------------------------------------------------------------
  def select_job_grade
    job_list_window_set_focus
  end
  #--------------------------------------------------------------------------
  # ● 職業グレード選択ウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def on_job_grade_cancel
    @help_window.set_text("Выберите персонажа для смены рода деятельности.")
    resize2
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[決定]
  #--------------------------------------------------------------------------
  def pop_ok
    if @popup_window.index == 0
      change_job
      @help_window.set_text("Выберите персонажа для смены рода деятельности.")
      resize2
    end
    pop_close
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def pop_cancel
    pop_close
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ[決定]
  #--------------------------------------------------------------------------
  def task_ok
    @edit_character_id = @charactor_list_window.index
    @actor = $game_actors[@charactor_list_window.current_ext]
    @charactor_status_window.actor = @actor
    @popup_window.actor = @actor
    
    resize

    @edit_actor_class_kind = @task_window.current_ext
    @charactor_list_window.edit_actor_class_kind = @edit_actor_class_kind
    @charactor_status_window.edit_actor_class_kind = @edit_actor_class_kind
    @popup_window.kind = @edit_actor_class_kind
    @charactor_status_window.refresh
    @help_window.set_text(@actor.name + ": выберите занятие.") if @edit_actor_class_kind == 0
    @help_window.set_text(@actor.name + ": выберите подзанятие.") if @edit_actor_class_kind == 1
    task_close
    @charactor_list_window.deactivate 
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def task_cancel
    task_close
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[開く]
  #--------------------------------------------------------------------------
  def pop_open
    @popup_window.show
    @popup_window.select(1)
    @popup_window.activate
    @charactor_list_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[閉じる]
  #--------------------------------------------------------------------------
  def pop_close
    @popup_window.hide
    @popup_window.unselect
    @popup_window.deactivate
    @charactor_list_window.activate
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ[開く]
  #--------------------------------------------------------------------------
  def task_open
    @task_window.refresh
    @task_window.show
    @task_window.select(0)
    @task_window.activate
    @charactor_list_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● タスクウィンドウ[閉じる]
  #--------------------------------------------------------------------------
  def task_close
    @task_window.hide
    @task_window.unselect
    @task_window.deactivate
    @charactor_list_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アクターリスト　→　職業グレード
  #--------------------------------------------------------------------------
  def actor_to_grade_window
    @edit_character_id = @charactor_list_window.index
    @actor = $game_actors[@charactor_list_window.current_ext]
    @charactor_status_window.actor = @actor
    @popup_window.actor = @actor
    @charactor_status_window.draw_index = 0
    
    resize

    @edit_actor_class_kind = 0
    @charactor_list_window.edit_actor_class_kind = @edit_actor_class_kind
    @charactor_status_window.edit_actor_class_kind = @edit_actor_class_kind
    @popup_window.kind = @edit_actor_class_kind
    @help_window.set_text(@actor.name + ": выберите занятие.") if @edit_actor_class_kind == 0
    @help_window.set_text(@actor.name + ": выберите подзанятие.") if @edit_actor_class_kind == 1
    task_close
    @charactor_list_window.deactivate    
  end
  #--------------------------------------------------------------------------
  # ● 職業リスト　→　職業グレード
  #--------------------------------------------------------------------------
  def grade_window_set_focus
    @charactor_list_window.select(0)
    @charactor_list_window.unselect
    @charactor_list_window.deactivate
    @charactor_list_window.view_index = -1
    @charactor_status_window.view_index = -1
    @job_grade_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 職業グレード　→　職業リスト
  #--------------------------------------------------------------------------
  def job_list_window_set_focus
    @charactor_list_window.select(0)
    @charactor_list_window.activate
    @charactor_list_window.view_index = @job_grade_window.current_ext
    @charactor_status_window.view_index = @job_grade_window.current_ext
    @charactor_status_window.job = @charactor_list_window.current_ext
    @popup_window.job = @charactor_list_window.current_ext
    @job_grade_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● 転職処理
  #--------------------------------------------------------------------------
  def change_job
    change_class_id = @charactor_list_window.current_ext
    if @edit_actor_class_kind == 1
      change_class_id = 0 if change_class_id == @actor.sub_class_id
    end
    
    #転職要求アイテムが存在すれば処理する
    if change_class_id != 0
      #経験済み職業でなければ処理
      unless @actor.class_level_list[change_class_id]
        change_class = $data_classes[change_class_id] 
        if change_class.need_jobchange_item != []
          for i in 0..change_class.need_jobchange_item.size - 1
            $game_party.gain_item($data_items[change_class.need_jobchange_item[i]], -1)
          end
        end
      end
    end
    
    #転職処理
    if KURE::BaseScript::USE_JOBLv == 1
      if @edit_actor_class_kind == 0
        @actor.change_class(change_class_id)
        @actor.change_sub_class(0) if $data_classes[change_class_id].seal_sub_class == true
      end
    else
      if @edit_actor_class_kind == 0
        if KURE::JobChange::BASE_LV_KEEP == 0
          @actor.change_class(change_class_id,false)
        else
          @actor.change_class(change_class_id,true)
        end
        @actor.change_sub_class(0) if $data_classes[change_class_id].seal_sub_class == true
      end
    end
    @actor.change_sub_class(change_class_id) if @edit_actor_class_kind == 1
    
    #グラフィック変更設定になっていれば処理
    if @edit_actor_class_kind == 0
      change_class = $data_classes[change_class_id].clone
      if $data_actors[@actor.id].can_change_graphic != 0
        change_graphic(change_class, $data_actors[@actor.id].can_change_graphic)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● グラフィック変更処理
  #--------------------------------------------------------------------------
  def change_graphic(change_class,graphic_id)
    list = change_class.use_job_graphic
    for i in 0..list.size - 1
      if list[i][0] == graphic_id
        @actor.set_graphic(list[i][1],list[i][2],list[i][3],list[i][4])
        $game_player.refresh
      end 
    end
  end
end

#==============================================================================
# ■ Window_k_Jobchange_Popup
#==============================================================================
class Window_k_Jobchange_Popup < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ◎ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 職業の設定
  #--------------------------------------------------------------------------
  def job=(job)
    return if @job == job
    @job = job
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 職業種類の設定
  #--------------------------------------------------------------------------
  def kind=(kind)
    return if @kind == kind
    @kind = kind
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 5
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の高さを計算
  #--------------------------------------------------------------------------
  def contents_height
    line_height * visible_line_number
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = super
    rect.x = index * (item_width + spacing)
    rect.y = line_height * 4
    rect
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("ОК", :ok)
    add_command("Отмена", :ok)
  end
  #--------------------------------------------------------------------------
  # ● 描画処理
  #--------------------------------------------------------------------------
  def draw_contents
    draw_gauge(5 , 0, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, 0, 126, line_height, "Смена деятельности")
    
    return if @actor == nil
    draw_text(5, line_height * 1, contents.width / 2 - 20, line_height, @actor.name)
    if @kind == 0
      draw_text(5, line_height * 2, contents.width / 2 - 20, line_height, @actor.class.name)
      draw_text(5, line_height * 3, contents.width / 2 - 20, line_height, "Lv  " + @actor.class_level_list[@actor.class_id].to_s)
    else
      draw_text(5, line_height * 2, contents.width / 2 - 20, line_height, @actor.sub_class.name) if @actor.sub_class_id != 0
      draw_text(5, line_height * 3, contents.width / 2 - 20, line_height, "Lv  " + @actor.class_level_list[@actor.sub_class_id].to_s) if @actor.sub_class_id != 0
    end  
    
    draw_text(contents.width / 2 - 10, line_height * 2 + line_height / 2 , 20, line_height, "→")
    
    return if @job == nil or @job == 0
    if @kind == 1 and @actor.sub_class_id == @job
      draw_text(contents.width / 2 + 25, line_height * 2, contents.width / 2 - 25, line_height, "サブクラス")
      draw_text(contents.width / 2 + 25, line_height * 3, contents.width / 2 - 25, line_height, "解除")
    else
      draw_text(contents.width / 2 + 25, line_height * 2, contents.width / 2 - 25, line_height, $data_classes[@job].name)
      lv = "-"
      lv = @actor.class_level_list[@job].to_s if @actor.class_level_list[@job]
      draw_text(contents.width / 2 + 25, line_height * 3, contents.width / 2 - 25, line_height, "Lv  " + lv)
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    draw_contents
  end
end


#==============================================================================
# ■ Window_k_Jobchange_Job_Grade_Command
#==============================================================================
class Window_k_Jobchange_Job_Grade_Command < Window_HorzCommand
  attr_accessor :status_window
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
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 先頭の桁の設定
  #--------------------------------------------------------------------------
  def top_col=(col)
    col = 0 if col < 0
    #桁数問題解消処理
    #col = col_max - 1 if col > col_max - 1
    self.ox = col * (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    return if index < 0
    @status_window.jobexp_index = @index if @status_window
    @status_window.draw_index = 0 if @status_window
  end
  #--------------------------------------------------------------------------
  # ● カーソルを下に移動
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    @status_window.draw_index += 1 if @status_window
    @status_window.roop_maker = 1 if @status_window
  end
  #--------------------------------------------------------------------------
  # ● カーソルを上に移動
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    @status_window.draw_index += -1 if @status_window
    @status_window.roop_maker = 0 if @status_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    for i in 0..KURE::JobChange::JOB_GRADE_LIST.size - 1
      add_command(KURE::JobChange::JOB_GRADE_LIST[i], :ok ,cheak_list(i) ,i + 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 条件開放チェック
  #--------------------------------------------------------------------------
  def cheak_list(grade)
    return true if KURE::JobChange::UNLOCK_JOB_GRADE[grade] == 0
    return false if $game_switches[KURE::JobChange::UNLOCK_JOB_GRADE[grade]] == false
    return true
  end
end

#==============================================================================
# ■ Window_k_Jobchange_Name_Job_Command
#------------------------------------------------------------------------------
# 　アクター名とジョブ名を表示するコマンドウィンドウです。
#==============================================================================
class Window_k_Jobchange_Name_Job_Command < Window_Command
  attr_accessor :status_window
  attr_accessor :popup_window
  attr_accessor :task_window
  attr_accessor :condition_list
  attr_accessor :edit_actor_class_kind
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    @view_index = 0
    @edit_actor_class_kind = 0
    super(x,y)
    @actor = $game_actors[current_ext]
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # ◎ 表示項目の呼び出し
  #--------------------------------------------------------------------------
  def view_index_num
    return @view_index
  end
  #--------------------------------------------------------------------------
  # ◎ 表示項目の設定
  #--------------------------------------------------------------------------
  def view_index=(view_index)
    return if @view_index == view_index
    @view_index = view_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    if @view_index == 0
      add_name_commands
    else
      add_job_commands
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    if @view_index > 0
      change_color(tp_gauge_color2, command_enabled?(index)) if @list[index][:ext] == @actor.class_id
      change_color(mp_gauge_color2, command_enabled?(index)) if @list[index][:ext] == @actor.sub_class_id
    end
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # ● →キー入力時動作
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    @status_window.draw_index += 1 if @status_window
  end
  #--------------------------------------------------------------------------
  # ● ←キー入力時操作
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    @status_window.draw_index -= 1 if @status_window
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    return if index < 0
    if @view_index == 0 
      @status_window.actor = $game_actors[current_ext] if @status_window
      @task_window.actor = $game_actors[current_ext] if @task_window
      @actor = $game_actors[current_ext]
    else
      @status_window.job = current_ext if @status_window
      @popup_window.job = current_ext if @popup_window
    end
  end
  #--------------------------------------------------------------------------
  # ● アクター名をリストに追加
  #--------------------------------------------------------------------------
  def add_name_commands
    counter = 0
    #アクターを描画
    for i in 1..$data_actors.size - 1
      if $game_actors[i].name != KURE::JobChange::NO_REGIST_Name
        #表示方法を判定する
        if $data_actors[i].view_jobchange_window == 0
          if $data_actors[i].add_jobchange_window == 0
            add_command($game_actors[i].name, :ok, true ,i)
            counter = 1
          elsif $data_actors[i].add_jobchange_window > 0
            add_command($game_actors[i].name, :ok, $game_switches[$data_actors[i].add_jobchange_window] ,i)
            counter = 1
          end
        else
          if $game_switches[$data_actors[i].view_jobchange_window] == true
            if $data_actors[i].add_jobchange_window == 0
              add_command($game_actors[i].name, :ok, true ,i)
              counter = 1
            elsif $data_actors[i].add_jobchange_window > 0
              add_command($game_actors[i].name, :ok, $game_switches[$data_actors[i].add_jobchange_window] ,i)
              counter = 1
            end
          end
        end  
      end
    end
    add_command("", :ok, false, 0) if counter == 0
  end
  #--------------------------------------------------------------------------
  # ● 職業名をリストに追加
  #--------------------------------------------------------------------------
  def add_job_commands
    counter = 0
    #全職業リストからグレードを設定している職業を選びだす
    for i in 1..$data_classes.size - 1
      if $data_classes[i].class_lank == @view_index and $data_classes[i].change_class_kind != @edit_actor_class_kind
        if condition($data_classes[i],i) == true
          add_command($data_classes[i].name, :ok, true, $data_classes[i].id)
          counter = 1
        else
          if KURE::JobChange::VIEW_ONLY_CAN_CHANGE == 0
            if $data_classes[i].view_class_name == true
              add_command($data_classes[i].name, :ok, false, $data_classes[i].id)
            else
              add_command("？？？？？", :ok, false, $data_classes[i].id)
            end
            counter = 1
          end
        end
      end
    end
    add_command("", :ok, false, 0) if counter == 0
  end
  #--------------------------------------------------------------------------
  # ● 前提条件をチェックする
  #--------------------------------------------------------------------------
  def condition(job,index)

    #メインとサブを被らないようにする
    return false if @edit_actor_class_kind == 0 and job.id == @actor.sub_class_id 
    return false if @edit_actor_class_kind == 1 and job.id == @actor.class_id 

    #両立不可職かどうかチェック
    if @edit_actor_class_kind == 0
      return false if job.not_same_time_jobchange_class.include?(@actor.sub_class_id)
    end
    if @edit_actor_class_kind == 1
      return false if job.not_same_time_jobchange_class.include?(@actor.class_id)
    end

    #単独職かチェック
    if job.only_one_class
      for i in 0..$game_party.all_members.size - 1
        return false if $game_party.all_members[i].class_id == job.id
      end
    end
    
    #経験済みかチェック
    return true if @actor.class_level_list[job.id] != nil

    #経験済み職業設定であればチェック
    if $data_actors[@actor.id].exp_jobchange_class !=[]
      for i in 0..$data_actors[@actor.id].exp_jobchange_class.size - 1
        if i % 2 == 0
          return true if $data_actors[@actor.id].exp_jobchange_class[i] == job.id
        end
      end
    end

    #レベルのチェック
    return false if @actor.level < job.need_jobchange_level[0]

    #職業レベルのチェック
    return false  if @actor.joblevel < job.need_jobchange_level[1]

    #要求経験職のチェック
    if job.need_jobchange_class != []
      for i in 0..job.need_jobchange_class.size - 1
        if i % 2 == 0
          return false if @actor.class_level_list[job.need_jobchange_class[i]] == nil
          return false if @actor.class_level_list[job.need_jobchange_class[i]] < job.need_jobchange_class[i + 1]
        end
      end
    end

    #選択経験職のチェック
    if job.select_jobchange_class != []
      select_flag = 0
      for i in 0..job.select_jobchange_class.size - 1
        if i % 2 == 0
          if @actor.class_level_list[job.select_jobchange_class[i]] != nil
            select_flag = 1 if @actor.class_level_list[job.select_jobchange_class[i]] >= job.select_jobchange_class[i + 1]
          end
        end
      end
      return false if select_flag == 0
    end

    #要求未経験職をチェック
    if job.unless_need_jobchange_class != []
      for i in 0..job.unless_need_jobchange_class.size - 1
        return false if @actor.class_level_list[job.unless_need_jobchange_class[i]]
      end
    end

    #転職前アクターチェック
    if job.need_jobchange_actor != []
      return false if job.need_jobchange_actor.include?(@actor.id) == false
    end

    #転職要求スキルをチェック
    if job.need_jobchange_skill != []
      for i in 0..job.need_jobchange_skill.size - 1
        return false if @actor.skill_learn?($data_skills[job.need_jobchange_skill[i]]) == false
      end
    end

    #転職要求スイッチをチェック
    if job.need_jobchange_swith != []
      for i in 0..job.need_jobchange_swith.size - 1
        return false if $game_switches[job.need_jobchange_swith[i]] == false
      end    
    end

    #転職要求アイテムをチェック
    if job.need_jobchange_item != []
      for i in 0..job.need_jobchange_item.size - 1
        return false if $game_party.item_number($data_items[job.need_jobchange_item[i]]) == 0
      end    
    end
  
    return true
  end
end

#==============================================================================
# ■ Window_k_Jobchange_Status_Jobexp
#------------------------------------------------------------------------------
# 　ステータスと職業説明を表示するクラスです。
#==============================================================================
class Window_k_Jobchange_Status_Jobexp < Window_Selectable
  attr_accessor :draw_index
  attr_accessor :charactor_list_window
  attr_accessor :roop_maker
  attr_accessor :edit_actor_class_kind
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x,y,width,height)
    super(x, y, width ,height)
    @job = 1
    @view_index = 0
    @draw_index = 0
    @jobexp_index = 0
    @roop_maker = 0
    @edit_actor_class_kind
  end
  #--------------------------------------------------------------------------
  # ◎ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 職業の設定
  #--------------------------------------------------------------------------
  def job=(job)
    return if @job == job
    @job = job
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 画面表示切り替えの設定
  #--------------------------------------------------------------------------
  def view_index=(view_index)
    return if @view_index == view_index
    @view_index = view_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 職業説明の表示切り替えの設定
  #--------------------------------------------------------------------------
  def jobexp_index=(jobexp_index)
    return if @jobexp_index == jobexp_index
    @jobexp_index = jobexp_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ 画面描画ページの設定
  #--------------------------------------------------------------------------
  def draw_index=(draw_index)
    return if @draw_index == draw_index
    @draw_index = draw_index
    @draw_index = 0 if draw_index > 9
    @draw_index = 9 if draw_index < 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ◎ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_job_exp(0,0) if @view_index == -1
    draw_character_status(0,0) if @view_index == 0
    draw_job_status(0,0) if @view_index > 0
  end
  #--------------------------------------------------------------------------
  # ◎ ステータスの描画
  #--------------------------------------------------------------------------
  def draw_character_status(x,y)
    draw_base_status(x,y)
    case @draw_index
    when 0,2,4,6,8
      draw_block1(x ,y + line_height * 4)
      draw_text(0, contents.height - line_height , contents.width, line_height, "←　→: Страница (1 / 2)" ,1)
    when 1,3,5,7,9
      draw_block2(x ,y + line_height * 4)
      draw_text(0, contents.height - line_height , contents.width, line_height, "←　→: Страница (2 / 2)" ,1)
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 基本情報の描画(共通描画)
  #--------------------------------------------------------------------------
  def draw_base_status(x,y)
    draw_actor_face(@actor, x, y + 0)
    draw_actor_name(@actor, x + 99, y + 0)
    draw_actor_nickname(@actor, x + 231, y + 0)
    
    draw_actor_class(@actor, x + 99, y + line_height * 1)
    draw_actor_hp(@actor, x + 231, y + line_height * 1)
    
    draw_actor_level(@actor, x + 99, y + line_height * 2)
    draw_actor_mp(@actor, x + 231, y + line_height * 2)
    
    draw_actor_icons(@actor, x + 99, line_height * 3)
    draw_exp_info(x + 231, y + line_height * 3)    
  end
  #--------------------------------------------------------------------------
  # ◎ 経験値情報の描画(共通描画)
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s2 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    s_next = "След. ур."
    change_color(system_color)
    draw_text(x, y , 60, line_height, s_next)
    change_color(normal_color)
    draw_text(x, y , 125, line_height, s2, 2)
  end
  #--------------------------------------------------------------------------
  # ◎ 基本能力値の描画(ブロック1)
  #--------------------------------------------------------------------------
  def draw_block1(x,y)
    draw_gauge(x , y, contents.width - x, 1, mp_gauge_color2,crisis_color)
    draw_text(x, y, 126, line_height, "Показатели")
    
    for param_id in 2..7
      case param_id
      when 2,3
        draw_y = y + line_height * (param_id - 1)
        draw_x = x
      when 4,5
        draw_y = y + line_height * (param_id - 3)
        draw_x = x + contents.width * 1 / 3
      when 6,7
        draw_y = y + line_height * (param_id - 5)
        draw_x = x + contents.width * 2 / 3
      end
      
      change_color(system_color)
      draw_text(draw_x, draw_y, 90, line_height, Vocab::param(param_id))
      change_color(normal_color)
      draw_text(draw_x + 80, draw_y, 30, line_height, @actor.param(param_id), 2)
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 装備品の描画(ブロック1)
  #--------------------------------------------------------------------------
  def draw_block2(x,y)
    draw_gauge(x , y, contents.width - x, 1, mp_gauge_color2,crisis_color)
    draw_text(x, y, 126, line_height, "Экипировка")
    
    for i in 0..@actor.equips.size - 1
      case i
      when 0..7
        draw_y = y
        draw_x = x
      when 8..15
        draw_y = y - line_height * 8
        draw_x = x + contents.width / 2
      end
      draw_item_name(@actor.equips[i], draw_x, draw_y + line_height * (1 + i))
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 職業経験の描画
  #--------------------------------------------------------------------------
  def draw_job_exp(x,y)
    draw_gauge(x , y, contents.width - x, 1, mp_gauge_color2,crisis_color)
    text = @actor.name + ", практика занятий категории " + KURE::JobChange::JOB_GRADE_LIST[@jobexp_index]
    draw_text(x, y, contents.width, line_height, text)
    
    #縦の描画項目数を取得
    draw_contents_number = ((contents.height - line_height * 2) / line_height).to_i
    
    #全職業リストからグレードを設定している職業を選びだす
    draw_line = 1
    draw_x_plus = 0
    draw_counter = 0
    
    select_grade_job = Array.new 
    #選択グレードのクラス配列を作成する
    for i in 1..$data_classes.size - 1
      if $data_classes[i].class_lank == @jobexp_index + 1 and $data_classes[i].change_class_kind != @edit_actor_class_kind
        if $data_classes[i].need_jobchange_actor == [] or $data_classes[i].need_jobchange_actor.include?(@actor.id)
          select_grade_job.push($data_classes[i]) if KURE::JobChange::VIEW_ONLY_IS_RECORD == 0 or @actor.class_level_list[i] != nil
        end
      end
    end
    
    #取得したクラス配列を処理
    draw_max = select_grade_job.size - 1
    max_page = (draw_max / (draw_contents_number * 2)).to_i + 1
    
    if @draw_index > max_page - 1
      @draw_index = 0 if @roop_maker == 1
      @draw_index = max_page - 1 if @roop_maker == 0
    end
  
    draw_start = 0 + (draw_contents_number * 2) * @draw_index
    draw_end = ((draw_contents_number * 2) - 1) + (draw_contents_number * 2) * @draw_index
    draw_end = draw_max if draw_end > draw_max
    
    if draw_start <= draw_end
    for i in draw_start..draw_end
      #2列目に入れば描画位置を変更
      if draw_line > draw_contents_number
        draw_line = 1
        draw_x_plus = contents.width / 2
      end
      
      if select_grade_job[i]
      if @actor.class_level_list[select_grade_job[i].id] != nil
        change_color(normal_color)
        change_color(tp_gauge_color2) if select_grade_job[i].id == @actor.class_id
        change_color(mp_gauge_color2) if select_grade_job[i].id == @actor.sub_class_id
        lv = "Ур."
        lv += " " if @actor.class_level_list[select_grade_job[i].id] < 10
        draw_text(x + draw_x_plus, y + line_height * draw_line, 130, line_height, select_grade_job[i].name)
        draw_text(x + draw_x_plus, y + line_height * draw_line, contents.width / 2 - 5, line_height, lv + @actor.class_level_list[select_grade_job[i].id].to_s, 2)
        change_color(normal_color)
      else
        change_color(normal_color, false)
        if select_grade_job[i].view_class_name == true
          draw_text(x + draw_x_plus, y + line_height * draw_line, 130, line_height, select_grade_job[i].name)
        else
          exp_flag = 0
          for k in 0..$data_actors[@actor.id].exp_jobchange_class.size - 1
            if k % 2 == 0
              exp_flag = 1 if $data_actors[@actor.id].exp_jobchange_class[k] == select_grade_job[i].id
            end
          end
          
          if exp_flag == 1
            draw_text(x + draw_x_plus, y + line_height * draw_line, 130, line_height, select_grade_job[i].name)
          else
            draw_text(x + draw_x_plus, y + line_height * draw_line, contents.width / 2 - 5, line_height, "？？？？？")
          end
        end
        draw_text(x + draw_x_plus, y + line_height * draw_line, contents.width / 2 - 5, line_height, "Lv -", 2)
        change_color(normal_color)
      end
      draw_line += 1
      draw_counter += 1
      end
    end    
    end
  
    draw_text(0, contents.height - line_height , contents.width, line_height, "↓↑: Страница (" + (@draw_index + 1).to_s + " / " + max_page.to_s + ")" ,1)
  end
  #--------------------------------------------------------------------------
  # ◎ 職業ステータスの描画
  #--------------------------------------------------------------------------
  def draw_job_status(x,y)
    if @charactor_list_window
      draw_job_status_true(x,y) if @charactor_list_window.command_enabled?(@charactor_list_window.index) == true
      draw_job_status_false(x,y) if @charactor_list_window.command_enabled?(@charactor_list_window.index) == false
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 職業ステータスの描画(選択可能)
  #--------------------------------------------------------------------------
  def draw_job_status_true(x,y)
    return if @job == nil or @job == 0
    #クラス名描画
    draw_text(x + 5, y, 130, line_height, $data_classes[@job].name) 
    draw_horz_line(y + line_height * 1 - 8)
    
    #装備可能リスト
    draw_text(x + 5, y + line_height * 1 + 8, 100, line_height, "Оружие:")
    get_equip_weapon
    draw_text(x + 100, y + line_height * 1 + 8, 280, line_height, @wep_str)
    get_equip_armor
    draw_text(x + 5, y + line_height * 2 + 8, 100, line_height, "Броня:")
    draw_text(x + 100, y + line_height * 2 + 8, 280, line_height, @armor_str)
    draw_text(x + 100, y + line_height * 3 + 8, 280, line_height, @armor_str2)
    draw_text(x + 100, y + line_height * 4 + 8, 280, line_height, @armor_str3)
    draw_horz_line(y + line_height * 5)
    
    #ステータス評価
    draw_text(x + 5, y + line_height * 6 - 8, 80, line_height, "Показатели：")
    8.times {|i| draw_actor_valuation(x , y + line_height * (i + 7) - 8, i) }
    draw_horz_line(y + line_height * 9 + 8)
    
    #職業説明
    draw_select_job_explan(x, y + line_height * 10)
  end
  #--------------------------------------------------------------------------
  # ◎ 水平線の描画
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # ◎ 水平線の色を取得
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # ★ 特徴コードより装備可能武器を取得する
  #--------------------------------------------------------------------------
  def get_equip_weapon
    #描画用文字列を用意
    @wep_str = ""
      for i in 0..$data_classes[@job].features.size - 1
        #特徴コード51は装備可能武器
        if $data_classes[@job].features[i].code == 51
          #装備タイプのIDを取得
          weaponid = $data_classes[@job].features[i].data_id
          @wep_str += $data_system.weapon_types[weaponid] + " "
        end  
      end  
  end
  #--------------------------------------------------------------------------
  # ★ 特徴コードより装備可能防具を取得する
  #--------------------------------------------------------------------------
  def get_equip_armor
    #描画用文字列を用意
    @armor_str = ""
    @armor_str2 = ""
    @armor_str3 = ""
    #描画用チェッカー
    addtime = 0
      for i in 0..$data_classes[@job].features.size - 1
        #特徴コード52は装備可能防具
        if $data_classes[@job].features[i].code == 52
          #装備タイプのIDを取得
          armorid = $data_classes[@job].features[i].data_id
          if addtime < 3
            @armor_str += $data_system.armor_types[armorid] + " "
            addtime += 1 
          elsif addtime < 6
            @armor_str2 += $data_system.armor_types[armorid] + " "
            addtime += 1
          else
            @armor_str3 += $data_system.armor_types[armorid] + " "
          end
        end  
      end  
    end
  #--------------------------------------------------------------------------
  # ★ 能力値評価の描画
  #--------------------------------------------------------------------------
  def draw_actor_valuation(x, y, param_id)
    change_color(system_color)
    if param_id % 2 == 0
      positionx = 80
      positiony = y - (line_height / 2 * param_id) - line_height
    else
      positionx = 230
      positiony = y - (line_height / 2 * (param_id - 1)) - line_height * 2
    end
    draw_text(x + positionx, positiony, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    
    #能力値評価
    if $data_classes[@job].params[param_id, KURE::JobChange::VALUATION_LEVEL] > KURE::JobChange::STATUS_VALUATION[param_id][0] 
      draw_text(x + 70 + positionx, positiony, 36, line_height, KURE::JobChange::VALUATION[0], 2)
    elsif $data_classes[@job].params[param_id, KURE::JobChange::VALUATION_LEVEL] > KURE::JobChange::STATUS_VALUATION[param_id][1] 
      draw_text(x + 70 + positionx, positiony, 36, line_height, KURE::JobChange::VALUATION[1], 2)
    elsif $data_classes[@job].params[param_id, KURE::JobChange::VALUATION_LEVEL] > KURE::JobChange::STATUS_VALUATION[param_id][2] 
      draw_text(x + 70 + positionx, positiony, 36, line_height, KURE::JobChange::VALUATION[2], 2)
    elsif $data_classes[@job].params[param_id, KURE::JobChange::VALUATION_LEVEL] > KURE::JobChange::STATUS_VALUATION[param_id][3]  
      draw_text(x + 70 + positionx, positiony, 36, line_height, KURE::JobChange::VALUATION[3], 2)
    elsif $data_classes[@job].params[param_id, KURE::JobChange::VALUATION_LEVEL] > KURE::JobChange::STATUS_VALUATION[param_id][4]  
      draw_text(x + 70 + positionx, positiony, 36, line_height, KURE::JobChange::VALUATION[4], 2)
    else
      draw_text(x + 70 + positionx, positiony, 36, line_height, KURE::JobChange::VALUATION[5], 2)
    end
  end
  #--------------------------------------------------------------------------
  # ★ 職業説明の描画
  #--------------------------------------------------------------------------
  def draw_select_job_explan(x,y)
    #職業のメモ欄を取得
    job_note = $data_classes[@job].note
      str_s = job_note.index("<職業説明>")
      str_e = job_note.index("</職業説明>")
    if str_s != nil && str_e != nil
      job_explan = job_note.slice(str_s + 6..str_e - 1)
      job_explan = job_explan.split
      for i in 0..job_explan.size - 1
        draw_text(x + 5, y + line_height * i , contents_width, line_height, job_explan[i])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 職業ステータスの描画(選択不可)
  #--------------------------------------------------------------------------
  def draw_job_status_false(x,y)
    draw_text(x, y, contents_width, line_height, "Не выполнены условия смены профессии.")
    draw_condition(x, y + line_height * 2)
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ◎ 転職条件の描画(選択不可)
  #--------------------------------------------------------------------------
  def draw_condition(x,y)
    return if @job == nil
    draw_line = 0
    #チェック用の職業データを取得
    job = $data_classes[@job]
    return unless job
    
    #職業ダブリをチェック
    if job.id == @actor.sub_class_id
      draw_text(x, y, contents_width, line_height, "この職業はサブクラスに設定されています")
      return
    end
    
    if job.id == @actor.class_id
      draw_text(x, y, contents_width, line_height, "この職業はメインクラスに設定されています")
      return
    end
    
    #単独職かチェック
    if job.only_one_class
      for i in 0..$game_party.all_members.size - 1
        if $game_party.all_members[i].class_id == job.id
          draw_text(x, y, contents_width, line_height, "この職業は複数人が同時に就くことはできません")
          return
        end
      end
    end
    
    #両立不可職かどうかチェック
    if @edit_actor_class_kind == 0
      if job.not_same_time_jobchange_class.include?(@actor.sub_class_id)
        draw_text(x, y, contents_width, line_height, "この職業は現在のサブクラスと両立できません")
        return        
      end
    end
    
    if @edit_actor_class_kind == 1
      if job.not_same_time_jobchange_class.include?(@actor.class_id)
        draw_text(x, y, contents_width, line_height, "この職業は現在のメインクラスと両立できません")
        return        
      end
    end
    
    #レベルのチェック
    change_color(normal_color)
    change_color(power_down_color) if @actor.level < job.need_jobchange_level[0]
    if job.need_jobchange_level[0] != 0
      draw_text(x, y, contents_width, line_height, "Требуется уровень " + job.need_jobchange_level[0].to_s)
      draw_line +=1
    end
    
    #職業レベルのチェック
    change_color(normal_color)
    change_color(power_down_color) if @actor.joblevel < job.need_jobchange_level[1]
    if job.need_jobchange_level[1] != 0
      draw_text(x, y + line_height * draw_line, contents_width, line_height, "要求職業レベル　" + job.need_jobchange_level[1].to_s)
      draw_line +=1
    end
  
    #要求経験職のチェック
    if job.need_jobchange_class != []
      change_color(normal_color)
      draw_text(x, y + line_height * draw_line, 110, line_height, "要求経験職 ")
      for i in 0..job.need_jobchange_class.size - 1
        if i % 2 == 0
          change_color(power_down_color) if @actor.class_level_list[job.need_jobchange_class[i]] == nil
          if @actor.class_level_list[job.need_jobchange_class[i]] != nil
            change_color(power_down_color) if @actor.class_level_list[job.need_jobchange_class[i]] < job.need_jobchange_class[i + 1]
          end
        end
      end
      str = Array.new
      for i in 0..job.need_jobchange_class.size - 1
        if i % 2 == 0
          if @actor.class_level_list[job.need_jobchange_class[i]] != nil
            str.push($data_classes[job.need_jobchange_class[i]].name + " Lv" + job.need_jobchange_class[i + 1].to_s)
          else
            if $data_classes[job.need_jobchange_class[i]].view_class_name == false
              str.push("？？？？？")
            else
              str.push($data_classes[job.need_jobchange_class[i]].name + " Lv" + job.need_jobchange_class[i + 1].to_s)            
            end
          end
        end
      end
      for i in 0..str.size - 1
        if i % 2 == 0
          draw_text(x + 110, y + line_height * draw_line, (contents.width - 110) / 2, line_height, str[i])
          draw_text(x + 55 + contents.width / 2, y + line_height * draw_line, (contents.width - 110) / 2, line_height, str[i + 1])
          draw_line += 1
        end
      end
    end
    
    #選択経験職のチェック
    if job.select_jobchange_class != []
      change_color(normal_color)
      draw_text(x, y + line_height * draw_line, 110, line_height, "選択経験職 ")
      str = Array.new
      select_flag = 0
      for i in 0..job.select_jobchange_class.size - 1
        if i % 2 == 0
          if @actor.class_level_list[job.select_jobchange_class[i]] != nil
            select_flag = 1 if @actor.class_level_list[job.select_jobchange_class[i]] >= job.select_jobchange_class[i + 1]
            str.push($data_classes[job.select_jobchange_class[i]].name + " Lv" + job.select_jobchange_class[i + 1].to_s)
          else  
            if $data_classes[job.select_jobchange_class[i]].view_class_name == false
              str.push("？？？？？")
            else
              str.push($data_classes[job.select_jobchange_class[i]].name + " Lv" + job.select_jobchange_class[i + 1].to_s)             
            end
          end
        end
      end
      change_color(power_down_color) if select_flag == 0
      for i in 0..str.size - 1
        if i % 2 == 0
          draw_text(x + 110, y + line_height * draw_line, (contents.width - 110) / 2, line_height, str[i])
          draw_text(x + 55 + contents.width / 2, y + line_height * draw_line, (contents.width - 110) / 2, line_height, str[i + 1])
          draw_line += 1
        end
      end    
    end
    
    
    #要求未経験職をチェック
    if job.unless_need_jobchange_class != []
      change_color(normal_color)
      draw_text(x, y + line_height * draw_line, 110, line_height, "要求未経験職 ")
      str = Array.new
      for i in 0..job.unless_need_jobchange_class.size - 1
        change_color(power_down_color) if @actor.class_level_list[job.unless_need_jobchange_class[i]]
        str.push($data_classes[job.unless_need_jobchange_class[i]].name)
      end
      counter = 0 
      for i in 0..str.size - 1
        draw_text(x + 110 + ((contents.width - 110) / 3) * counter, y + line_height * draw_line, (contents.width - 110) / 3, line_height, str[i])
        draw_line += 1 if counter == 2
        counter += 1
        counter = 0 if counter == 3
      end
      counter = 0
      draw_line += 1
    end
    
    #転職前アクターチェック
    if job.need_jobchange_actor != []
      change_color(normal_color)
      draw_text(x, y + line_height * draw_line, 110, line_height, "転職可能者 ")
      change_color(power_down_color) if job.need_jobchange_actor.include?(@actor.id) == false
      str = Array.new     
      for i in 0..job.need_jobchange_actor.size - 1
        str.push($data_actors[job.need_jobchange_actor[i]].name)
      end      
      counter = 0 
      for i in 0..str.size - 1
        draw_text(x + 110 + ((contents.width - 110) / 3) * counter, y + line_height * draw_line, (contents.width - 110) / 3, line_height, str[i])
        draw_line += 1 if counter == 2
        counter += 1
        counter = 0 if counter == 3
      end
      counter = 0
      draw_line += 1
    end
    
    #転職要求スキルをチェック
    if job.need_jobchange_skill != []
      change_color(normal_color)
      draw_text(x, y + line_height * draw_line, 110, line_height, "要求スキル ")
      str = Array.new
      for i in 0..job.need_jobchange_skill.size - 1
        str.push($data_skills[job.need_jobchange_skill[i]].name)
        change_color(power_down_color) if @actor.skill_learn?($data_skills[job.need_jobchange_skill[i]]) == false
      end
      counter = 0 
      for i in 0..str.size - 1
        draw_text(x + 110 + ((contents.width - 110) / 3) * counter, y + line_height * draw_line, (contents.width - 110) / 3, line_height, str[i])
        draw_line += 1 if counter == 2
        counter += 1
        counter = 0 if counter == 3
      end
      counter = 0 
    end
    
    #転職要求スイッチをチェック
    if job.need_jobchange_swith != []
      change_color(normal_color)
      for i in 0..job.need_jobchange_swith.size - 1
        change_color(power_down_color) if $game_switches[job.need_jobchange_swith[i]] == false
      end
      draw_text(x, y + line_height * draw_line, contents.width, line_height, "特定条件を満たす")
      draw_line +=1
    end
    
    #転職要求アイテムをチェック
    if job.need_jobchange_item != []
      change_color(normal_color)
      draw_text(x, y + line_height * draw_line, 110, line_height, "必要アイテム")
      str = Array.new
      for i in 0..job.need_jobchange_item.size - 1
        str.push($data_items[job.need_jobchange_item[i]].name)
        change_color(power_down_color) if $game_party.item_number($data_items[job.need_jobchange_item[i]]) == 0
      end
      counter = 0 
      for i in 0..str.size - 1
        draw_text(x + 110 + ((contents.width - 110) / 3) * counter, y + line_height * draw_line, (contents.width - 110) / 3, line_height, str[i])
        draw_line += 1 if counter == 2
        counter += 1
        counter = 0 if counter == 3
      end
      counter = 0  
    end
  end
end

#==============================================================================
# ■ Window__k_Jobchange_Task_Command
#------------------------------------------------------------------------------
# 　選択肢を表示するウィンドウです。
#==============================================================================
class Window__k_Jobchange_Task_Command < Window_Command
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ◎ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return if @actor == nil
    add_main_sub_select_commands
  end
  #--------------------------------------------------------------------------
  # ● キャラ作成コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_main_sub_select_commands
    add_command("職業を変更する", :ok, true, 0) if KURE::JobChange::LOCK_MAIN_CLASS_SYSTEM == 0
    add_command("職業を変更する", :ok, true, 0) if KURE::JobChange::LOCK_MAIN_CLASS_SYSTEM != 0 && $game_switches[KURE::JobChange::LOCK_MAIN_CLASS_SYSTEM] == false
    if KURE::JobChange::UNLOCK_SUB_CLASS_SYSTEM == 0
      if $data_classes[@actor.class_id].seal_sub_class == false
        if KURE::BaseScript::USE_JOBLv == 1
          add_command("サブクラスを変更する", :ok, true, 1)
        else
          add_command("サブクラスを変更する", :ok, false, 1)
        end
      end
    else
      if $game_switches[KURE::JobChange::UNLOCK_SUB_CLASS_SYSTEM] == true
        if $data_classes[@actor.class_id].seal_sub_class == false
          if KURE::BaseScript::USE_JOBLv == 1
            add_command("サブクラスを変更する", :ok, true, 1)
          else
            add_command("サブクラスを変更する", :ok, false, 1)
          end
        end
      end
    end
    add_command("キャンセル", :cancel, true, 2)
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