#==============================================================================
# ■ RGSS3 スキルポイント振り分けシステム ver 1.02　本体プログラム
#------------------------------------------------------------------------------
# 　配布元:
#     白の魔 http://izumiwhite.web.fc2.com/
#
# 　利用規約:
#     RPGツクールVXの正規の登録者のみご利用になれます。
#     利用報告・著作権表示とかは必要ありません。
#     改造もご自由にどうぞ。
#     何か問題が発生しても責任は持ちません。
#==============================================================================


#--------------------------------------------------------------------------
# ★ 初期設定。
#    親スキルとスキルポイントを振り分けることで修得可能なスキルの設定。
#    他いろいろ。
#
#    親スキル:スキルポイントを振り分けるターゲットのことです。
#             この親スキルにスキルポイントを振り分けることで
#             実際に使用可能なスキルを修得します。
#--------------------------------------------------------------------------
module WD_skillpoint_ini
 #親スキルの設定
 Skilllearn = [] #この行は消さないこと。
 #一列目は親スキルの名前、二列目以降に修得するスキルと必要なスキルポイントを
 #記述します。
 #"9;10"と記述すると9番のスキルを修得するには10ポイントのスキルポイントが
 #必要であることを意味します。
 Skilllearn[1] = ["Сила","353;3","362;5","202;6","363;8","370;12","383;15","376;18","381;25","382;30","389;35","404;45","332;50",]
 Skilllearn[2] = ["Магическая практика","252;4","364;6","255;10","369;12","377;16","387;19","178;20","258;22","390;30","396;35","261;40","211;50","335;60",]
 Skilllearn[3] = ["Фехтование","154;5","365;7","184;9","384;12","371;16","386;19","331;20","160;22","378;25","181;28","391;30","395;35","405;42","205;45","406;48","166;50","223;65",]
 Skilllearn[4] = ["Учёба","285;6","366;9","388;13","372;15","288;16","175;19","379;22","392;30","169;35","398;40","187;45","401;48","172;55","321;68",]
 Skilllearn[5] = ["Медитация","356;5","367;6","208;9","373;11","133;12","385;15","380;18","333;20","271;21","318;22","393;25","291;32","399;40","327;42","402;45","334;55",]
 Skilllearn[6] = ["Отдых","361;4","368;8","374;15","375;20","394;30","397;35","400;40","403;50","407;60",]

 #スキルポイントの振り分け可能最大値
 Max_charge_each = [] #この行は消さないこと。
 Max_charge = 100 #振り分け可能最大値のデフォルト値。
 #振り分け可能最大値をアクターごとに指定。
 #指定しない場合はデフォルト値Max_chargeの値となる。
 Max_charge_each[1] = 250 #1番の親スキルの振り分け可能最大値。
 Max_charge_each[2] = 250
 Max_charge_each[3] = 250
 Max_charge_each[4] = 250
 Max_charge_each[5] = 250
 Max_charge_each[6] = 250
 
 #レベルアップ時に入手するスキルポイントの指定
 Sp_exp_each = [] #この行は消さないこと。
 Sp_exp = 5       #レベルアップ時に入手するスキルポイントのデフォルト値。
 #レベルアップ時に入手するスキルポイントをアクターごとに指定。
 #指定しない場合はデフォルト値Sp_expの値となる。
 Sp_exp_each[12] = 3 #レベルアップ時に1番のアクターが入手するスキルポイント。
 Sp_exp_each[13] = 3
 Sp_exp_each[14] = 3
 
 #各名称の設定
 Sp_name = "Очки умений"   #スキルポイントの名前
 Sp_dimention = " ОУ"           #スキルポイントの単位
 Result_text = "Получены навыки" #スキル修得ウィンドウのテキスト
 Master_sign = "MASTER"       #修得済みのスキルに対する表記
 Master_sign2 = "MASTER"       #コンプリート済みの親スキルに対する表記

 #確認用メッセージ
 Confirm_mess = "Распределить очки умений?"
 Confirm_yes = "　Да"
 Confirm_no  = "　Нет"

 #未修得のスキルの表示設定
 Nolearn_display = false    #未修得のスキル名を表示しない場合はtrue
 Nolearn_text    = "？？？" #代わりに表示するテキスト

 #一ページに表示可能な親スキルの数。
 #この値を小さくすると、スキルポイント振り分けウィンドウが小さくなり、
 #その分、修得可能スキルを表示するウィンドウが大きくなります。
 Skill_row = 5

 
end
#--------------------------------------------------------------------------
# ★ 初期設定おわり
#--------------------------------------------------------------------------


#==============================================================================
# ■ WD_skillpoint
#------------------------------------------------------------------------------
# 　スキルポイトン振り分け用の共通メソッドです。
#==============================================================================

module WD_skillpoint
  #アクターにスキルポイントを加える
  def get_skillpoint(actorid, value)
    check_sp_variables(actorid, nil)
    $game_actors[actorid].sp += value
  end
  #アクターのスキルポイントを減らす
  def lose_skillpoint(actorid, value)
    check_sp_variables(actorid, nil)
    $game_actors[actorid].sp -= value
  end
  #アクターの親スキルを増やす
  def add_skilluseable(actorid, skillid)
    check_sp_variables(actorid, skillid)
    $game_actors[actorid].skill_useable[skillid] = true
  end
  #アクターの親スキルを減らす
  def reduce_skilluseable(actorid, skillid)
    check_sp_variables(actorid, skillid)
    $game_actors[actorid].skill_useable[skillid] = false
  end
  #アクターの親スキルのSPを増やす
  def get_skillcharge(actorid, skillid, value)
    check_sp_variables(actorid, skillid)
    $game_actors[actorid].skill_charge[skillid] += value
  end
  #アクターの親スキルのSPを減らす
  def lose_skillcharge(actorid, skillid, value)
    check_sp_variables(actorid, skillid)
    $game_actors[actorid].skill_charge[skillid] -= value
    $game_actors[actorid].skill_charge[skillid] = 0 if $game_actors[actorid].skill_charge[skillid] < 0
  end
  #アクターの親スキルを判定
  def check_sp_variables(actorid, skillid)
    $game_actors[actorid].sp = 0 if $game_actors[actorid].sp == nil
    $game_actors[actorid].sp_kari = 0 if $game_actors[actorid].sp_kari == nil
    $game_actors[actorid].skill_useable = [] if $game_actors[actorid].skill_useable == nil
    $game_actors[actorid].skill_charge = [] if $game_actors[actorid].skill_charge == nil
    $game_actors[actorid].skill_charge_kari = [] if $game_actors[actorid].skill_charge_kari == nil
    if skillid
      $game_actors[actorid].skill_useable[skillid] = false if $game_actors[actorid].skill_useable[skillid] == nil
      $game_actors[actorid].skill_charge[skillid] = 0 if $game_actors[actorid].skill_charge[skillid] == nil
      $game_actors[actorid].skill_charge_kari[skillid] = 0 if $game_actors[actorid].skill_charge_kari[skillid] == nil
    end
  end
end


class Game_Interpreter
  include WD_skillpoint
end


class Game_Actor < Game_Battler
  include WD_skillpoint
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :sp
  attr_accessor :sp_kari
  attr_accessor :skill_useable
  attr_accessor :skill_charge
  attr_accessor :skill_charge_kari
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias wd_orig_setup010 setup
  def setup(actor_id)
    wd_orig_setup010(actor_id)
    @sp = 0
    @sp_kari = 0
    @skill_useable    = []
    @skill_charge      = []
    @skill_charge_kari = []
  end
  #--------------------------------------------------------------------------
  # ● レベルアップ
  #--------------------------------------------------------------------------
  alias wd_orig_level_up010 level_up
  def level_up
    wd_orig_level_up010
    @getskillpoint = 0
    if WD_skillpoint_ini::Sp_exp_each[@actor_id] == nil
      @getskillpoint += WD_skillpoint_ini::Sp_exp
      get_skillpoint(@actor_id, WD_skillpoint_ini::Sp_exp)
    else
      @getskillpoint += WD_skillpoint_ini::Sp_exp_each[@actor_id]
      get_skillpoint(@actor_id, WD_skillpoint_ini::Sp_exp_each[@actor_id])
    end
  end
  #--------------------------------------------------------------------------
  # ● レベルアップメッセージの表示
  #     new_skills : 新しく習得したスキルの配列
  #--------------------------------------------------------------------------
  alias wd_orig_display_level_up010 display_level_up
  def display_level_up(new_skills)
    wd_orig_display_level_up010(new_skills)
    text = "#{WD_skillpoint_ini::Sp_name}を#{@getskillpoint}#{WD_skillpoint_ini::Sp_dimention}手に入れた！"
    $game_message.texts.push(text)
  end
end


#==============================================================================
# ■ Scene_SkillDevide
#------------------------------------------------------------------------------
# 　SP振り分けの処理を行うクラスです。
#==============================================================================

class Scene_SkillDevide < Scene_ItemBase
  include WD_skillpoint
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_learning_window
    create_actor_window
    create_devide_window
    create_confirm_window
    create_add_window
    @devide_window.update_help2
    @actor_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● パーティから外すアクターを選択するウィンドウの作成
  #--------------------------------------------------------------------------
  def create_learning_window
    @learning_window = Window_SPLearningList.new(@actor)
    @learning_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● パーティから外すアクターを選択するウィンドウの作成
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_SPActorSp.new(@actor)
    @actor_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● パーティに加えるアクターを選択するウィンドウの作成
  #--------------------------------------------------------------------------
  def create_devide_window
    @devide_window = Window_SPDevide.new(@actor)
    @devide_window.viewport = @viewport
    @devide_window.learning_window = @learning_window
    @devide_window.actor_window = @actor_window
    @devide_window.set_handler(:ok, method(:determine_devide))
    @devide_window.set_handler(:cancel, method(:cancel_devide))
    @devide_window.set_handler(:up_sp, method(:up_sp))
    @devide_window.set_handler(:down_sp, method(:down_sp))
    @devide_window.set_handler(:pagedown, method(:next_actor))
    @devide_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● 除籍確認ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_confirm_window
    @confirm_window = Window_ConfirmDevide.new
    @confirm_window.viewport = @viewport
    @confirm_window.set_handler(:ok,     method(:ok_confirm))
    @confirm_window.set_handler(:cancel, method(:cancel_confirm))
    @confirm_window.hide.deactivate
  end
  #--------------------------------------------------------------------------
  # ● 商品追加ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_add_window
    @add_window = Window_SkillAdd.new
    @add_window.viewport = @viewport
    @add_window.set_handler(:ok,     method(:on_add_ok))
    @add_window.hide.deactivate
  end
  #--------------------------------------------------------------------------
  # ● パーティから外すメンバーの選択
  #--------------------------------------------------------------------------
  def determine_devide
    @confirm_window.visible = true
    @confirm_window.select(0)
    @confirm_window.activate
    @devide_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● キャンセル
  #--------------------------------------------------------------------------
  def cancel_devide
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● 振り分け確認時の決定
  #--------------------------------------------------------------------------
  def ok_confirm
    @actor.sp = @actor.sp_kari
    
    @newlearn_list = []
    for i in 0...WD_skillpoint_ini::Skilllearn.size
      if @actor.skill_charge_kari and @actor.skill_charge[i]
      if (@actor.skill_charge_kari[i] - @actor.skill_charge[i]) > 0
        j = -1
        next if WD_skillpoint_ini::Skilllearn[i] == nil
        for skill_id_sp in WD_skillpoint_ini::Skilllearn[i]
          j += 1
          next if j == 0
          skill_id = skill_id_sp.split(/;/)[0].to_i
          skill_sp = skill_id_sp.split(/;/)[1].to_i
          if skill_sp > @actor.skill_charge[i] and
            skill_sp <= @actor.skill_charge_kari[i]
            if (@actor.skill_learn?($data_skills[skill_id])) != true
              @actor.learn_skill(skill_id)
              @newlearn_list.push(skill_id)
            end
          end
        end
      end
      end
      @actor.skill_charge[i] = @actor.skill_charge_kari[i]
    end

    @confirm_window.hide.deactivate
    on_add_ok
  end
  #--------------------------------------------------------------------------
  # ● 振り分け確認時のキャンセル
  #--------------------------------------------------------------------------
  def cancel_confirm
    @confirm_window.visible = false
    @confirm_window.deactivate
    @devide_window.activate    
  end
  #--------------------------------------------------------------------------
  # ● スキル習得ウィンドウのアクティブ化
  #--------------------------------------------------------------------------
  def activate_add_window
    @add_window.item = @newlearn_list.shift
    @add_window.show.active
  end
  #--------------------------------------------------------------------------
  # ● スキル習得ウィンドウ入の処理
  #--------------------------------------------------------------------------
  def on_add_ok
    @add_window.hide.deactivate
    if @newlearn_list.size > 0
      activate_add_window
    else
      @devide_window.activate
      @devide_window.all_refresh
      @devide_window.update_help2
      @actor_window.refresh
    end    
  end
  #--------------------------------------------------------------------------
  # ● SP振り分け(up)
  #--------------------------------------------------------------------------
  def up_sp
    @devide_window.up_sp
  end
  #--------------------------------------------------------------------------
  # ● SP振り分け(down)
  #--------------------------------------------------------------------------
  def down_sp
    @devide_window.down_sp    
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    @learning_window.set_actor(@actor)
    @actor_window.set_actor(@actor)
    @devide_window.set_actor(@actor)
    @devide_window.all_refresh
    @devide_window.update_help2
    @actor_window.refresh
  end
end


#==============================================================================
# ■ Window_SPDevide
#------------------------------------------------------------------------------
# 　SPの振り分けを行なうウィンドウです。
#==============================================================================

class Window_SPDevide < Window_Selectable
  include WD_skillpoint
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor   :learning_window         # 習得スキルリスト表示ウィンドウ
  attr_accessor   :actor_window            # アクター残りSP表示ウィンドウ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(actor)
    height = WD_skillpoint_ini::Skill_row * 24 + 24
    super(0, 480-height, 544, height)
    @actor = actor
    make_item_list
    refresh
    select(0)
    activate
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def set_actor(actor)
    @actor = actor
    all_refresh
    select(0)
    activate
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 0
  end
  #--------------------------------------------------------------------------
  # ● アイテムの取得
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● (一旦振り分けた後の)全リフレッシュ
  #--------------------------------------------------------------------------
  def all_refresh
    make_item_list
    refresh
  end
  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = [] #アクタースキルを順番に格納
    @data2 = [] #スキルIDを順番に格納

    @actor.sp_kari = @actor.sp
        
    for skillid in 0..WD_skillpoint_ini::Skilllearn.size
      if @actor.skill_useable[skillid] == true
        @data.push(WD_skillpoint_ini::Skilllearn[skillid])
        @data2.push(skillid)
        check_sp_variables(@actor.id, skillid)
        @actor.skill_charge_kari[skillid] = @actor.skill_charge[skillid]
      end
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    skillid = @data2[index]
    rect = item_rect(index)
    rect.x += 4
    draw_text(rect, item[0], 0)
    rect.x -= 4
    rect.width -= 108
    draw_text(rect, "#{@actor.skill_charge[skillid]}#{WD_skillpoint_ini::Sp_dimention}", 2)
    if @actor.skill_charge_kari[skillid] != @actor.skill_charge[skillid]
      rect.width += 36
      draw_text(rect, "→", 2)
      rect.width += 56
      draw_text(rect, "#{@actor.skill_charge_kari[skillid ]}#{WD_skillpoint_ini::Sp_dimention}", 2)
    end
    rect.width = 504
    if WD_skillpoint_ini::Max_charge_each[skillid] != nil
      gaugemax = WD_skillpoint_ini::Max_charge_each[skillid]
    else
      gaugemax = WD_skillpoint_ini::Max_charge
    end
    if gaugemax == @actor.skill_charge[skillid]
      draw_text(rect, WD_skillpoint_ini::Master_sign2, 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 習得リストウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    @learning_window.set_skill(item)
  end
  #--------------------------------------------------------------------------
  # ● 習得リストウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help2
    @learning_window.set_skill2(item)
  end
  #--------------------------------------------------------------------------
  # ● SP振り分け(up)
  #--------------------------------------------------------------------------
  def up_sp
    skillid = @data2[index]
    if skillid != nil
      if WD_skillpoint_ini::Max_charge_each[skillid] != nil
        gaugemax = WD_skillpoint_ini::Max_charge_each[skillid]
      else
        gaugemax = WD_skillpoint_ini::Max_charge
      end
      if (@actor.skill_charge_kari[skillid] < gaugemax) and (@actor.sp_kari > 0)
        @actor.skill_charge_kari[skillid] += 1
        @actor.sp_kari -= 1
        Sound.play_cursor
        refresh
        @actor_window.refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● SP振り分け(down)
  #--------------------------------------------------------------------------
  def down_sp
    skillid = @data2[index]
    if skillid != nil
      if (@actor.skill_charge_kari[skillid] - @actor.skill_charge[skillid]) > 0
        @actor.skill_charge_kari[skillid] -= 1
        @actor.sp_kari += 1
        Sound.play_cursor
        refresh
        @actor_window.refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    if @actor.sp_kari - @actor.sp != 0
      Input.update
      deactivate
      Sound.play_ok
      call_ok_handler
    else
#      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    super
    if active
      return up_sp if handle?(:up_sp) && Input.repeat?(:RIGHT)
      return down_sp if handle?(:down_sp) && Input.repeat?(:LEFT)
    end
    update_help
  end
end



#==============================================================================
# ■ Window_SPLearningList
#------------------------------------------------------------------------------
# 　習得可能スキルのリストを表示するウィンドウです。
#==============================================================================

class Window_SPLearningList < Window_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item            # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(actor)
    height = 480 - WD_skillpoint_ini::Skill_row * 24 - 24 - 48 
    super(0, 0, 544, height)
    item = nil
    @actor = actor
    refresh(nil)
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def set_actor(actor)
    item = nil
    @actor = actor
    refresh(nil)
  end
  #--------------------------------------------------------------------------
  # ● スキルの設定
  #--------------------------------------------------------------------------
  def set_skill(item)
    if @item != item
      contents.clear
      refresh(item)
      @item = item
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルの設定
  #--------------------------------------------------------------------------
  def set_skill2(item)
    contents.clear
    refresh(item)
    @item = item
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(item)
    contents.clear
    if item
      linemax = (480 - WD_skillpoint_ini::Skill_row * 24 - 24 - 48 -24)/24
      linemax -= 2
      i = -1
      
        basic_skill_name = item[0]
        self.contents.draw_text(0, 0, 544-24, 24, basic_skill_name, 0)
        for skill_id_sp in item
          i = i + 1
          next if i == 0
          skill_id = skill_id_sp.split(/;/)[0].to_i
          skill_sp = skill_id_sp.split(/;/)[1].to_i
          x = 0                   if i <= linemax
          x = 256                 if i >  linemax
          y = 24*(i+1)           if i <= linemax
          y = 24*(i-linemax+1)   if i >  linemax
          if i <= 2*linemax
            if WD_skillpoint_ini::Nolearn_display == false
              draw_item_name($data_skills[skill_id], x + 2, y, enabled = true)
            else
              if (@actor.skill_learn?($data_skills[skill_id])) != true
                 self.contents.draw_text(x + 36, y, 172, 24, WD_skillpoint_ini::Nolearn_text, 0)
              else
                draw_item_name($data_skills[skill_id], x + 2, y, enabled = true)
              end
            end
          
            if (@actor.skill_learn?($data_skills[skill_id])) != true
              self.contents.draw_text(x, y, 256, 24, "#{skill_sp}#{WD_skillpoint_ini::Sp_dimention}", 2)
            else
              self.contents.draw_text(x, y, 256, 24, WD_skillpoint_ini::Master_sign, 2)
            end
          end
        end

    end
  end
end


#==============================================================================
# ■ Window_SPActorSp
#------------------------------------------------------------------------------
# 　アクターの残りSPを表示するウィンドウです。
#==============================================================================

class Window_SPActorSp < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(actor)
    y = 480 - WD_skillpoint_ini::Skill_row * 24 - 24 - 48 
    super(0, y, 544, 48)
    @actor = actor
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def set_actor(actor)
    @actor = actor
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_name(@actor, 0, 0)
    draw_text(0,0,440,24, "Осталось очков умений:", 2)
    draw_text(0,0,520,24, "#{@actor.sp_kari}#{WD_skillpoint_ini::Sp_dimention}", 2)
  end
end
    
    
#==============================================================================
# ■ Window_ConfirmDevide
#------------------------------------------------------------------------------
# 　SP振り分けの確認用ウィンドウです。
#==============================================================================

class Window_ConfirmDevide < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(62, 180, 424, 96)
    @data = [WD_skillpoint_ini::Confirm_yes,WD_skillpoint_ini::Confirm_no]
    refresh
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
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect_for_text(index)
    draw_text(rect.x, rect.y, contents_width, line_height, @data[index])
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    self.contents.draw_text(0, 0, 400, 24, WD_skillpoint_ini::Confirm_mess, 0)
    
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = contents.width - 4
    rect.height = line_height
    rect.x = 0
    rect.y = line_height * 1 + index * line_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    Input.update
    deactivate
    if index == 0
      Sound.play_ok
      call_ok_handler
    else
      Sound.play_cancel
      call_cancel_handler
    end
  end
end

#==============================================================================
# ■ Window_SkillAdd
#------------------------------------------------------------------------------
# 　習得したスキルを表示するウィンドウです。
#==============================================================================

class Window_SkillAdd < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(160, 200, 224, 72)
    @item = nil
    refresh
    activate
  end
  #--------------------------------------------------------------------------
  # ● 習得スキルの設定
  #--------------------------------------------------------------------------
  def item=(item)
    return if @item == item
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(0, 0, 180, line_height, WD_skillpoint_ini::Result_text)
    if @item
      draw_item_name($data_skills[@item], 0, line_height, true)
    end
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && visible
    return process_ok       if Input.trigger?(:C)
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    Sound.play_ok
    Input.update
    deactivate
    call_ok_handler
  end
end



class Game_Battler < Game_BattlerBase
  include WD_skillpoint
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの適用テスト
  #    使用対象が全快しているときの回復禁止などを判定する。
  #--------------------------------------------------------------------------
  alias wd_orig_item_test010 item_test
  def item_test(user, item)
    return false if item.for_dead_friend? != dead?
    if /<SP増加:(.+)>/ =~ item.note
      return true
    end
    if /<親スキル追加:(.+)>/ =~ item.note
      skillid = $1.to_i
      check_sp_variables(self.id, skillid)
      if $game_actors[self.id].skill_useable[skillid] != true
        return true
      else
        return false
      end
    end    
    return wd_orig_item_test010(user, item)
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果適用
  #--------------------------------------------------------------------------
  alias wd_orig_item_apply010 item_apply
  def item_apply(user, item)
    if /<SP増加:(.+)>/ =~ item.note
      value = $1.to_i
      check_sp_variables(self.id, nil)
      get_skillpoint(self.id, value)
    end
    if /<親スキル追加:(.+)>/ =~ item.note
      skillid = $1.to_i
      check_sp_variables(self.id, skillid)
      if $game_actors[self.id].skill_useable[skillid] != true
        add_skilluseable(self.id, skillid)
      end
    end
    wd_orig_item_apply010(user, item)
  end
end

