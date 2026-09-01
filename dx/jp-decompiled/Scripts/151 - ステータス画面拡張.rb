#===============================================================================
#  ■拡張ステータス画面 for RGSS3 Ver3.01-β5
#　□作成者 kure
#===============================================================================
$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:ExStatus] = 3013
p "拡張ステータス画面"

module KURE
  module ExStatus
  #初期設定
    EX_MAIN_STATUS_MENU = [] ; EX_SUB_STATUS_MENU = [] ; VIEW_SUB_MENU = []
    FREE_SPACE = [] ; PROFILE = [] ; PROFILE2 = [] ; VIEW_Ex1 = [] ; VIEW_Ex2 = []
    
  #描画方法の選択---------------------------------------------------------------
    #各ステータスの表示方法
    #VIEW_MODE(0=値を表示 1=補正値を表示)
    VIEW_MODE = 0
    
  #メニュー選択肢の設定---------------------------------------------------------    
    #メニューの設定
    #EX_MAIN_STATUS_MENU[ID] = ["表示名",サブメニュー使用可非]
    #表示名               … コマンドの表示名を設定します
    #サブメニュー使用可非 … (0=サブメニュー使用せず 1=サブメニュー使用)
    
    EX_MAIN_STATUS_MENU[0] = ["基本情報",1]       #(ID0)基本情報
    EX_MAIN_STATUS_MENU[1] = ["職業履歴",1]       #(ID1)職業履歴
    EX_MAIN_STATUS_MENU[2] = ["装備情報",1]       #(ID2)装備情報
    EX_MAIN_STATUS_MENU[3] = ["プロフィール",0]   #(ID3)プロフィール
    
    #表示ページのIDリスト(選択肢に表示される項目)
    VIEW_MAIN_MENU = [0,2,3]
    
  #サブメニュー選択肢の設定-----------------------------------------------------
    #初期設定(変更しないこと)
      EX_SUB_STATUS_MENU[0] = []
      
    #基本情報    
      #EX_SUB_STATUS_MENU[0][ID] = 表示名
      EX_SUB_STATUS_MENU[0][0] = "基本能力値"       #(ID0)能力値
      EX_SUB_STATUS_MENU[0][1] = "特殊能力"         #(ID1)特殊能力値
      EX_SUB_STATUS_MENU[0][2] = "パーティー能力"   #(ID2)パーティー能力  
      EX_SUB_STATUS_MENU[0][3] = "属性耐性"         #(ID3)属性耐性
      EX_SUB_STATUS_MENU[0][4] = "ステート耐性"     #(ID4)ステート耐性
      EX_SUB_STATUS_MENU[0][5] = "習得中スキル"     #(ID5)AP制スキル習得画面
      EX_SUB_STATUS_MENU[0][6] = "フリースペース"   #(ID6)フリースペース
      
      #サブメニューのページリスト(選択肢に表示される項目)
      #VIEW_SUB_MENU[ID] = [サブメニューIDリスト]
      VIEW_SUB_MENU[0] = [0,1]
      
    #職業履歴、装備情報のサブメニューは自動的に作成されます。
    
  #1-1ページ(基本能力値)--------------------------------------------------------
    #VIEW_Ex1[ID] = ["表示名",表示切り替え]
    #表示名       … 追加能力値の表示名
    #表示切り替え … (0=表示、1=非表示)
    
    VIEW_Ex1[0] = ["命中率",0]           #(ID0)命中率
    VIEW_Ex1[1] = ["回避率",0]           #(ID1)回避率
    VIEW_Ex1[2] = ["会心率",0]           #(ID2)会心率
    VIEW_Ex1[3] = ["会心回避率",0]       #(ID3)会心回避率
    VIEW_Ex1[4] = ["魔法回避率",0]       #(ID4)魔法回避率
    VIEW_Ex1[5] = ["魔法反射率",0]       #(ID5)魔法反射率
    VIEW_Ex1[6] = ["反撃率",0]           #(ID6)反撃率
    VIEW_Ex1[7] = ["HP再生率",0]         #(ID7)HP再生率
    VIEW_Ex1[8] = ["MP再生率",0]         #(ID8)MP再生率
    VIEW_Ex1[9] = ["TP再生率",0]         #(ID9)TP再生率
  
  #1-2ページ(特殊能力値)--------------------------------------------------------
    #VIEW_Ex2[ID] = ["表示名",表示切り替え]
    #表示名       … 追加能力値の表示名
    #表示切り替え … (0=表示、1=非表示)  
  
    VIEW_Ex2[0] = ["狙われ率",0]            #(ID0)狙われ率
    VIEW_Ex2[1] = ["防御効果率",1]          #(ID1)防御効果率
    VIEW_Ex2[2] = ["回復効果率",0]          #(ID2)回復効果率
    VIEW_Ex2[3] = ["アイテム回復率",0]            #(ID3)薬の知識
    VIEW_Ex2[4] = ["MP消費率",0]            #(ID4)MP消費率
    VIEW_Ex2[5] = ["TPチャージ率",1]        #(ID5)TPチャージ率
    VIEW_Ex2[6] = ["通常ダメージ率",0]      #(ID6)物理ダメージ率
    VIEW_Ex2[7] = ["特殊ダメージ率",0]      #(ID7)魔法ダメージ率
    VIEW_Ex2[8] = ["床ダメージ率",0]        #(ID8)床ダメージ率
    VIEW_Ex2[9] = ["経験獲得率",0]          #(ID9)経験獲得率
    VIEW_Ex2[10] = ["スティール成功率",1]   #※拡張(ID10)スティール成功率
    VIEW_Ex2[11] = ["魔法反撃率",0]         #※拡張(ID11)魔法反撃率

  #1-4ページ(属性耐性)---------------------------------------------------------
    #属性耐性を表示する項目を属性IDで選択します
    VIEW_ELEMENT_REGIST = []
    
    #項目にアイコンを使用するかどうか(0=使用しない 1=使用する)
    ELEMENT_ICON = 1
    
    #アイコンリスト
    ELEMENT_ICON_LIST = []

  #1-5ページ目描画対応、ステート耐性の表示--------------------------------------
    #ステート耐性を表示する項目をステートIDで選択します
    VIEW_STATE_REGIST = []
    
    #項目にアイコンを使用するかどうか(0=使用しない 1=使用する)
    STATE_ICON = 1
    
  #1-7ページ対応、フリースペース--------------------------------------------------
    #FREE_SPACE[アクターID] = [描画内容1行目,…]
    #区切りはダブルクオテーション「"」ではなくシングルクオテーション「'」です
  
    FREE_SPACE[1] = ['','',''] 
    FREE_SPACE[2] = ['','',''] 
    FREE_SPACE[3] = ['','','']
  
  #2ページ目(職業情報)----------------------------------------------------------
    #履歴が存在する職歴のみ表示(0=OFF、1=ON)
    VIEW_ONLY_IS_RECORD = 0
    
  #3ページ目(装備情報)
    #拡張ページの表示設定(装備品個別管理拡張)
    #ID2 … 装備品のスロットアイテム
    #ID3 … 装備品のシンボル
    #VIEW_Ex3 = [表示するページのIDリスト]
    VIEW_Ex3 = []
    
  #4-1ページ目描画対応----------------------------------------------------------
    #PROFILE_NUM = [アクター1の変数,アクター2の変数,…]
    #アクターのプロフィール描画の切り替え用の変数を指定します。
    #項目数はアクター数と同一にすること
    PROFILE_NUM = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
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
                    ['500_ココアプロフィール裸',
                    '',
                    'えっちした回数　　　： \\V[261]',
                    '犯された回数　　　　： \\V[262]',
                    '膣内射精された回数　： \\V[263]',
                    '',
                    '経験人数　　　　　　： \\V[264]',
                    '',
                    '',
                    '心の闇　　　　　　　： \\V[5]',
                    '',
                    '',
                    ''],             
                 ]
                 
    PROFILE[2] = [
                    [nil,
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
                  
    PROFILE[5] = [
                    ['500_ここなプロフィール裸',
                    '',
                    'えっちした回数　　　： \\V[266]',
                    '犯された回数　　　　： \\V[267]',
                    '膣内射精された回数　： \\V[268]',
                    '',
                    '経験人数　　　　　　： \\V[269]',
                    '',
                    '',
                    '心の闇　　　　　　　： \\V[270]',
                    '',
                    '',
                    ''],  
                    ]
                    
                    
    PROFILE[10] = [
                    ['500_いちごプロフィール',
                    '',
                    'えっちした回数　　　： たくさん',
                    '犯された回数　　　　： いっぱい',
                    '膣内射精された回数　： 数え切れない',
                    '',
                    '経験人数　　　　　　： それなり',
                    '',
                    '',
                    '心の闇　　　　　　　： 0',
                    '',
                    '',
                    ''],    
                    ]
                    

                 

                    
                 
                 
  #4-2ページ目描画対応----------------------------------------------------------
    #PROFILE_NUM2 = [アクター1の変数,アクター2の変数,…]
    #アクターのプロフィール描画の切り替え用の変数を指定します。
    #項目数はアクター数と同一にすること
    PROFILE_NUM2 = [0,0,0,0,0,0,0,0,0,0]
    
    #PROFILE2[アクターID] = [
    #      変数未設定又は0 [プロフィール内容1行目,…],
    #              変数１  [プロフィール内容1行目,…],
    #                       …
    #                      ]
    PROFILE2[1] = [
                    [nil,
                    '',
                    ' クルニャー族という(猫耳人獣の中で)エリート種族である。',
                    ' 5年前の災厄により両親を失い、祖母と暮らすが',
                    ' 祖母が寿命で亡くなり天涯孤独となる。',
                    '',
                    ' 基本的に物事を知らない田舎娘。ボーっとしていてマイペースである。',
                    ' 口数も少なく自分からはあまり喋らない。',
                    ' ･･･が喋るのが嫌いな訳でなく必要があれば割と喋る。',
                    ' 知らないだけで頭はわりと良く、洞察力は高い。',
                    ' 問題に対して理性的な思考をし判断する素質は持っている。']                 
                  ]
    PROFILE2[5] = [
                    [nil,
                    '',
                    ' ヤリニャン族という生まれながらに淫らに堕ちやすい種族で',
                    ' その種族がら戦闘にも学問にも大した素質を持たない。',
                    ' ',
                    ' 本人も種族の弱点を自覚しており普段から気をつけている。',
                    ' その為か問題に対して頭を使って解決しようとするが',
                    ' 基本的に馬鹿なので問題解決には至らない。',
                    ' ',
                    ' 現在はクロウに付いて助手のような仕事をしている。',
                    ' ']   
                    ]
    
    PROFILE2[10] = [
                    [nil,
                    ' クロウ達の所属する組織のシスターズの構成員。',
                    ' 自分ではエリートだと言っているがシスターズの中では下っ端である。',
                    ' ',
                    ' 小心者ではあるが、かなりの努力家であり、',
                    ' ヤリニャン族の中では出来る方ではある･･･',
                    ' ･･･がやはり種族がら才能に恵まれておらず',
                    ' レモンなどからは相手にもされていない。',
                    ' ',
                    ' 淫魔の血を引いており',
                    ' かつヤリニャン族と言うこともあって',
                    ' 発情期はそれはもう激しいらしい････。']
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
    if KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_window.index]][1] == 0
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
    KURE::ExStatus::VIEW_MAIN_MENU.each do |id|
      add_command(KURE::ExStatus::EX_MAIN_STATUS_MENU[id][0], :ok)
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
    KURE::ExStatus::VIEW_SUB_MENU[0].each do |com|
      add_command(KURE::ExStatus::EX_SUB_STATUS_MENU[0][com], :ok)
    end
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド２の作成
  #--------------------------------------------------------------------------
  def make_command_list_2
    if $kure_base_script[:JobChange]
      KURE::JobChange::JOB_GRADE_LIST.each do |com|
        add_command(com, :ok)
      end
    else
      add_command("職業履歴", :ok)
    end 
  end
  #--------------------------------------------------------------------------
  # ● サブコマンド３の作成
  #--------------------------------------------------------------------------
  def make_command_list_3
    @actor.equips.each do |com|
      add_command("", :ok) unless com
      add_command(com.name, :ok) if com
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
    draw_text(0, 0, 126, line_height,KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]][0])
    
    case KURE::ExStatus::VIEW_SUB_MENU[0][@sub_command_index]
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
    12.times {|i| draw_actor_param(@actor, 160, line_height * 1, i + 20) }
    
    draw_gauge(160,line_height * 8, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, line_height * 8, 200, line_height, "アクター能力")
    
    draw_actor_self_features(@actor, 160, line_height * 9)
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
      if KURE::ExStatus::VIEW_Ex1[param_id - 9][1] != 0
        @draw_postion_xparam += 1 
      else
        value = (@actor.xparam(param_id - 9) * 100).to_i
        draw_str = draw_value_s(value,0)
        draw_pos_xparam = (param_id - 9) - @draw_postion_xparam
      
        case draw_pos_xparam
        when 0,2,4,6,8
          change_color(system_color)
          draw_text(x, y + line_height * (draw_pos_xparam / 2), 120, line_height, KURE::ExStatus::VIEW_Ex1[param_id - 9][0])
          change_color(normal_color)
          draw_text(x + 120, y + line_height * (draw_pos_xparam / 2), 50, line_height, draw_str, 2)        
        when 1,3,5,7,9
          change_color(system_color)
          draw_text(x + (contents.width - x)/2, y + line_height * ((draw_pos_xparam - 1)/ 2), 120, line_height, KURE::ExStatus::VIEW_Ex1[param_id - 9][0])
          change_color(normal_color)
          draw_text(x + (contents.width - x)/2 + 120, y + line_height * ((draw_pos_xparam - 1)/ 2), 50, line_height, draw_str, 2)
        end
      end
      
    when 20,21,22,23,24,25,26,27,28,29,30,31
      if KURE::ExStatus::VIEW_Ex2[param_id - 20][1] != 0
        @draw_postion_sparam += 1
      else
        case param_id
        when 20,21,22,23,24,25,26,27,28,29
          value = (@actor.sparam(param_id - 20) * 100).to_i
          draw_str = draw_value_s(value,100)
          draw_pos_sparam = (param_id - 20) - @draw_postion_sparam
        when 30
          value = (@actor.battler_add_ability(0) * 100).to_i
          draw_str = draw_value_s(value,100)
          draw_pos_sparam = (param_id - 20) - @draw_postion_sparam
        when 31
          value = (@actor.battler_add_ability(29)*100).to_i
          draw_str = draw_value_s(value,0)
          draw_pos_sparam = (param_id - 20) - @draw_postion_sparam
        end
      
        case draw_pos_sparam
        when 0,2,4,6,8,10
          change_color(system_color)
          draw_text(x, y + line_height * (draw_pos_sparam / 2), 120, line_height, KURE::ExStatus::VIEW_Ex2[param_id - 20][0])
          change_color(normal_color)
          draw_text(x + 120, y + line_height * (draw_pos_sparam / 2), 50, line_height, draw_str, 2)        
        when 1,3,5,7,9,11
          change_color(system_color)
          draw_text(x + (contents.width - x)/2, y + line_height * ((draw_pos_sparam - 1)/ 2), 120, line_height, KURE::ExStatus::VIEW_Ex2[param_id - 20][0])
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
    @actor.all_features.each do |ft|
      #二刀流チェック
      if ft.code == 55
        if draw_counter < 3
          draw_text(x + ((contents.width - x)/3) * draw_counter, y + line_height * 0,(contents.width - 10)/3,line_height,"二刀流")
        else
          draw_text(x + ((contents.width - x)/3) * (draw_counter - 3), y + line_height * 1,(contents.width - 10)/3,line_height,"二刀流")
        end
        draw_counter += 1
      end
      
      #特殊フラグチェック
      if ft.code == 62
        case ft.data_id
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
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →：表示切り替え ( " + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + " )" ,1)
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
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →：表示切り替え ( " + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + " )" ,1)
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
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →：表示切り替え ( " + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + " )" ,1)
  end
  #--------------------------------------------------------------------------
  # ● 個人能力リスト(1-7ページの描画)
  #--------------------------------------------------------------------------
  def page_1_7_draw
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    draw_text(160, 0, 200, line_height, KURE::ExStatus::EX_SUB_STATUS_MENU[1][6])
    
    draw_FREE_SPACE = KURE::ExStatus::FREE_SPACE[@actor.id]
    counter = 1
    
    return unless draw_FREE_SPACE
    return if draw_FREE_SPACE == []
    
    for line in 0..draw_FREE_SPACE.size - 1
      draw_text(160, line_height * counter, contents.width - 160, line_height, draw_FREE_SPACE[line])
      counter += 1
    end
    
  end
  #--------------------------------------------------------------------------
  # ■ 職業履歴(2ページの描画)
  #--------------------------------------------------------------------------
  def page_2_draw  
    draw_gauge(0,0, 155, 1, mp_gauge_color2,crisis_color)
    draw_text(0, 0, 126, line_height,KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]][0])
    
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    if $kure_base_script[:JobLvSystem]
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
      if $kure_base_script[:JobChange]
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
        lv = "Lv"
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
    draw_text(160, contents.height - line_height , contents.width - 160, line_height, "← →：表示切り替え ( " + (@draw_sub_command_index + 1).to_s + " / " + max_page.to_s + " )" ,1)
  end
  #--------------------------------------------------------------------------
  # ▲ 基本情報(3ページの描画)
  #--------------------------------------------------------------------------
  def page_3_draw    
    draw_gauge(0,0, 155, 1, mp_gauge_color2,crisis_color)
    draw_text(0, 0, 126, line_height,KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]][0])
    
    draw_gauge(160,0, contents.width - 160, 1, mp_gauge_color2,crisis_color)
    page_list = [0,1] + KURE::ExStatus::VIEW_Ex3
    max = page_list.size - 1
    
    @draw_sub_command_index = 0 if @draw_sub_command_index > max
    @draw_sub_command_index = max if @draw_sub_command_index < 0
    
    case page_list[@draw_sub_command_index]
    when 0
      draw_text(160, 0, 200, line_height, "装備アイテム詳細")
      draw_equipments_status(160,line_height * 1)
      
      if $kure_base_script[:ExEquip]
        draw_gauge(160,line_height * 6, contents.width - 160, 1, mp_gauge_color2,crisis_color)
        draw_text(160, line_height * 6, 200, line_height, "装備アイテム追加情報")
        draw_equipments_add_status(160,line_height * 7)
      end

    when 1
      draw_text(160, 0, 200, line_height, "装備アイテム特徴")
      draw_equipments_features(160,line_height * 1)
    when 2
      draw_text(160, 0, 200, line_height, "装備アイテムスロット")
      draw_equipments_slot(160,line_height * 1)
    when 3
      draw_text(160, 0, 200, line_height, "装備アイテムシンボル")
      draw_equipments_symbol(160,line_height * 1)
    end
      draw_text(160, contents.height - line_height, contents.width - 160, line_height, "← →：表示切り替え( " + (@draw_sub_command_index + 1).to_s  + " / " + page_list.size.to_s + ")",1)
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
    if $kure_base_script[:SortOut]
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
    return unless @actor.equips[@sub_command_index]
    features_max = @actor.equips[@sub_command_index].features.size - 1
    #アイテムをセット
    item = @actor.equips[@sub_command_index]
    draw_list = call_add_feature_txt(item)

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
  #--------------------------------------------------------------------------
  # ▲ 装備品のスロット(3ページ目、INDEX2)
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
  # ▲ 装備品のシンボル(3ページ目、INDEX3)
  #--------------------------------------------------------------------------
  def draw_equipments_symbol(x, y)
    return unless @actor.equips[@sub_command_index]
    item = @actor.equips[@sub_command_index]
    
    #シンボルリストを取得
    slot_list = item.symbol_list.collect{|obj| obj[0] }
    slot_max_size = item.max_symbol_number
    
    #シンボルリストを描画
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
      draw_text(280, contents.height - line_height, contents.width - 280, line_height, "← →：表示切り替え( 1 / 2 )",1) if KURE::ExStatus::PROFILE2[@actor.id] != nil
    when 1
      page_4_2_draw
      draw_text(280, contents.height - line_height, contents.width - 280, line_height, "← →：表示切り替え( 2 / 2 )",1)
    end
  end
  #--------------------------------------------------------------------------
  # ★ プロフィール(4-1ページの描画)
  #--------------------------------------------------------------------------
  def page_4_1_draw  
    draw_gauge(5,0, contents.width, 1, mp_gauge_color2,crisis_color)
    draw_text(5, 0, 126, line_height, KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]][0])
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
    draw_text(5, 0, 126, line_height, KURE::ExStatus::EX_MAIN_STATUS_MENU[KURE::ExStatus::VIEW_MAIN_MENU[@main_command_index]][0])
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
    if KURE::ExStatus::VIEW_MODE == 0
      str = val.to_s + "%"
    else
      value = val - baseval
      str = "-" if value == 0
      str += "+" if value > 0
      str += value.to_s + "%" 
    end
    
    return str
  end
end