#===============================================================================
#  ■拡張ステータス画面 for RGSS3 Ver2.10-β8
#　□author kure
#===============================================================================
module KURE
  module ExStatus
  #初期設定
    EX_SUB_STATUS_MENU = []
    VIEW_SUB_MENU = []
    UNIQ_ABILITY = []
    PROFILE = []
    PROFILE2 = []
    
    
  #描画方法の選択---------------------------------------------------------------
    #表示方法
    #VIEW_MODE(0=値を表示 1=補正値を表示)
    VIEW_MODE = 0
    
  #メインメニュー選択肢の設定---------------------------------------------------
    #メインメニューの表示名設定（後ろの数字はページ振り分けに使用します。）
    #EX_MAIN_STATUS_MENU = ["基本情報(0)","職業履歴(1)","装備情報(2)","プロフィール(3)"]
    EX_MAIN_STATUS_MENU = ["基本情報","職業履歴","装備情報",]
    
    #表示ページのリスト(選択肢に表示される項目)
    VIEW_MAIN_MENU = [0,1,2,]

  #サブメニュー選択肢の設定-----------------------------------------------------
    #サブメニューの使用可否(0=使用しない、1=使用する)
    #USE_SUB_MENU = [選択肢1,選択肢2,選択肢3,選択肢4]
    USE_SUB_MENU = [1,1,1,0]
    
    #サブメニューの選択肢の表示名
    #EX_SUB_STATUS_MENU[1] = ["基本能力値(0)","特殊能力(1)","パーティー能力(2)","属性耐性(3)","ステート耐性(4)","習得中スキル(5)","フリースペース(6)"]
    EX_SUB_STATUS_MENU[1] = ["基本能力値","特殊能力","パーティー能力","属性耐性","ステート耐性","習得中スキル","フリースペース"]
    
    #サブメニューのページリスト(選択肢に表示される項目)
    VIEW_SUB_MENU[1] = [0,1,2,3,4]
    
  #1-1ページ目描画対応、ステータス表示方法--------------------------------------
    #Vocab_Ex1 = [命中率,回避率,会心率,会心回避率,魔法回避率,魔法反射率,反撃率,HP再生率,MP再生率,TP再生率]
    Vocab_Ex1 = ["Меткость","Уворот","Крит. шанс","会心回避率","魔法回避率","魔法反射率","反撃率","HP再生率","MP再生率","TP再生率"]
    #表示、非表示切り替え(0=表示、1=非表示)
    VIEW_Ex1 = [0,0,0,0,0,0,0,0,0,0]
    
  #1-2ページ目描画対応、特殊能力値の表示方法------------------------------------
    #Vocab_Ex2 = [狙われ率,防御効果率,回復効果率,薬の知識,MP消費率,TPチャージ率,物理ダメージ率,魔法ダメージ率,床ダメージ率,経験獲得率]
    Vocab_Ex2 = ["狙われ率","防御効果率","回復効果率","薬の知識","MP消費率","TPチャージ率","物理ダメージ率","魔法ダメージ率","床ダメージ率","経験獲得率"]
    #表示、非表示切り替え(0=表示、1=非表示)
    VIEW_Ex2 = [0,0,0,0,0,0,0,0,0,0,0]

  #1-3ページ目描画対応、属性耐性の表示------------------------------------------
    #属性耐性を表示する項目を属性IDで選択します
    VIEW_ELEMENT_REGIST = [12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    
    #項目にアイコンを使用するかどうか(0=使用しない 1=使用する)
    ELEMENT_ICON = 0
    
    #アイコンリスト
    ELEMENT_ICON_LIST = [116,120,96,97,98,99,100,101,102,103]

  #1-4ページ目描画対応、ステート耐性の表示--------------------------------------
    #ステート耐性を表示する項目をステートIDで選択します
    VIEW_STATE_REGIST = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]
    
    #項目にアイコンを使用するかどうか(0=使用しない 1=使用する)
    STATE_ICON = 1
    
  #1-6ページ対応、フリースペース--------------------------------------------------
    #UNIQ_ABILITY[アクターID] = [描画内容1行目,…]
    #区切りはダブルクオテーション「"」ではなくシングルクオテーション「'」です
  
    UNIQ_ABILITY[1] = ['','',''] 
    UNIQ_ABILITY[2] = ['','',''] 
    UNIQ_ABILITY[3] = ['','','']
  
  #2ページ目描画対応------------------------------------------------------------
    #履歴が存在する職歴のみ表示(0=OFF、1=ON)
    VIEW_ONLY_IS_RECORD = 1
    
  #4-1ページ目描画対応----------------------------------------------------------
    #PROFILE_NUM = [アクター1の変数,アクター2の変数,…]
    #アクターのプロフィール描画の切り替え用の変数を指定します。
    #項目数はアクター数と同一にすること
    PROFILE_NUM = [1,0,0,0,0,0,0,0,0,0]
    
    #PROFILE[アクターID] = [
    #      変数未設定又は0 [立ち絵設定,プロフィール内容1行目,…],
    #              変数１  [立ち絵設定,プロフィール内容1行目,…],
    #                       …
    #                      ]
    #顔グラフィックは｢Picture｣フォルダに入れておくこと
    #
    #立ち絵設定(1 = 表示する ,ファイル名 = 指定ピクチャを表示, nil = 表示しない)
    #１を指定した場合、読み込まれる立ち絵ファイルのファイル名は「ファイル名-INDEX値です」
    #例）
    #『"Actor1"』のINDEX6番目のアクターの立ち絵ファイル名は『"Actor1-6"』とすること
    #
    #ファイル名で指定した場合は指定したファイル名を読み込みます。
    #
    #
    #区切りはダブルクオテーション「"」ではなくシングルクオテーション「'」です
    PROFILE[1] = [
                    [nil,
                    '変数未設定(=0)または0の時の描画です。',
                    ''],
                    
                    [1,
                    '変数の値が1の時の描画です。',
                    'プロフィールを変数で切り替えるには',
                    '項目を追加してください']                  
                 ]
    PROFILE[2] = [
                    [1,
                    'プロフィールの描画テストをしています',
                    '配列を使用して描画しているので、改行',
                    'したい場所で「,」で区切っていけばいいですね']
                 ]
    PROFILE[3] = [
                    [nil,
                    '顔文字を表示しない場合もテストしておきます。',
                    'nilを入れないと顔文字があると判断されるので',
                    '御注意を']
                 ]  
  #4-2ページ目描画対応----------------------------------------------------------
    #PROFILE_NUM2 = [アクター1の変数,アクター2の変数,…]
    #アクターのプロフィール描画の切り替え用の変数を指定します。
    #項目数はアクター数と同一にすること
    PROFILE_NUM2 = [1,0,0,0,0,0,0,0,0,0]
    
    #PROFILE2[アクターID] = [
    #      変数未設定又は0 [プロフィール内容1行目,…],
    #              変数１  [プロフィール内容1行目,…],
    #                       …
    #                      ]
    PROFILE2[1] = [
                    ['2ページ目の描画テストをしています']
                  ]
  end
end
#==============================================================================
# ■ Scene_Status(再定義)
#------------------------------------------------------------------------------
# 　ステータス画面の処理を行うクラスです。
#==============================================================================
class Scene_Status < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_status_main_command
    create_status_sub_command
    create_draw_window
    create_small_status_window
    
    window_setup
  end
  #--------------------------------------------------------------------------
  # ● メインコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_main_command
    @main_command_window = Window_k_ExStatus_Main_Command.new(0,0)
    @main_command_window.activate
    @main_command_window.select(0)
    @main_command_window.set_handler(:ok,   method(:select_main_command))
    @main_command_window.set_handler(:cancel,   method(:return_scene))
    @main_command_window.set_handler(:pagedown, method(:next_actor))
    @main_command_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● サブコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_sub_command
    x = 0
    y = @main_command_window.height + 24
    height = Graphics.height - @main_command_window.height - 24
    @sub_command_window = Window_k_ExStatus_Sub_Menu_Command.new(x,y,height)
    @sub_command_window.unselect
    @sub_command_window.opacity = 0
    @sub_command_window.z += 100 
    @sub_command_window.deactivate
    @sub_command_window.set_handler(:cancel,   method(:on_sub_command_cancel))
    @sub_command_window.set_handler(:pagedown, method(:next_actor))
    @sub_command_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● 描画領域ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_draw_window
    x = 0
    y = @main_command_window.height
    ww = Graphics.width
    wy = Graphics.height - @main_command_window.height
    @draw_window = Window_k_ExStatus_Draw.new(x,y,ww,wy)
    @draw_window.refresh    
  end
  #--------------------------------------------------------------------------
  # ● キャラクターのスモールステータスウィンドウ作成
  #--------------------------------------------------------------------------
  def create_small_status_window
    x = @main_command_window.width
    y = 0
    ww = Graphics.width - @main_command_window.width
    height = @main_command_window.height
    @status_window = Window_k_ExStatus_Small_Status.new(x,y,ww,height)    
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのセットアップ処理
  #--------------------------------------------------------------------------
  def window_setup
    @main_command_window.sub_command_window = @sub_command_window
    @main_command_window.draw_window = @draw_window
    @sub_command_window.draw_window = @draw_window
  end
  #--------------------------------------------------------------------------
  # ● メインコマンド→サブコマンド
  #--------------------------------------------------------------------------
  def select_main_command
    if KURE::ExStatus::USE_SUB_MENU[@main_command_window.index] == 0
      @main_command_window.activate
    else
      @main_command_window.deactivate
      @sub_command_window.select(0)
      @sub_command_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド→メインコマンド
  #--------------------------------------------------------------------------
  def on_sub_command_cancel
    @main_command_window.activate
    @sub_command_window.select(0)
    @sub_command_window.unselect
    @sub_command_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.refresh
    @draw_window.refresh
    @sub_command_window.refresh
    
    if @main_command_window.index > -1
      @main_command_window.activate
    end
    if @sub_command_window.index > -1
      @sub_command_window.activate
      @main_command_window.deactivate
    end
  end
end

#==============================================================================
# ■ Window_k_ExStatus_Main_Command
#------------------------------------------------------------------------------
# 　一般的なコマンド選択を行うウィンドウです。
#==============================================================================
class Window_k_ExStatus_Main_Command < Window_Command
  attr_accessor :sub_command_window
  attr_accessor :draw_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(4)
  end
  #--------------------------------------------------------------------------
  # ● →キーの処理
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    @draw_window.draw_index(1) if @draw_window
  end
  #--------------------------------------------------------------------------
  # ● ←キーの処理
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    @draw_window.draw_index(-1) if @draw_window
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    @sub_command_window.main_command_index = @index if @sub_command_window
    @draw_window.main_command_index = @index if @draw_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    for i in 0..KURE::ExStatus::VIEW_MAIN_MENU.size - 1
      add_command(KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[i]], :ok)
    end
  end
end

#==============================================================================
# ■ Window_k_ExStatus_Small_Status
#------------------------------------------------------------------------------
# 　メニュー画面でパーティメンバーのステータスを表示するウィンドウです。
#==============================================================================
class Window_k_ExStatus_Small_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :pending_index            # 保留位置（並び替え用）
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,width,height)
    super(x, y, width, height)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_status
    @actor = $game_party.menu_actor
    draw_actor_face(@actor, 0, 0)
    draw_actor_name(@actor, 100, line_height * 0)
    draw_actor_class(@actor, 220,line_height * 0)
    draw_actor_icons(@actor, 100,line_height * 2)
    draw_actor_level(@actor, 100,line_height * 1)
    draw_actor_hp(@actor, 220,line_height * 1)
    draw_actor_mp(@actor, 220,line_height * 2)
    draw_exp_info(100,line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_status
  end
end

#==============================================================================
# ■ Window_k_ExStatus_Sub_Menu_Command
#==============================================================================
class Window_k_ExStatus_Sub_Menu_Command < Window_Command
  attr_accessor :draw_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y,height)
    @height = height
    @main_command_index = 0
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    return if @index < 0
    @draw_window.sub_command_index = @index if @draw_window
    @draw_window.draw_sub_command_index = 0 if @draw_window
  end
  #--------------------------------------------------------------------------
  # ● →キーの処理
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    @draw_window.draw_sub_command_index(1) if @draw_window
  end
  #--------------------------------------------------------------------------
  # ● ←キーの処理
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    @draw_window.draw_sub_command_index(-1) if @draw_window
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 180
  end
  #--------------------------------------------------------------------------
  # ● メインコマンドインデックスの設定
  #--------------------------------------------------------------------------
  def main_command_index=(main_command_index)
    return if @main_command_index == main_command_index
    @main_command_index = main_command_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    @actor = $game_party.menu_actor
    case KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]
    when 0
      make_command_list_1
    when 1
      make_command_list_2
    when 2
      make_command_list_3
    when 3
      make_command_list_4
    when 4
      make_command_list_5
    end
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド１の作成
  #--------------------------------------------------------------------------
  def make_command_list_1
    for i in 0..KURE::ExStatus::VIEW_SUB_MENU[1].size - 1
      add_command(KURE::ExStatus::EX_SUB_STATUS_MENU[1][KURE::ExStatus::VIEW_SUB_MENU[1][i]], :ok)
    end
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド２の作成
  #--------------------------------------------------------------------------
  def make_command_list_2
    if KURE::BaseScript::USE_JobChange == 1
      for i in 0..KURE::JobChange::JOB_GRADE_LIST.size - 1
        add_command(KURE::JobChange::JOB_GRADE_LIST[i], :ok)
      end
    else
      add_command("職業履歴", :ok)
    end 
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド３の作成
  #--------------------------------------------------------------------------
  def make_command_list_3
    for i in 0...@actor.equip_slots.size
      if @actor.equips[i] == nil    
        add_command("", :ok)
      else
        add_command(@actor.equips[i].name, :ok)
      end
    end 
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド４の作成
  #--------------------------------------------------------------------------
  def make_command_list_4
    
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド５の作成
  #--------------------------------------------------------------------------
  def make_command_list_5
    
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return @height
  end
end

#==============================================================================
# ■ Window_k_ExStatus_Draw
#------------------------------------------------------------------------------
# 　描画領域
#==============================================================================
class Window_k_ExStatus_Draw < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @main_command_index = 0
    @sub_command_index = 0
    @draw_index = 0
    @draw_sub_command_index = 0
    @roop_call = 6
  end
  #--------------------------------------------------------------------------
  # ● メインコマンドインデックスの設定
  #--------------------------------------------------------------------------
  def main_command_index=(main_command_index)
    return if @main_command_index == main_command_index
    @main_command_index = main_command_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● サブコマンドインデックスの設定
  #--------------------------------------------------------------------------
  def sub_command_index=(sub_command_index)
    return if @sub_command_index == sub_command_index
    @sub_command_index = sub_command_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画メインインデックスの設定
  #--------------------------------------------------------------------------
  def draw_index=(draw_index)
    return if @draw_index == draw_index
    @draw_index = draw_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画サブインデックスの設定
  #--------------------------------------------------------------------------
  def draw_sub_command_index=(draw_sub_command_index)
    @draw_sub_command_index += draw_sub_command_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画メインインデックスの設定
  #--------------------------------------------------------------------------
  def draw_index(value)
    @draw_index += value 
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描画サブインデックスの設定
  #--------------------------------------------------------------------------
  def draw_sub_command_index(value)
    @draw_sub_command_index += value 
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @actor = $game_party.menu_actor
    contents.clear
    case KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]
    when 0
      page_1_draw
    when 1
      page_2_draw
    when 2
      page_3_draw
    when 3
      page_4_draw
    end
  end
  #--------------------------------------------------------------------------
  # ● 基本情報(1ページの描画)
  #--------------------------------------------------------------------------
  def page_1_draw    
    draw_gauge(0,0, 155, 1, mp_gauge_color2,crisis_color)
    draw_text(0, 0, 126, line_height,KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]])
    
    case KURE::ExStatus::VIEW_SUB_MENU[1][@sub_command_index]
    when 0
      page_1_1_draw
    when 1
      page_1_2_draw
    when 2
      page_1_3_draw
    when 3
      page_1_4_draw
    when 4
      page_1_5_draw
    when 5
      page_1_6_draw
    when 6
      page_1_7_draw
    end
  end
  #--------------------------------------------------------------------------
  # ● 基本能力値(1-1ページの描画)
  #--------------------------------------------------------------------------
  def page_1_1_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, "基本能力値")
    
    8.times {|i| draw_actor_param(@actor, 160, line_height * 1, i) }
    
    draw_gauge(160,line_height * 5, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, line_height * 5, 200, line_height, "追加能力値")    

    @draw_postion_xparam = 0
    10.times {|i| draw_actor_param(@actor, 160, line_height * 6, i + 9) }
  end
  #--------------------------------------------------------------------------
  # ● 特殊能力(1-2ページの描画)
  #--------------------------------------------------------------------------
  def page_1_2_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, "特殊能力値")
    
    @draw_postion_sparam = 0
    10.times {|i| draw_actor_param(@actor, 160, line_height * 1, i + 20) }
    
    draw_gauge(160,line_height * 7, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, line_height * 7, 200, line_height, "アクター能力")
    
    draw_actor_self_features(@actor, 160, line_height * 8)
  end 
  #--------------------------------------------------------------------------
  # ● 能力値の描画(1-1、1-2ページの描画)
  #--------------------------------------------------------------------------
  def draw_actor_param(actor, x, y, param_id)
    case param_id
    when 0,2,4,6
      change_color(system_color)
      draw_text(x, y + line_height * (param_id / 2), 120, line_height, Vocab::param(param_id))
      change_color(normal_color)
      draw_text(x + 120, y + line_height * (param_id / 2), 50, line_height, actor.param(param_id), 2)
    when 1,3,5,7  
      change_color(system_color)
      draw_text(x + (contents.width - x)/2, y + line_height * ((param_id - 1)/ 2), 120, line_height, Vocab::param(param_id))
      change_color(normal_color)
      draw_text(x + (contents.width - x)/2 + 120, y + line_height * ((param_id - 1)/ 2), 50, line_height, actor.param(param_id), 2)    

    when 9,10,11,12,13,14,15,16,17,18
      if KURE::ExStatus::VIEW_Ex1[param_id - 9] != 0
        @draw_postion_xparam += 1 
      else
        value = (@actor.xparam(param_id - 9) * 100).to_i
        draw_str = draw_value_s(value,0)
        draw_pos_xparam = (param_id - 9) - @draw_postion_xparam
      
        case draw_pos_xparam
        when 0,2,4,6,8
          change_color(system_color)
          draw_text(x, y + line_height * (draw_pos_xparam / 2), 120, line_height, KURE::ExStatus::Vocab_Ex1[param_id - 9])
          change_color(normal_color)
          draw_text(x + 120, y + line_height * (draw_pos_xparam / 2), 50, line_height, draw_str, 2)        
        when 1,3,5,7,9
          change_color(system_color)
          draw_text(x + (contents.width - x)/2, y + line_height * ((draw_pos_xparam - 1)/ 2), 120, line_height, KURE::ExStatus::Vocab_Ex1[param_id - 9])
          change_color(normal_color)
          draw_text(x + (contents.width - x)/2 + 120, y + line_height * ((draw_pos_xparam - 1)/ 2), 50, line_height, draw_str, 2)
        end
      end
      
    when 20,21,22,23,24,25,26,27,28,29,30
      if KURE::ExStatus::VIEW_Ex2[param_id - 20] != 0
        @draw_postion_sparam += 1
      else
        value = (@actor.sparam(param_id - 20) * 100).to_i
        draw_str = draw_value_s(value,100)
        draw_pos_sparam = (param_id - 20) - @draw_postion_sparam
      
        case draw_pos_sparam
        when 0,2,4,6,8
          change_color(system_color)
          draw_text(x, y + line_height * (draw_pos_sparam / 2), 120, line_height, KURE::ExStatus::Vocab_Ex2[param_id - 20])
          change_color(normal_color)
          draw_text(x + 120, y + line_height * (draw_pos_sparam / 2), 50, line_height, draw_str, 2)        
        when 1,3,5,7,9
          change_color(system_color)
          draw_text(x + (contents.width - x)/2, y + line_height * ((draw_pos_sparam - 1)/ 2), 120, line_height, KURE::ExStatus::Vocab_Ex2[param_id - 20])
          change_color(normal_color)
          draw_text(x + (contents.width - x)/2 + 120, y + line_height * ((draw_pos_sparam - 1)/ 2), 50, line_height, draw_str, 2)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● アクター能力の描画(1-2ページの描画)
  #--------------------------------------------------------------------------
  def draw_actor_self_features(actor, x, y)
    draw_counter = 0
    for i in 0..@actor.all_features.size - 1
      #二刀流チェック
      if @actor.all_features[i].code == 55
        if draw_counter < 3
          draw_text(x + ((contents.width - x)/3) * draw_counter, y + line_height * 0,(contents.width - 10)/3,line_height,"二刀流")
        else
          draw_text(x + ((contents.width - x)/3) * (draw_counter - 3), y + line_height * 1,(contents.width - 10)/3,line_height,"二刀流")
        end
        draw_counter += 1
      end
      
      #特殊フラグチェック
      if @actor.all_features[i].code == 62
        case @actor.all_features[i].data_id
        when 0
          value = "自動戦闘"
        when 1
          value = "自動防御"
        when 2
          value = "自動献身"
        when 3
          value = "TP持越し"
        end
        if draw_counter < 3
          draw_text(x + ((contents.width - x)/3) * draw_counter, y + line_height * 0,(contents.width - 10)/3,line_height,value)
        else
          draw_text(x + ((contents.width - x)/3) * (draw_counter - 3), y + line_height * 1,(contents.width - 10)/3,line_height,value)
        end
        draw_counter += 1
      end
    end
    
    draw_counter = 0
    for add in 0..0    
      if @actor.battler_add_ability(add) != 1
        case add
        when 0
          value = "スティール成功率" + (@actor.battler_add_ability(add).to_f).to_s + "倍"
        end
        draw_text(x , y + line_height * (draw_counter + 2), contents.width / 2,line_height,value)
        draw_counter += 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● パーティー能力(1-3ページの描画)
  #--------------------------------------------------------------------------
  def page_1_3_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, "パーティ能力")
        
    draw_actor_party_features(@actor, 160, line_height * 1)
  end 
  #--------------------------------------------------------------------------
  # ● パーティー能力の描画(1-3ページの描画)
  #--------------------------------------------------------------------------
  def draw_actor_party_features(actor, x, y)
    draw_counter = 0
    for i in 0..@actor.all_features.size - 1      
      #パーティーフラグチェック
      if @actor.all_features[i].code == 64
        case @actor.all_features[i].data_id
        when 0
          value = "エンカウント率半減"
        when 1
          value = "エンカウント無効"
        when 2
          value = "不意打ち無効"
        when 3
          value = "先制攻撃率アップ"
        when 4
          value = "獲得金額２倍"              
        when 5
          value = "アイテム入手率２倍"   
        end
        draw_text(x , y + line_height * draw_counter, contents.width / 2,line_height,value)
        draw_counter += 1
      end
    end
    
    for j in 0..5
      if @actor.party_add_ability(j) != 1
        case j
        when 0
          value = "獲得金額" + @actor.party_add_ability(j).to_s + "倍"
        when 1
          value = "アイテム入手率" + @actor.party_add_ability(j).to_s + "倍"
        when 2
          value = "エンカウント率" + @actor.party_add_ability(j).to_s + "倍"
        when 3
          value = "獲得経験値倍率" + @actor.party_add_ability(j).to_s + "倍"
        when 4
          value = "獲得職業経験値倍率" + @actor.party_add_ability(j).to_s + "倍"
        when 5
          value = "獲得装備経験値倍率" + @actor.party_add_ability(j).to_s + "倍"
        end
        draw_text(x , y + line_height * draw_counter, contents.width / 2,line_height,value)
        draw_counter += 1      
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 属性耐性(1-4ページの描画)
  #--------------------------------------------------------------------------
  def page_1_4_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, "属性耐性(属性吸収)")
    
    #1ページの最大描画数、ページ数を取得
    elements = KURE::ExStatus::VIEW_ELEMENT_REGIST.size
    max_list = (((contents.height - 48) / line_height).to_i) * 2
    max_page = (elements / max_list).to_i + 1
    
    #ページ切り替えによる表示項目を取得
    @draw_sub_command_index = 0 if @draw_sub_command_index > max_page - 1
    @draw_sub_command_index = max_page - 1 if @draw_sub_command_index < 0
    first_num = max_list * @draw_sub_command_index + 1
    last_num = [(max_list * (@draw_sub_command_index + 1)), elements].min + 1   
    
    (last_num - first_num).times {|i| draw_actor_elements_regist(@actor, 160, line_height * 1, i + first_num, i + 1, max_page)}   
  end
  #--------------------------------------------------------------------------
  # ● 属性耐性の描画(1-4ページの描画)
  #--------------------------------------------------------------------------
  def draw_actor_elements_regist(actor, x, y, element_id, pos, max_page)
    use_icon = 0
    use_icon = 24 if KURE::ExStatus::ELEMENT_ICON == 1
    if element_id % 2 != 0
      value = 100 - (@actor.element_rate(KURE::ExStatus::VIEW_ELEMENT_REGIST[element_id - 1])*100).to_i
      draw_str = draw_value_s(value,0)
      
      value2 = (@actor.elements_drain_rate(KURE::ExStatus::VIEW_ELEMENT_REGIST[element_id - 1])*100).to_i
      draw_str2 = "(" if value2 >= 100 
      draw_str2 = "( " if value2 >= 10
      draw_str2 = "(  "  if value2 < 10 
      draw_str2 += draw_value_s(value2,0) + ")"

      change_color(system_color)
      count = (pos - 1) / 2
      draw_icon(KURE::ExStatus::ELEMENT_ICON_LIST[element_id - 1], x, y + line_height * count) if KURE::ExStatus::ELEMENT_ICON == 1 
      draw_text(x + use_icon, y + line_height * count, 45, line_height, $data_system.elements[KURE::ExStatus::VIEW_ELEMENT_REGIST[element_id - 1]])
      change_color(normal_color)
      draw_text(x + 45 + use_icon, y + line_height * count, 48, line_height, draw_str, 2)
      draw_text(x + 93 + use_icon, y + line_height * count, 62, line_height, draw_str2, 2)
    else
      value = 100 - (@actor.element_rate(KURE::ExStatus::VIEW_ELEMENT_REGIST[element_id - 1])*100).to_i
      draw_str = draw_value_s(value,0)
      
      value2 = (@actor.elements_drain_rate(KURE::ExStatus::VIEW_ELEMENT_REGIST[element_id - 1])*100).to_i
      draw_str2 = "(" if value2 >= 100 
      draw_str2 = "( " if value2 >= 10 && value2 < 100
      draw_str2 = "(  "  if value2 < 10 
      draw_str2 += draw_value_s(value2,0) + ")"
      
      count = (pos - 2) / 2
      change_color(system_color)
      draw_icon(KURE::ExStatus::ELEMENT_ICON_LIST[element_id - 1], x + (contents.width - x)/2, y + line_height * count) if KURE::ExStatus::ELEMENT_ICON == 1
      draw_text(x + (contents.width - x)/2 + use_icon, y + line_height * count, 45, line_height, $data_system.elements[KURE::ExStatus::VIEW_ELEMENT_REGIST[element_id - 1]])
      change_color(normal_color)
      draw_text(x + (contents.width - x)/2 + 45 + use_icon, y + line_height * count, 48, line_height, draw_str, 2)
      draw_text(x + (contents.width - x)/2 + 93 + use_icon, y + line_height * count, 62, line_height, draw_str2, 2)
    end
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →: Страница (" + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + ")" ,1)
  end
  #--------------------------------------------------------------------------
  # ● ステート耐性(1-5ページの描画)
  #--------------------------------------------------------------------------
  def page_1_5_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, "ステート耐性")
        
    #1ページの最大描画数、ページ数を取得
    state = KURE::ExStatus::VIEW_STATE_REGIST.size
    max_list = (((contents.height - 48) / line_height).to_i) * 2
    max_page = (state / max_list).to_i + 1
    
    #ページ切り替えによる表示項目を取得
    @draw_sub_command_index = 0 if @draw_sub_command_index > max_page - 1
    @draw_sub_command_index = max_page - 1 if @draw_sub_command_index < 0
    first_num = max_list * @draw_sub_command_index + 1
    last_num = [(max_list * (@draw_sub_command_index + 1)), state].min + 1   
    
    (last_num - first_num).times {|i| draw_actor_state_regist(@actor, 160, line_height * 1, i + first_num, i + 1, max_page)}    
  end
  #--------------------------------------------------------------------------
  # ● ステート耐性の描画(1-5ページの描画)
  #--------------------------------------------------------------------------
  def draw_actor_state_regist(actor, x, y, state_id, pos, max_page)
    use_icon = 0
    use_icon = 24 if KURE::ExStatus::STATE_ICON == 1
    
    if state_id % 2 != 0
      #無効化をチェック
      flag = 0
      for i in 0..@actor.all_features.size - 1
        if @actor.all_features[i].code == 14
          if KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1] == @actor.all_features[i].data_id
            flag = @actor.all_features[i].data_id
          end
        end
      end
      
      #描画
      if flag != 0
        if flag == KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1]
          draw_str = "無効"
        else
          value = 100 - (@actor.state_rate(KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1])*100).to_i
          draw_str = draw_value_s(value,0)
        end
      else
        value = 100 - (@actor.state_rate(KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1])*100).to_i
        draw_str = draw_value_s(value,0)
      end
      
      change_color(system_color)
      count = (pos - 1) / 2
      draw_icon($data_states[KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1]].icon_index, x, y + line_height * count) if KURE::ExStatus::STATE_ICON == 1
      draw_text(x + use_icon, y + line_height * count, 70, line_height, $data_states[KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1]].name)
      change_color(normal_color)
      
      draw_text(x + 70 + use_icon, y + line_height * count, 50, line_height, draw_str, 2)
    else
      #無効化をチェック
      flag = 0
      for i in 0..@actor.all_features.size - 1
        if @actor.all_features[i].code == 14
          if KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1] == @actor.all_features[i].data_id
            flag = @actor.all_features[i].data_id
          end
        end
      end
      
      #描画
      if flag != 0
        if flag == KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1]
          draw_str = "無効"
        else
          value = 100 - (@actor.state_rate(KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1])*100).to_i
          draw_str = draw_value_s(value,0)
        end
      else
        value = 100 - (@actor.state_rate(KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1])*100).to_i
        draw_str = draw_value_s(value,0)
      end
      
      count = (pos - 2) / 2
      change_color(system_color)
      draw_icon($data_states[KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1]].icon_index, x + (contents.width - x)/2, y + line_height * count) if KURE::ExStatus::STATE_ICON == 1
      draw_text(x + (contents.width - x)/2 + use_icon, y + line_height * count, 70, line_height, $data_states[KURE::ExStatus::VIEW_STATE_REGIST[state_id - 1]].name)
      change_color(normal_color)
            
      draw_text(x + (contents.width - x)/2 + 70 + use_icon, y + line_height * count, 50, line_height, draw_str, 2)
    end
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →: Страница (" + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + ")" ,1)
  end
  #--------------------------------------------------------------------------
  # ● 習得中スキルリスト(1-6ページの描画)
  #--------------------------------------------------------------------------
  def page_1_6_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, "習得中スキルリスト")
    
    #アビリティポイントを取得
    ap_list = @actor.ability_point
    
    #描画用配列にIDとポイント出力する
    draw_list = Array.new
    for ap in 1..ap_list.size - 1
      #値があれば出力する
      if ap_list[ap] 
        draw_list.push([ap,ap_list[ap]])
      end
    end
    skill_size = draw_list.size
    
    #1ページの最大描画数、ページ数を取得
    max_list = ((contents.height - 48) / line_height).to_i
    max_page = (skill_size / max_list).to_i + 1
    
    #ページ切り替えによる表示項目を取得
    @draw_sub_command_index = 0 if @draw_sub_command_index > max_page - 1
    @draw_sub_command_index = max_page - 1 if @draw_sub_command_index < 0
    first_num = max_list * @draw_sub_command_index
    last_num = [(max_list * (@draw_sub_command_index + 1)), draw_list.size].min
    
    count = 0
    for skill_id in first_num..last_num - 1
      n_ap = draw_list[skill_id][1]
      m_ap = $data_skills[draw_list[skill_id][0]].need_ability_point
      
      draw_item_name($data_skills[draw_list[skill_id][0]], 160, line_height * (count + 1))
      
      if @actor.skill_learn?($data_skills[draw_list[skill_id][0]])
        draw_text(contents.width - 105, line_height * (count + 1), 105, line_height, "MASTER" , 2)
      else
        draw_text(contents.width - 105, line_height * (count + 1), 40, line_height, n_ap.to_s, 2)
        draw_text(contents.width - 65, line_height * (count + 1), 25, line_height,"/")
        draw_text(contents.width - 40, line_height * (count + 1), 40, line_height, m_ap.to_s , 2)
      end
      count += 1
    end
    
    max_page = 1 if max_page == 0
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →: Страница (" + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + ")" ,1)
  end
  #--------------------------------------------------------------------------
  # ● 個人能力リスト(1-7ページの描画)
  #--------------------------------------------------------------------------
  def page_1_7_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, KURE::ExStatus::EX_SUB_STATUS_MENU[1][6])
    
    draw_uniq_ability = KURE::ExStatus::UNIQ_ABILITY[@actor.id]
    counter = 1
    
    return unless draw_uniq_ability
    return if draw_uniq_ability == []
    
    for line in 0..draw_uniq_ability.size - 1
      draw_text(160, line_height * counter, contents.width - 160, line_height, draw_uniq_ability[line])
      counter += 1
    end
    
  end
  #--------------------------------------------------------------------------
  # ■ 職業履歴(2ページの描画)
  #--------------------------------------------------------------------------
  def page_2_draw  
    draw_gauge(0,0, 155, 1, mp_gauge_color2,crisis_color)
    draw_text(0, 0, 126, line_height,KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]])
    
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    if KURE::BaseScript::USE_JOBLv == 1
      draw_text(160, 0, 200, line_height, KURE::JobChange::JOB_GRADE_LIST[@sub_command_index] + " の職業履歴")
    else
      draw_text(160, 0, 200, line_height, "職業履歴")
    end
    draw_job_exp(160,line_height * 1)
  end
  #--------------------------------------------------------------------------
  # ■ 職業経験の描画
  #--------------------------------------------------------------------------
  def draw_job_exp(x,y)
    #縦の描画項目数を取得
    draw_contents_number = ((contents.height - line_height * 2) / line_height).to_i
    
    #全職業リストからグレードを設定している職業を選びだす
    draw_line = 1
    draw_x_plus = 0
    draw_counter = 0
    
    select_grade_job = Array.new 
    #選択グレードのクラス配列を作成する
    for i in 1..$data_classes.size - 1
      if KURE::BaseScript::USE_JobChange == 1
        if $data_classes[i].class_lank == @sub_command_index + 1
          if $data_classes[i].need_jobchange_actor == [] or $data_classes[i].need_jobchange_actor.include?(@actor.id)
            select_grade_job.push($data_classes[i]) if KURE::ExStatus::VIEW_ONLY_IS_RECORD == 0 or @actor.class_level_list[i] != nil
          end
        end
      else
        select_grade_job.push($data_classes[i]) if KURE::ExStatus::VIEW_ONLY_IS_RECORD == 0 or @actor.class_level_list[i] != nil
      end
    end
    
    #取得したクラス配列を処理
    draw_max = select_grade_job.size - 1
    max_page = (draw_max / (draw_contents_number * 2)).to_i + 1
    
    @draw_sub_command_index = 0 if @draw_sub_command_index > max_page - 1
    @draw_sub_command_index = max_page - 1 if @draw_sub_command_index < 0
    
    @draw_sub_command_index = 0 if @draw_sub_command_index < 0
  
    draw_start = 0 + (draw_contents_number * 2) * @draw_sub_command_index
    draw_end = ((draw_contents_number * 2) - 1) + (draw_contents_number * 2) * @draw_sub_command_index
    draw_end = draw_max if draw_end > draw_max
    
    if draw_start <= draw_end
    for i in draw_start..draw_end
      #2列目に入れば描画位置を変更
      if draw_line > draw_contents_number
        draw_line = 1
        draw_x_plus = (contents.width - 160) / 2
      end
      
      if select_grade_job[i]
      if @actor.class_level_list[select_grade_job[i].id] != nil
        change_color(normal_color)
        change_color(tp_gauge_color2) if select_grade_job[i].id == @actor.class_id
        change_color(mp_gauge_color2) if select_grade_job[i].id == @actor.sub_class_id
        lv = "Ур."
        lv += " " if @actor.class_level_list[select_grade_job[i].id] < 10
        draw_text(x + draw_x_plus, y + line_height * (draw_line - 1), 130, line_height, select_grade_job[i].name)
        draw_text(x + draw_x_plus, y + line_height * (draw_line - 1), (contents.width - 160) / 2 - 5, line_height, lv + @actor.class_level_list[select_grade_job[i].id].to_s, 2)
        change_color(normal_color)
      else
        change_color(normal_color, false)
        if select_grade_job[i].view_class_name == true
          draw_text(x + draw_x_plus, y + line_height * (draw_line -1), 130, line_height, select_grade_job[i].name)
        else
          exp_flag = 0
          for k in 0..$data_actors[@actor.id].exp_jobchange_class.size - 1
            if k % 2 == 0
              exp_flag = 1 if $data_actors[@actor.id].exp_jobchange_class[k] == select_grade_job[i].id
            end
          end
          
          if exp_flag == 1
            draw_text(x + draw_x_plus, y + line_height * (draw_line - 1), 130, line_height, select_grade_job[i].name)
          else
            draw_text(x + draw_x_plus, y + line_height * (draw_line - 1), (contents.width - 160) / 2 - 5, line_height, "？？？？？")
          end
        end
        draw_text(x + draw_x_plus, y + line_height * (draw_line - 1), (contents.width - 160) / 2 - 5, line_height, "Lv -", 2)
        change_color(normal_color)
      end
      draw_line += 1
      draw_counter += 1
      end
    end    
    end
    
    max_page = 1 if max_page == 0
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →: Страница (" + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + ")" ,1)
  end
  #--------------------------------------------------------------------------
  # ▲ 基本情報(3ページの描画)
  #--------------------------------------------------------------------------
  def page_3_draw    
    draw_gauge(0,0, 155, 1, mp_gauge_color2,crisis_color)
    draw_text(0, 0, 126, line_height,KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]])
    
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    max = 1
    max = 2 if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::USE_SLOT_EQUIP == 1
    
    @draw_sub_command_index = 0 if @draw_sub_command_index > max
    @draw_sub_command_index = max if @draw_sub_command_index < 0
    
    case @draw_sub_command_index
    when 0
      draw_text(160, 0, 200, line_height, "装備アイテム詳細")
      draw_equipments_status(160,line_height * 1)
      
      if KURE::BaseScript::USE_ExEquip == 1
        draw_gauge(160,line_height * 6, contents.width - 160, 1, mp_gauge_color2,crisis_color)
        draw_text(160, line_height * 6, 200, line_height, "装備アイテム追加情報")
        draw_equipments_add_status(160,line_height * 7)
      end
      
      if KURE::BaseScript::USE_SortOut == 0
        draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →: Страница (1 / 2)",1)
      else
        if KURE::SortOut::USE_SLOT_EQUIP == 1
          draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →: Страница (1 / 3)",1)
        else
          draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →: Страница (1 / 2)",1) 
        end
      end
    when 1
      draw_text(160, 0, 200, line_height, "装備アイテム特徴")
      draw_equipments_features(160,line_height * 1)
      
      if KURE::BaseScript::USE_SortOut == 0
        draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →: Страница (2 / 2)",1)
      else
        if KURE::SortOut::USE_SLOT_EQUIP == 1
          draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →: Страница (2 / 3)",1)
        else
          draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →: Страница (2 / 2)",1) 
        end
      end
    when 2
      draw_text(160, 0, 200, line_height, "装備スロット")
      draw_equipments_slot(160,line_height * 1)
      
      draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →: Страница (3 / 3)",1)
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 装備品の描画(3ページ目、INDEX0)
  #--------------------------------------------------------------------------
  def draw_equipments_status(x, y)
    #装備名を描画
    draw_item_name(@actor.equips[@sub_command_index], x, y) if @actor.equips[@sub_command_index] != nil 
      
    #上昇ステータスを描画
    for i in 0..7
      case i
      when 0,2,4,6
        change_color(system_color)
        draw_text(x, y + line_height * ((i / 2)+1), 120, line_height, Vocab::param(i))
        if @actor.equips[@sub_command_index] != nil
          change_color(normal_color)
          draw_text(x + 120, y + line_height * ((i / 2)+1), 50, line_height, @actor.equips[@sub_command_index].params[i], 2)
        end
      when 1,3,5,7  
        change_color(system_color)
        draw_text(x + (contents.width - x)/2, y + line_height * ((i + 1)/ 2), 120, line_height, Vocab::param(i))
        if @actor.equips[@sub_command_index] != nil
          change_color(normal_color)
          draw_text(x + (contents.width - x)/2 + 120, y + line_height * ((i + 1)/ 2), 50, line_height, @actor.equips[@sub_command_index].params[i], 2)    
        end
      end
      change_color(normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 装備品の描画(3ページ目、INDEX0)
  #--------------------------------------------------------------------------
  def draw_equipments_add_status(x, y)
    counter = 0
    #装備重量の判定
    if KURE::ExEquip::USE_WEIGHT_SYSTEM == 1
      change_color(system_color)
      draw_text(x, y + line_height * counter, 120, line_height, "装備重量")
      if @actor.equips[@sub_command_index] != nil
        change_color(normal_color)
        draw_text(x + 120, y + line_height * counter, 50, line_height, @actor.equips[@sub_command_index].weight, 2)
      end
      
      change_color(system_color)
      draw_text(x + (contents.width - x)/2, y + line_height * counter, 120, line_height, "最大重量増加量")
      if @actor.equips[@sub_command_index] != nil
        change_color(normal_color)
        draw_text(x + (contents.width - x)/2 + 120, y + line_height * counter, 50, line_height, @actor.equips[@sub_command_index].gain_weight, 2) 
      end
      counter += 1
    end
    
    #装備Lvの判定
    if KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
      change_color(system_color)
      draw_text(x, y + line_height * counter, 120, line_height, "装備レベル")
      if @actor.equips[@sub_command_index] != nil
        change_color(normal_color)
        draw_text(x + 120, y + line_height * counter, 50, line_height, @actor.equips[@sub_command_index].need_equip_level, 2)
      end
    
      change_color(system_color)
      draw_text(x + (contents.width - x)/2, y + line_height * counter, 120, line_height, "装備職業レベル")
      if @actor.equips[@sub_command_index] != nil
        change_color(normal_color)
        draw_text(x + (contents.width - x)/2 + 120, y + line_height * counter, 50, line_height, @actor.equips[@sub_command_index].need_equip_joblevel, 2) 
      end
      counter += 1
    end
    
    #スロット、耐久値の判定
    if KURE::BaseScript::USE_SortOut == 1
      if KURE::SortOut::USE_SLOT_EQUIP == 1
        change_color(system_color)
        draw_text(x, y + line_height * counter, 120, line_height, "スロット数")
        if @actor.equips[@sub_command_index] != nil
          change_color(normal_color)
          draw_text(x + 120, y + line_height * counter, 50, line_height, @actor.equips[@sub_command_index].max_slot_number, 2)
        end
      end
    
      if KURE::SortOut::USE_DURABLE == 1
        change_color(system_color)
        draw_text(x + (contents.width - x)/2, y + line_height * counter, 120, line_height, "耐久値")
        if @actor.equips[@sub_command_index] != nil
          change_color(normal_color)
          draw_text(x + (contents.width - x)/2 + 120, y + line_height * counter, 50, line_height, @actor.equips[@sub_command_index].durable_value, 2) 
        end
      end
    
      counter += 1
    end
    
    
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ▲ 装備品の特徴(3ページ目、INDEX1)
  #--------------------------------------------------------------------------
  def draw_equipments_features(x, y)
    if @actor.equips[@sub_command_index] != nil

    features_max = @actor.equips[@sub_command_index].features.size - 1
  
    #描画用配列を作成
    draw_list = Array.new
    #配列用カウンターをセット
    draw_counter = 0
    
    #アイテムをセット
    item = @actor.equips[@sub_command_index]
          
  #攻撃属性がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 31
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_system.elements[keep[drow]]
          draw_list[draw_counter] = draw_str + "属性 "
          draw_counter += 1
        end
      end
      
  #属性耐性がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 11
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = $data_system.elements[drow]+ "耐性"
          value = 100 - (keep[drow] * 100).to_i
          if value != 0
            draw_list[draw_counter] = draw_str + value.to_s + "% "
            draw_counter += 1
          end
        end
      end
      
  #弱体化有効度がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 12
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = "耐"+Vocab::param(drow)+ "減少"
          value = 100 - (keep[drow] * 100).to_i
          if value != 0
            draw_list[draw_counter] = draw_str + value.to_s + "% "
            draw_counter += 1
          end
        end
      end
      
  #ステート耐性がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 13
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = $data_states[drow].name + "耐性"
          value = 100 - (keep[drow] * 100).to_i
          if value != 0
            draw_list[draw_counter] = draw_str + value.to_s + "% "
            draw_counter += 1
          end
        end
      end
      
  #ステート無効化がある場合
      keep = [] 
      #項目をチェックして描画用配列に入れる
      for l in 0..features_max
        if item.features[l].code == 14
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_states[keep[drow]].name
          draw_list[draw_counter] = draw_str + "無効"
          draw_counter += 1
        end
      end
      
  #通常能力値判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 21
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          #ステータス名取得
          draw_str = Vocab::param(drow)
          value = (keep[drow] * 100).to_i - 100
            if value > 0
              value = "+" + value.to_s
            end
          if value != 0
            draw_list[draw_counter] = draw_str + value.to_s + "% "
            draw_counter += 1
          end
        end
      end
              
  #特殊能力値判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 22
          keep[item.features[l].data_id] = 0 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] += item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          #ステータス名取得
          case drow
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
          value = (keep[drow] * 100).to_i
            if value > 0
              value = "+" + value.to_s
            end
          if value != 0
            draw_list[draw_counter] = draw_str + value.to_s + "% "
            draw_counter += 1
          end
        end
      end       
          
  #特殊能力値判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 23
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          #ステータス名取得
          case drow
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
          value = (keep[drow] * 100).to_i - 100
            if value > 0
              value = "+" + value.to_s
            end
          if value != 0
            draw_list[draw_counter] = draw_str + value.to_s + "% "
            draw_counter += 1
          end
        end
      end   

  #攻撃時ステート判定がある場合
      keep = [] 
      for l in 0..features_max
        if item.features[l].code == 32
          keep[item.features[l].data_id] = 1 unless keep[item.features[l].data_id]
          keep[item.features[l].data_id] *= item.features[l].value
        end
      end
         
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str = $data_states[drow].name + "追加"
          value = (keep[drow] * 100).to_i
          if value != 0
            draw_list[draw_counter] = draw_str + value.to_s + "% "
            draw_counter += 1
          end
        end
      end
      
  #攻撃追加がある場合
      keep = 1
      for l in 0..features_max
        if item.features[l].code == 34
          keep += (item.features[l].value).to_i
        end
      end
        
      if keep != 1
        draw_list[draw_counter] = keep.to_s + "回攻撃 "
        draw_counter += 1
      end
      
  #スキルタイプ追加がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 41
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_system.skill_types[keep[drow]]
          draw_list[draw_counter] = draw_str + "使用可"
          draw_counter += 1
        end
      end
      
  #スキルタイプ削除がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 42
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_system.skill_types[keep[drow]]
          draw_list[draw_counter] = draw_str + "使用不可"
          draw_counter += 1
        end
      end
        
  #スキル追加がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 43
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_skills[keep[drow]].name
          draw_list[draw_counter] = draw_str + "使用可"
          draw_counter += 1
        end
      end
      
  #スキル削除がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 44
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        if keep[drow]
          draw_str  = $data_skills[keep[drow]].name
          draw_list[draw_counter] = draw_str + "使用不可"
          draw_counter += 1
        end
      end  
           
  #行動追加がある場合
      for l in 0..features_max
        if item.features[l].code == 61
          #項目を取得
          value = (item.features[l].value * 100).to_i
          draw_list[draw_counter] = "追加行動"+ value.to_s + "% "
          draw_counter += 1
        end
      end
      
  #特殊フラグがある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 62
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        case keep[drow]
        when 0
          value = "自動戦闘"
        when 1
          value = "自動防御"
        when 2
          value = "自動献身"
        when 3
          value = "TP持越"
        end
          draw_list[draw_counter] = value
          draw_counter += 1
      end
          
    #パーティー能力がある場合
      keep = []
      for l in 0..features_max
        if item.features[l].code == 64
          keep.push(item.features[l].data_id)
        end
      end
      keep.uniq!
      
      for drow in 0..keep.size - 1
        case keep[drow]
        when 0
          value = "敵出現率↓"
        when 1
          value = "敵出現率0"
        when 2
          value = "被先制無効"
        when 3
          value = "先制率上昇"
        when 4
          value = "獲得金額2倍"              
        when 5
          value = "Drop率2倍" 
        end
          draw_list[draw_counter] = value
          draw_counter += 1
      end
        
      #追加特徴項目
      for add in 0..5
        if item.party_add_ability(add) != 100
          case add
          when 0
            value = "獲得金額" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          when 1
            value = "Drop率" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          when 2
            value = "遭遇率" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          when 3
            value = "獲得EXP" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          when 4
            value = "獲得JEXP" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          when 5
            value = "獲得EEXP" + (item.party_add_ability(add).to_f / 100).to_s + "倍"
          end
          draw_list[draw_counter] = value
          draw_counter += 1
        end
      end  

      #追加特徴項目2
      for add in 0..29
        case add
        when 0
          if item.battler_add_ability(add) != 100
            value = "スティール率" + (item.battler_add_ability(add).to_f / 100).to_s + "倍"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 1
          if item.battler_add_ability(add)[0] != 0
            value = "自動復活"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 2
          if item.battler_add_ability(add) != 0
            value = "踏みとどまり" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 3
          if item.battler_add_ability(add) != 0
            value = "回復反転" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 4
          if item.battler_add_ability(add) != []
            for state in 0..item.battler_add_ability(add).size - 1
              value = $data_states[item.battler_add_ability(add)[state]].name + "発動"
              draw_list[draw_counter] = value
              draw_counter += 1
            end
          end
        when 5
          if item.battler_add_ability(add) != 0
            value = "メタルボディ"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 6
          multi_skill = Array.new
          all_list = item.battler_add_ability(add)
          for list in 0..all_list.size - 1
            if list % 2 == 0
              if all_list[list] && all_list[list + 1]
                multi_skill[all_list[list]] = 0 unless multi_skill[all_list[list]]
                multi_skill[all_list[list]] = [multi_skill[all_list[list]],all_list[list + 1]].max
              end
            end
          end
          
          for skill_type in 1..multi_skill.size - 1
            if multi_skill[skill_type] != 0
              value = $data_system.skill_types[skill_type] + multi_skill[skill_type].to_s + "回発動"
              draw_list[draw_counter] = value
              draw_counter += 1
            end
          end
        when 7
          if item.battler_add_ability(add) != 0
            value = "即死反転"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 8
          if item.battler_add_ability(add) != 0
            value = "仲間想い" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 9
          if item.battler_add_ability(add) != 0
            value = "弱気" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 10
          if item.battler_add_ability(add) != 0
            value = "防御壁" + item.battler_add_ability(add).to_s + "枚展開"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 11
          if item.battler_add_ability(add) != 0
            value = "無効化" + item.battler_add_ability(add).to_s
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 12
          if item.battler_add_ability(add) != 100
            value = "TP消費率" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 13
          if item.battler_add_ability(add) != []
            value = "スキル変化"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 14
          if item.battler_add_ability(add) != []
            value = "スキル強化"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 15
          if item.battler_add_ability(add) != []
            value = "行動変化"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 16
          if item.battler_add_ability(add) != []
            value = "最終反撃能力"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 17
          if item.battler_add_ability(add) != []
            value = "反撃変化"
            draw_list[@draw_counter] = value
            @draw_counter += 1
          end
        when 18
          if item.battler_add_ability(add) != []
            value = "戦闘後回復"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 19
          if item.battler_add_ability(add) != []
            value = "HP消費率変化"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 20
          if item.battler_add_ability(add) != []
            value = "MP消費率変化"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 21
          if item.battler_add_ability(add) != []
            value = "TP消費率変化"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 22
          if item.battler_add_ability(add) != 100
            value = "HP消費率" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 23
          if item.battler_add_ability(add) != 0
            value = "憑依強化" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 24
          if item.battler_add_ability(add) != 0
            value = "反撃強化" + item.battler_add_ability(add).to_s + "%"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 25
          if item.battler_add_ability(add) != []
            value = "逆境時強化"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 26
          if item.battler_add_ability(add) != 0
            value = "衝撃MP変換"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 27
          if item.battler_add_ability(add) != 0
            value = "衝撃G変換"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 28
          if item.battler_add_ability(add) != 0
            value = "必中反撃"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        when 29
          if item.battler_add_ability(add) != 0
            value = "魔法反撃"
            draw_list[draw_counter] = value
            draw_counter += 1
          end
        end
      end 
      
    #追加特徴項目3
    booster = item.multi_booster(0)
    drain = item.multi_booster(1)
    keep = []
    if booster
      for i in 0..booster.size - 1
        if i % 2 == 0
          keep[booster[i]] = 0 unless keep[booster[i]]
          keep[booster[i]] += booster[i + 1]
        end
      end
      
      for drow in 0..keep.size - 1
        if keep[drow]
          value = $data_system.elements[drow] + "追加" + keep[drow].to_s + "%"
          draw_list[draw_counter] = value
          draw_counter += 1
        end
      end
      
    end
    
    keep = []
    if drain
      for i in 0..drain.size - 1
        if i % 2 == 0
          keep[drain[i]] = 0 unless keep[drain[i]]
          keep[drain[i]] += drain[i + 1]
        end
      end
      
      for drow in 0..keep.size - 1
        if keep[drow]
          value = $data_system.elements[drow] + "吸収" + keep[drow].to_s + "%"
          draw_list[draw_counter] = value
          draw_counter += 1
        end
      end
    end    
    
    draw_list.compact!

    #実際の描画処理
    line_cheacker_x = 0
    line_cheacker_y = 0
    for j in 0..draw_list.size - 1
      line_cheacker_y += 1 if line_cheacker_x == 3  
      line_cheacker_x = 0 if line_cheacker_x == 3
      change_color(normal_color)
      draw_text(x + ((contents.width - x)/3) * line_cheacker_x, y + line_height * line_cheacker_y , ((contents.width - x)/3) - 5, line_height, draw_list[j])
      line_cheacker_x += 1
    end
    
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 装備品の特徴(3ページ目、INDEX1)
  #--------------------------------------------------------------------------
  def draw_equipments_slot(x, y)
    return unless @actor.equips[@sub_command_index]
    item = @actor.equips[@sub_command_index]
    
    #スロットリストを取得
    slot_list = item.slot_list
    slot_max_size = item.max_slot_number
    
    #スロットリストを描画
    counter = 0
    for slot in 0..slot_max_size - 1
      draw_text(x + 5, y + line_height * counter, 25, line_height, counter + 1)
      draw_item_name(slot_list[slot], x + 30, y + line_height * counter) if slot_list[slot]
      counter += 1
    end    
    
  end
  #--------------------------------------------------------------------------
  # ★ プロフィール(4ページの描画)
  #--------------------------------------------------------------------------
  def page_4_draw
    
    @draw_index = 0 if @draw_index > 1
    @draw_index = 1 if @draw_index < 0
    @draw_index = 0 if KURE::ExStatus::PROFILE2[@actor.id] == nil
    
    case @draw_index
    when 0
      page_4_1_draw
      draw_text(280, contents.height - line_height, contents.width - 280, line_height, "← →: Страница (1 / 2)",1) if KURE::ExStatus::PROFILE2[@actor.id] != nil
    when 1
      page_4_2_draw
      draw_text(280, contents.height - line_height, contents.width - 280, line_height, "← →: Страница (2 / 2)",1)
    end
  end
  #--------------------------------------------------------------------------
  # ★ プロフィール(4-1ページの描画)
  #--------------------------------------------------------------------------
  def page_4_1_draw  
    draw_gauge(5,0, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, 0, 126, line_height, KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]])
    draw_text(150, 0, contents.width - 280, line_height, @actor.name)
    draw_actor_nickname(@actor, contents.width - 150,0)
    
    #描画内容を変数で判断
    if KURE::ExStatus::PROFILE_NUM[@actor.id - 1] != 0
      draw_profile = $game_variables[KURE::ExStatus::PROFILE_NUM[@actor.id - 1]]
    else
      draw_profile = 0
    end
    
    #立ち絵のあるなしを判断
    draw_standpicture = 0
    
    #立ち絵グラフィックを設定
    if KURE::ExStatus::PROFILE[@actor.id] != nil
      if KURE::ExStatus::PROFILE[@actor.id][draw_profile] != nil
        if KURE::ExStatus::PROFILE[@actor.id][draw_profile].size != 0
          #立ち絵の選択
          if KURE::ExStatus::PROFILE[@actor.id][draw_profile][0] == 1
            lastname = File.extname($game_actors[@actor.id].face_name)
            basename = File.basename($game_actors[@actor.id].face_name, lastname)
            bitmap = Cache.picture(basename + "-" + ($game_actors[@actor.id].face_index + 1).to_s + lastname)
            #描画
            self.contents.blt(0, contents.height - bitmap.rect.height + 24, bitmap, bitmap.rect)
            draw_standpicture = 1
          elsif KURE::ExStatus::PROFILE[@actor.id][draw_profile][0] != 1 && KURE::ExStatus::PROFILE[@actor.id][draw_profile][0] != nil
            bitmap = Cache.picture(KURE::ExStatus::PROFILE[@actor.id][draw_profile][0])
            #描画
            self.contents.blt(0, contents.height - bitmap.rect.height + 24, bitmap, bitmap.rect)
            draw_standpicture = 1
          end
        end
      end
    end
    
    #プロフィールが設定されているかをチェックする
    if KURE::ExStatus::PROFILE[@actor.id] != nil
      #プロフィールが設定されていれば描画する
      if KURE::ExStatus::PROFILE[@actor.id][draw_profile] != nil
        if KURE::ExStatus::PROFILE[@actor.id][draw_profile].size != 0
          #立ち絵の有無で描画位置を調節
          if draw_standpicture == 1
            profile_x = 280
          else
            profile_x = 0
          end
          #プロフィールを描画
          for i in 1..KURE::ExStatus::PROFILE[@actor.id][draw_profile].size - 1
            draw_text_ex(profile_x, line_height * (i +1), KURE::ExStatus::PROFILE[@actor.id][draw_profile][i])
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● プロフィール(4-2ページの描画)
  #--------------------------------------------------------------------------
  def page_4_2_draw
    draw_gauge(5,0, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, 0, 126, line_height, KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]])
    draw_text(150, 0, contents.width - 280, line_height, @actor.name)
    draw_actor_nickname(@actor, contents.width - 150,0)
    
    #描画内容を変数で判断
    if KURE::ExStatus::PROFILE_NUM2[@actor.id - 1] != 0
      draw_profile = $game_variables[KURE::ExStatus::PROFILE_NUM2[@actor.id - 1]]
    else
      draw_profile = 0
    end
    
    #プロフィールが設定されているかをチェックする
    if KURE::ExStatus::PROFILE2[@actor.id] != nil
      #プロフィールが設定されていれば描画する
      if KURE::ExStatus::PROFILE2[@actor.id][draw_profile] != nil
        if KURE::ExStatus::PROFILE2[@actor.id][draw_profile].size != 0
          #プロフィールを描画
          for i in 0..KURE::ExStatus::PROFILE2[@actor.id][draw_profile].size - 1
            draw_text_ex(0, line_height * (i +1), KURE::ExStatus::PROFILE2[@actor.id][draw_profile][i])
          end
        end
      end
    end
    
  end 
  #--------------------------------------------------------------------------
  # ◎ 表示内容の設定(共通呼び出し項目)
  #--------------------------------------------------------------------------
  def draw_value_s(val,baseval)
    str = ""
    plus = ""
    if KURE::ExStatus::VIEW_MODE == 0
      str = val.to_s + "%"
    else
      case baseval
      when 100
        if val - 100 == 0
          str = "-"
        else
          plus = "+" if val - 100 > 0
          str = plus + (val - 100).to_s + "%" 
        end
      when 0
        if val == 0
          str = "-"
        else
          plus = "+" if val > 0
          str = plus + val.to_s + "%" 
        end      
      end
    end
    
    return str
  end
end