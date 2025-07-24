#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#                   ◆ コモンイベント呼出し ver2.03 ◆ VX Ace ◆
#                                                     by Ｏｚ
#------------------------------------------------------------------------------
# 　スキル発動前にコモンイベントを呼び出します。スキルの詠唱イベントとかに
# 使えると思います。スキルのメモに
# [コモン呼出(call commonでもok) コモンイベントID]
# と記述するとスキル使用前にコモンイベントＩＤを実行します。
# イベントのスクリプトで使用者のユニット、使用者、スキルを取得したい場合は、
# 以下のメソッドをイベントのスクリプトで呼び出すことで取得できます。
# user_unit_in_battle  →  使用者が味方ならtrue、敵ならfalse
# user_in_battle　     →　スキル発動したキャラのＩＤです。
# use_skill_in_battle  →  発動するスキルＩＤです。
# よくわかんない人用にＤＢの変数に入れることもできます。使わない場合 nil に
# にしてください。
# 戦闘中以外に呼び出した場合、０を返します。(使用者のユニットはtrueを返します。)
# 戦闘前、勝利時、敗北時、逃走時にコモンイベントを呼び出せるようにしました。
# ０を指定するとコモンイベントは呼び出ししません。
# Call_Common_Event.phase　で戦闘開始前、勝利時、敗北時、逃走時を取得できます。
#==============================================================================

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

$imported = {} if $imported == nil
$imported["Call_Common_Event"] = true

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ★ 設定項目 Call Common Event ★
#==============================================================================

module Call_Common_Event
  #スキル発動者のユニット用変数(0:敵、1:味方)
  User_Unit_Variable_ID = nil
  #スキル発動者用変数
  User_Variable_ID = nil
  #スキル用変数
  Use_Skill_Variable_ID = nil
  #戦闘前
  Standby_Event_ID = 0
  #戦闘勝利時
  Won_Event_ID = 4
  #戦闘敗北時
  Defeat_Event_ID = 0
  #戦闘逃走時
  Escaped_Event_ID = 0
end

#==============================================================================
# ★ 設定項目 Call Common Event ★
#==============================================================================

module Call_Common_Event_System_Word
  Call_Common_Event = /\[(?:コモン呼出|call\s*common)\s*[=＝]\s*(\d+)\]/i
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ RPG::Item
#==============================================================================

class RPG::UsableItem
  #------------------------------------------------------------------------
  # ○ キャッシュを生成
  #------------------------------------------------------------------------
  def create_call_common_event_cache
    @call_common_event = false
    @call_common_event_id = 0
    self.note.each_line{|line|
      case line
      when Call_Common_Event_System_Word::Call_Common_Event
        @call_common_event = true
        @call_common_event_id = $1.to_i
      end
    }
  end
  #------------------------------------------------------------------------
  # ○ コモン呼出？
  #------------------------------------------------------------------------
  def call_common_event?
    create_call_common_event_cache if @call_common_event.nil?
    return @call_common_event
  end
  #------------------------------------------------------------------------
  # ○ コモン呼出ＩＤ
  #------------------------------------------------------------------------
  def call_common_event_id
    create_call_common_event_cache unless @call_common_event_id
    return @call_common_event_id
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Call Common Event
#==============================================================================

module Call_Common_Event
  #--------------------------------------------------------------------------
  # ● メンバ変数の初期化
  #--------------------------------------------------------------------------
  def self.initialize(proc = nil)
    @user_unit = true
    @user = 0
    @use_skill = 0
    @call_event_proc = proc
    @phase = :standby
    clear_last_battler
  end
  #--------------------------------------------------------------------------
  # ● ユニット
  #--------------------------------------------------------------------------
  def self.user_unit
    initialize if @user_unit.nil?
    return @user_unit
  end
  #--------------------------------------------------------------------------
  # ● 発動者
  #--------------------------------------------------------------------------
  def self.user
    initialize unless @user    
    return @user
  end
  #--------------------------------------------------------------------------
  # ● スキル
  #--------------------------------------------------------------------------
  def self.use_skill
    initialize unless @use_skill
    return @use_skill
  end
  #--------------------------------------------------------------------------
  # ● フェイズ
  #--------------------------------------------------------------------------
  def self.phase
    initialize unless @phase
    return @phase
  end
  #--------------------------------------------------------------------------
  # ● ユニット
  #--------------------------------------------------------------------------
  def self.user_unit=(user_unit)
    @user_unit = user_unit
    self.user_unit_variable = user_unit
  end
  #--------------------------------------------------------------------------
  # ● 発動者
  #--------------------------------------------------------------------------
  def self.user=(user)
    @user = user
    self.user_variable = user
  end
  #--------------------------------------------------------------------------
  # ● スキル
  #--------------------------------------------------------------------------
  def self.use_skill=(skill)
    @use_skill = skill
    self.use_skill_variable = skill
  end
  #--------------------------------------------------------------------------
  # ● ユニット変数
  #--------------------------------------------------------------------------
  def self.user_unit_variable=(value)
    return unless User_Unit_Variable_ID
    $game_variables[User_Unit_Variable_ID] = value ? 1 : 0
  end
  #--------------------------------------------------------------------------
  # ● 発動者変数
  #--------------------------------------------------------------------------
  def self.user_variable=(value)
    return unless User_Variable_ID
    $game_variables[User_Variable_ID] = value
  end
  #--------------------------------------------------------------------------
  # ● 発動スキル変数
  #--------------------------------------------------------------------------
  def self.use_skill_variable=(value)
    return unless Use_Skill_Variable_ID
    $game_variables[Use_Skill_Variable_ID] = value
  end
  #--------------------------------------------------------------------------
  # ● 戦闘開始前
  #--------------------------------------------------------------------------
#~   def self.standby?
#~     @phase == :standby
#~   end
  #--------------------------------------------------------------------------
  # ● 勝利後
  #--------------------------------------------------------------------------
  def self.won?
    @phase == :won
  end
  #--------------------------------------------------------------------------
  # ● 敗北後
  #--------------------------------------------------------------------------
  def self.defeat?
    @phase == :defeat
  end
  #--------------------------------------------------------------------------
  # ● 逃走中
  #--------------------------------------------------------------------------
  def self.escaped?
    @phase == :escaped
  end
  #--------------------------------------------------------------------------
  # ● 開始前
  #--------------------------------------------------------------------------
  def self.call_standby_event
    return unless Standby_Event_ID > 0
    @phase = :standby
    @call_event_proc.call(Standby_Event_ID) if @call_event_proc
  end
  #--------------------------------------------------------------------------
  # ● 勝利時
  #--------------------------------------------------------------------------
  def self.call_won_event
    return unless Won_Event_ID > 0
    @phase = :won
    @call_event_proc.call(Won_Event_ID) if @call_event_proc
  end
  #--------------------------------------------------------------------------
  # ● 敗北時
  #--------------------------------------------------------------------------
  def self.call_defeat_event
    return unless Defeat_Event_ID > 0
    @phase = :defeat
    @call_event_proc.call(Defeat_Event_ID) if @call_event_proc
  end
  #--------------------------------------------------------------------------
  # ● 逃走時
  #--------------------------------------------------------------------------
  def self.call_escaped_event
    return unless Escaped_Event_ID > 0
    @phase = :escaped
    @call_event_proc.call(Escaped_Event_ID) if @call_event_proc
  end
  #--------------------------------------------------------------------------
  # ● 最後の行動者
  #--------------------------------------------------------------------------
  def self.last_battler=(battler)
    @last_battler = battler
  end
  #--------------------------------------------------------------------------
  # ● アクター：ランダム
  #--------------------------------------------------------------------------
  def self.actor_randam
    members = $game_party.alive_members
    actor = members[rand * members.size]
    return actor ? actor.id : 0
  end
  #--------------------------------------------------------------------------
  # ● アクター：最後の行動者
  #--------------------------------------------------------------------------
  def self.last_actor
    return 0 if @last_battler.nil? || @last_battler.enemy?
    return @last_battler.actor.id
  end
  #--------------------------------------------------------------------------
  # ● エネミー：最後の行動者
  #--------------------------------------------------------------------------
  def self.last_enemy
    return 0 if @last_battler.nil? || @last_battler.actor?
    return @last_battler.enemy.id
  end
  #--------------------------------------------------------------------------
  # ● 最後の行動者：クリアー
  #--------------------------------------------------------------------------
  def self.clear_last_battler
    @last_battler = nil
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戦闘の進行を管理するモジュールです。
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # ● 戦闘開始
  #--------------------------------------------------------------------------
#~   alias call_common_event_battle_start battle_start
#~   def battle_start
#~     call_common_event_battle_start
#~     Call_Common_Event.call_standby_event
#~   end
  #--------------------------------------------------------------------------
  # ● 勝利の処理
  #--------------------------------------------------------------------------
  alias call_common_event_process_victory process_victory
  def process_victory
    return if Call_Common_Event.won?
    Call_Common_Event.call_won_event
    call_common_event_process_victory    
  end
  #--------------------------------------------------------------------------
  # ● 中断の処理
  #--------------------------------------------------------------------------
  alias call_common_event_process_abort process_abort
  def process_abort
    return if Call_Common_Event.escaped?
    Call_Common_Event.call_escaped_event
    call_common_event_process_abort
  end
  #--------------------------------------------------------------------------
  # ● 敗北の処理
  #--------------------------------------------------------------------------
  alias call_common_event_process_defeat process_defeat
  def process_defeat
    return if Call_Common_Event.defeat?
    Call_Common_Event.call_defeat_event
    call_common_event_process_defeat
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ☐ Command
#==============================================================================

module Commands
  module_function
  #--------------------------------------------------------------------------
  # ● ユーザのユニット
  #--------------------------------------------------------------------------
  def user_unit_in_battle
    return true unless $game_party.in_battle
    Call_Common_Event.user_unit
  end
  #--------------------------------------------------------------------------
  # ● ユーザ
  #--------------------------------------------------------------------------
  def user_in_battle
    return 0 unless $game_party.in_battle
    Call_Common_Event.user
  end
  #--------------------------------------------------------------------------
  # ● 発動スキル
  #--------------------------------------------------------------------------
  def use_skill_in_battle
    return 0 unless $game_party.in_battle
    Call_Common_Event.use_skill
  end
end

class Game_Interpreter
  include Commands
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias call_common_event_start start
  def start
    Call_Common_Event.initialize(method(:call_common_event))
    call_common_event_start
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動終了時の処理
  #--------------------------------------------------------------------------
  alias call_common_event_process_action_end process_action_end
  def process_action_end
    unless call_common_event_process_action_end
      Call_Common_Event.clear_last_battler
      return false
    else
      return true
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  alias call_common_event_use_item use_item
  def use_item
    item = @subject.current_action.item
    Call_Common_Event.last_battler = @subject
    Call_Common_Event.use_skill = item.id
    Call_Common_Event.user_unit = @subject.actor?
    Call_Common_Event.user = @subject.actor? ? @subject.actor.id : @subject.enemy.id
    call_common_event(item.call_common_event_id) if item.call_common_event?
    call_common_event_use_item
  end
  #--------------------------------------------------------------------------
  # ● 反撃の発動
  #--------------------------------------------------------------------------
  alias call_common_event_invoke_counter_attack invoke_counter_attack
  def invoke_counter_attack(target, item)
    Call_Common_Event.last_battler = target
    invoke_counter_attack(target, item)    
  end
  #--------------------------------------------------------------------------
  # ● コモンイベントの呼び出し
  #--------------------------------------------------------------------------
  def call_common_event(common_event_id)
    $game_temp.reserve_common_event(common_event_id)
    process_event
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★
