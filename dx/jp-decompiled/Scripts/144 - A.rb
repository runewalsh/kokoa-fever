#==============================================================================
#  ■併用化ベーススクリプトＡ for RGSS3 Ver5.05-EX14
#　□作成者 kure
#==============================================================================
$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:base_A] = 503
p "併用化ベーススクリプトA"

#==============================================================================
# ■ Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # ◎ 経験値情報の描画(追加定義)
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    s_next = "Next"
    change_color(system_color)
    draw_text(x + 100, y , 45, line_height, s_next)
    change_color(normal_color)
    draw_text(x + 140, y , 85, line_height, s1, 2)
  end
  #--------------------------------------------------------------------------
  # ☆ TP の描画(再定義)
  #--------------------------------------------------------------------------
  def draw_actor_tp(actor, x, y, width = 124)
    return if actor.max_tp == 0
    draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    change_color(tp_color(actor))
    draw_current_and_max_values(x, y, width, actor.tp.to_i, actor.max_tp.to_i,
    tp_color(actor), normal_color)
  end
end

#==============================================================================
# ■ Window_SkillList(再定義)
#==============================================================================
class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ■ 記憶スキルリストの作成(再定義)
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @actor ? @actor.skills.select {|skill| include?(skill) && view_skill?(skill) } : []
    return @data unless $kure_base_script[:Memorize]
    #メモライズ適用時の処理(戦闘中は常に適用)
    if $game_party.in_battle or KURE::SkillMemorize::ADOPT_MEMORIZE == 0
      @data = @data.select {|skill| @actor.memorize_now?(skill.id)}
    end
    return @data
  end
  #--------------------------------------------------------------------------
  # ■ スキルを表示するかどうか(バトル)
  #--------------------------------------------------------------------------
  def view_skill?(item)
    return false unless item
    return true if item.view_skill_mode == 3
    return true if item.view_skill_mode == 2 && $game_party.in_battle
    return true if item.view_skill_mode == 1 && !$game_party.in_battle
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ フレーム更新(追加定義)
  #--------------------------------------------------------------------------
  def process_cost_refresh
    return if KURE::BaseScript::C_SKILL_COST_DRAW == 0
    @cost_draw_index ||= 0 ; @time_keeper ||= 0
    @time_keeper += 1
    return if @time_keeper < 101
    @cost_draw_index += 1
    @cost_draw_index = 0 if @cost_draw_index > 5
    @time_keeper = 0
    refresh
  end
end

#==============================================================================
# ■ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ☆ 行動結果の表示
  #--------------------------------------------------------------------------
  def display_action_results(target, item)
    if target.result.used
      last_line_number = line_number
      display_critical(target, item)
      display_auto_guard_message(target)
      display_invalidate_message(target)
      display_convert_message(target)
      display_damage(target, item)
      display_break_equip_message(target)
      display_defensewall_message(target)
      display_invalidatewall_message(target)
      display_autostand_message(target)
      display_drain_message(target)
      display_steal(target, item)
      display_reverse_deth(target, item)
      display_affected_status(target, item)
      display_multi_status(target)
      display_failure(target, item)
      wait if line_number > last_line_number
      back_to(last_line_number)
    else
      last_line_number = line_number
      display_no_effect(target, item)
      wait if line_number > last_line_number
      back_to(last_line_number)
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 効果なしの表示(エイリアス再定義)
  #--------------------------------------------------------------------------
  def display_no_effect(target, item)
    return if target.result.invalidate?
    return unless target.alive?
    fmt = Vocab::NOEFFECT
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ オートガードメッセージのの表示(追加定義)
  #--------------------------------------------------------------------------
  def display_auto_guard_message(target)
    return unless target.result.auto_guard
    fmt = Vocab::AUTO_GUARD
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 失敗の表示(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_display_failure display_failure
  def display_failure(target, item)
    return if target.result.invalidate?
    k_before_display_failure(target, item)
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージの表示(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_display_damage display_damage
  def display_damage(target, item)
    return if target.result.invalidate?
    k_before_display_damage(target, item)
  end
  #--------------------------------------------------------------------------
  # ☆ スティールの表示
  #--------------------------------------------------------------------------
  def display_steal(target, item)
    return unless target.enemy?
    return unless target.result.use_steal
        
    if target.result.stealed
      fmt = Vocab::EnemyStealed
      add_text(sprintf(fmt, target.name))
    elsif target.result.steal
      if KURE::BaseScript::C_STEAL_ITEM_SE_PLAY == 1
        sound = KURE::BaseScript::C_STEAL_ITEM_SE
        Audio.se_play('Audio/SE/' + sound[0], sound[1], sound[2])
      end
          
      fmt = Vocab::EnemySteal
      icon = ''
      icon = '\I[' + target.result.steal.icon_index.to_s + ']' if KURE::BaseScript::C_DRAW_STEAL_ITEM_ICON == 1
      color = '\C[' + KURE::BaseScript::C_DRAW_STEAL_ITEM_COLOR.to_s + ']'
          
      add_text(sprintf(fmt, target.name, icon + color + target.result.steal.name + '\C[0]'))
    else
      fmt = Vocab::EnemyNOSteal
      add_text(sprintf(fmt, target.name))
    end
    target.result.success = true
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 自爆スキルのメッセージの表示
  #--------------------------------------------------------------------------
  def display_paylife_message(user, item)
    if item.is_a?(RPG::Skill) && item.life_cost
      fmt = user.battler_add_ability(34) ? Vocab::Stand : Vocab::PayLife
      add_text(sprintf(fmt, user.name))
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ☆ オートリザレクションのメッセージの表示
  #--------------------------------------------------------------------------
  def display_autorevive_message(battler)
    fmt = Vocab::Revive
    add_text(sprintf(fmt, battler.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ ロストスキルのメッセージの表示
  #--------------------------------------------------------------------------
  def display_lostskill_message(battler, skill)
    fmt = Vocab::LostSkill
    add_text(sprintf(fmt, battler.name, skill.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 踏みとどまりのメッセージの表示
  #--------------------------------------------------------------------------
  def display_autostand_message(battler)
    return unless battler.result.auto_stand
    return if battler.result.missed
    return if battler.result.evaded
    return if battler.result.hp_damage == 0
    fmt = Vocab::Stand
    add_text(sprintf(fmt, battler.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 変換のメッセージの表示
  #--------------------------------------------------------------------------
  def display_convert_message(battler)
    #ゴールド変換
    if battler.result.gold_convert
      fmt = Vocab::GOLDCONVERT
      add_text(sprintf(fmt, battler.name))
      wait
    end
    
    #ＭＰ変換
    if battler.result.mp_convert
      fmt = Vocab::MPCONVERT
      add_text(sprintf(fmt, battler.name))
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 変換のメッセージの表示
  #--------------------------------------------------------------------------
  def display_drain_message(battler)
    #ゴールド回収
    if battler.result.gold_convert_drain
      fmt = Vocab::GOLDDRAIN
      add_text(sprintf(fmt, battler.name,battler.result.gold_convert_drain))
      wait
    end
    
    #ＭＰ回収
    if battler.result.mp_convert_drain
      fmt = Vocab::MPDRAIN
      add_text(sprintf(fmt, battler.name,battler.result.mp_convert_drain))
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 即死反転のメッセージの表示
  #--------------------------------------------------------------------------
  def display_reverse_deth(target, item)
    return unless target.result.reverse_deth
    fmt = Vocab::Reverse_deth
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 防御壁展開のメッセージの表示
  #--------------------------------------------------------------------------
  def display_defensewall_message(target)
    return unless target.result.defense
    fmt = Vocab::Defense
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 無効化のメッセージの表示
  #--------------------------------------------------------------------------
  def display_invalidate_message(target)
    fmt = Vocab::CERTAIN_B if target.result.certain_invalidate
    fmt = Vocab::PHYSICAL_B if target.result.physical_invalidate
    fmt = Vocab::MAGICAL_B if target.result.magical_invalidate
    return unless fmt
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 無効化障壁のメッセージの表示
  #--------------------------------------------------------------------------
  def display_invalidatewall_message(target)
    return unless target.result.invalidate
    fmt = Vocab::Invalidate
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 装備破損のメッセージの表示(攻撃時)
  #--------------------------------------------------------------------------
  def display_breakequip_message(battler, item_name)
    fmt = Vocab::BreakEquip
    add_text(sprintf(fmt, battler.name, item_name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 装備破損のメッセージの表示(被攻撃時)
  #--------------------------------------------------------------------------
  def display_break_equip_message(battler)
    return if battler.result.broken == []
    fmt = Vocab::BreakEquip
    battler.result.broken.each{|item| add_text(sprintf(fmt, battler.name, item))}
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 最終攻撃のメッセージの表示
  #--------------------------------------------------------------------------
  def display_final_counter(target, item)
    clear
    add_text(sprintf(Vocab::FinalCounterAttack, target.name, item.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 追撃のメッセージの表示
  #--------------------------------------------------------------------------
  def display_chase_attack(attcker, item)
    clear
    add_text(sprintf(Vocab::ChaseAttack, attcker.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 最終攻撃のメッセージの表示(追加定義)
  #--------------------------------------------------------------------------
  def display_final_end(user)
    state = $data_states[user.death_state_id]
    state_msg = user.actor? ? state.message1 : state.message2
    add_text(user.name + state_msg)
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 重複ステートのメッセージの表示
  #--------------------------------------------------------------------------
  def display_multi_status(target)
    return unless target.result.multi_state
    fmt = Vocab::MultiState
    add_text(sprintf(fmt, target.name, $data_states[target.result.multi_state].name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 特殊付与ステート付加の表示
  #--------------------------------------------------------------------------
  def display_sp_added_states(target)
    target.result.sp_added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id
      next if state_msg.empty?
      add_text(target.name + state_msg)
      wait
      wait_for_effect
    end
    wait_and_clear
  end
  #--------------------------------------------------------------------------
  # ☆ 反撃無効化のメッセージの表示
  #--------------------------------------------------------------------------
  def display_counter_break(target, item)
    fmt = Vocab::CounterBreak
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ トラップ発動のメッセージの表示
  #--------------------------------------------------------------------------
  def display_trap(target, item)
    fmt = Vocab::TrapInvoke
    add_text(sprintf(fmt, item.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ☆ 連携発動のメッセージの表示
  #--------------------------------------------------------------------------
  def display_use_team_skill(subject, team, item)
    fmt = Vocab::TeamSkill
    add_text(sprintf(fmt, subject.name, team[0].name) + item.message1)
    unless item.message2.empty?
      wait
      add_text(item.message2)
    end
  end
end

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ☆ ステート割合ブースターの取得(追加定義)
  #--------------------------------------------------------------------------
  def state_per_booster(user, item, state_id)
    return 1 unless item.is_a?(RPG::Skill)
    boost = 100
    boost += user.multi_boost(6)[item.stype_id] if user.multi_boost(6)[item.stype_id]
    boost += user.multi_boost(8)[state_id] if user.multi_boost(8)[state_id]
    return boost.to_f / 100
  end
  #--------------------------------------------------------------------------
  # ☆ ステート固定ブースターの取得(追加定義)
  #--------------------------------------------------------------------------
  def state_val_booster(user, item, state_id)
    return 0 unless item.is_a?(RPG::Skill)
    boost = 0
    boost += user.multi_boost(7)[item.stype_id] if user.multi_boost(7)[item.stype_id]
    boost += user.multi_boost(9)[state_id] if user.multi_boost(9)[state_id]
    return boost.to_f / 100
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  attr_accessor :actor_add_counter    #発動カウンター
  attr_accessor :actor_add_delay      #発動ディレイ
  attr_accessor :trap_list            #トラップリスト
  #--------------------------------------------------------------------------
  # ☆ 追加定数（使用効果）
  #--------------------------------------------------------------------------
  EFFECT_STEAL            = 45                 #盗むスキル
  EFFECT_SKILL_RESET      = 46                 #スキルポイントリセット
  EFFECT_BREAK_EQUIP      = 47                 #装備破壊
  EFFECT_GET_ITEM         = 48                 #アイテム獲得
  EFFECT_CLEAR_STATE      = 49                 #ステート初期化
  EFFECT_RAND_ITEM        = 50                 #ランダムアイテム入手
  EFFECT_TRAP             = 51                 #トラップ設置
  #--------------------------------------------------------------------------
  # ☆ チェック配列の初期化(追加定義)
  #--------------------------------------------------------------------------
  def clear_cheackers  
    @actor_add_counter = [] #カウント変数の初期化
    @actor_add_delay = [] #ディレイ変数の初期化
    
    @battle_add_status = [] #戦闘中追加ステータス割合配列
    @substitute_list = [] #身代わり対象リスト
    @trap_list = [] #トラップリスト
  end
  #--------------------------------------------------------------------------
  # ☆ マルチ反撃率計算(追加定義)
  #--------------------------------------------------------------------------
  def multi_cnt_rate(user, hit_type, turn)
    return 0 unless opposite?(user)# 味方には反撃しない
    return 0 unless movable? #行動不可時は反撃でない
    mode = KURE::BaseScript::COUNTER_MODE + turn
    
    #反撃モードにより判定を変更
    case mode
    #攻撃前 or 攻撃
    when 1,3
      case hit_type
      when 0
        return battler_add_ability(28)
      when 1
        return cnt
      when 2
        return battler_add_ability(29)
      end 
    when 2
      case hit_type
      when 0
        return battler_add_ability(42)
      when 1
        return battler_add_ability(40)
      when 2
        return battler_add_ability(41)
      end 
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 回避反撃率計算(追加定義)
  #--------------------------------------------------------------------------
  def eva_cnt_rate(user, hit_type, mode)
    return 0 unless opposite?(user)# 味方には反撃しない
    return 0 unless movable? #行動不可時は反撃でない
    return battler_add_ability(56)
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの消費 HP 計算(追加定義)
  #--------------------------------------------------------------------------
  def skill_hp_cost(skill)
    return 0
  end
  #--------------------------------------------------------------------------
  # ☆ HPタイプ消費率(追加定義)
  #--------------------------------------------------------------------------
  def thpr(skill)
    read = battler_add_ability(19)[skill.stype_id]
    return 1 unless read
    return read
  end
  #--------------------------------------------------------------------------
  # ☆ MPタイプ消費率(追加定義)
  #--------------------------------------------------------------------------
  def tmcr(skill)
    read = battler_add_ability(20)[skill.stype_id]
    return 1 unless read
    return read
  end
  #--------------------------------------------------------------------------
  # ☆ TPタイプ消費率(追加定義)
  #--------------------------------------------------------------------------
  def ttpr(skill)
    read = battler_add_ability(21)[skill.stype_id]
    return 1 unless read
    return read
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘後自動回復(追加定義)
  #--------------------------------------------------------------------------
  def auto_heeling
    #戦闘後自動回復
    heel = battler_add_ability(18)
    self.hp += (self.mhp * heel[0].to_f / 100).to_i if self.hp > 0
    self.mp += (self.mmp * heel[1].to_f / 100).to_i
    
    #戦闘後全体自動回復
    heel_party = battler_add_ability(49)
    $game_party.battle_members.each do |actor|
      actor.hp += (actor.mhp * heel_party[0].to_f / 100).to_i if actor.hp > 0
      actor.mp += (actor.mmp * heel_party[1].to_f / 100).to_i
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘中追加ステータス処理(追加定義)
  #--------------------------------------------------------------------------
  def set_b_add_status
    return unless $game_party.in_battle
    #HPトリガーブロック
    read_1 = battler_add_ability(23)
    read_2 = battler_add_ability(25)
    @battle_add_status ||= []
    
    #戦闘中ステータスを強化する。
    for param in 2..7
      @battle_add_status[param] ||= 0
      #オーバーソウル適用
      @battle_add_status[param] = read_1 * $game_party.dead_members.size
      
      #ピンチ強化適用
      if read_2[0] > (self.hp * 100 / self.mhp)
        @battle_add_status[param] += read_2[1].to_f / 100
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘中追加ステート処理(追加定義)
  #--------------------------------------------------------------------------
  def set_b_add_state
    return unless SceneManager.scene_is?(Scene_Battle)
    #ステート発動
    read_3 = battler_add_ability(33)
    read_3.each do |data|
      if data && data[0] && data[1] && data[2] && data[3]
        #付与、解除の条件分岐
        case data[3]
        when 0,1
          next if state?(data[1])  
        when 2,3
          next unless state?(data[1])
        end
        
        #検索するステータスを絞り込む
        case data[0]
        when 1
          rate = (self.hp.to_f / mhp) * 100
        when 2
          rate = (self.mp / self.mmp) * 100
        when 3
          rate = (self.tp / self.max_tp) * 100
        end
        
        #トリガーによって処理を分岐
        case data[3]
        when 0
          add_state(data[1]) if data[2] > rate
        when 1
          add_state(data[1]) if data[2] <= rate
        when 2
          remove_state(data[1]) if data[2] > rate
        when 3
          remove_state(data[1]) if data[2] <= rate
        end
        
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ バトラー能力の上限回数の取得(追加定義)
  #--------------------------------------------------------------------------
  def add_cheacker
    @actor_add_counter = [] #カウント変数の初期化
    @actor_add_delay = [] #ディレイ変数の初期化
    @trap_list = [] #トラップリストの初期化
    
    ability_1 = battler_add_ability(1).clone
    
    for ability in 0..32
      case ability
      when 1
        @actor_add_counter[ability] = ability_1[2]
        @actor_add_delay[ability] = ability_1[3]
      when 2,3,4,5,6,7,8,9
        @actor_add_counter[ability] = 0
        @actor_add_delay[ability] = 0 
      when 10
        @actor_add_counter[ability] = battler_add_ability(10)
      when 32
        @actor_add_delay[ability] = battler_add_ability(32)
      end
    end
    
  end
  #--------------------------------------------------------------------------
  # ☆ トラップの消滅処理(追加定義)
  #--------------------------------------------------------------------------
  def trap_cutter
    @trap_list.size.times {|i|
      @trap_list[i][3] -= 1
      @trap_list[i] = nil if @trap_list[i][2] <= 0 or @trap_list[i][3] <= 0
    }
    @trap_list.compact!
  end
  #--------------------------------------------------------------------------
  # ☆ 発動ディレイの減少(追加定義)
  #--------------------------------------------------------------------------
  def delay_cutter
  end
  #--------------------------------------------------------------------------
  # ☆ バトラースキルディレイの追加(追加定義)
  #--------------------------------------------------------------------------
  def add_skill_delay(skill, random, change)
  end
  #--------------------------------------------------------------------------
  # ☆ スキルディレイの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def skill_delay
    return @skill_delay
  end
  #--------------------------------------------------------------------------
  # ☆ アクター能力発動ディレイの減少(追加定義)
  #--------------------------------------------------------------------------
  def actor_ability_delay_cutter
    delay_list = [1,32]
    
    delay_list.each do |id|
      @actor_add_delay[id] ||= 0
      case id
      #オートリザレクション
      when 1
        next if self.hp != 0
        @actor_add_delay[id] = [@actor_add_delay[id] - 1, 0].max
      #ディレイステート
      when 32
        next if @actor_add_delay[id] == 0
        @actor_add_delay[id].each do |state_list|
          next unless state_list
          state_list[0] -= 1
          if state_list[0] < 0
            add_state(state_list[1])
            state_list = nil
          end
        end
        @actor_add_delay[id].compact!
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ ステートのカウント（ターン数および歩数）を追加(追加定義)
  #--------------------------------------------------------------------------
  def add_state_counts(state_id)
    state = $data_states[state_id]
    variance = 1 + [state.max_turns - state.min_turns, 0].max
    @state_turns[state_id] ||= 0
    @state_steps[state_id] ||= 0
    @state_turns[state_id] += state.min_turns + rand(variance)
    @state_steps[state_id] += state.steps_to_remove
  end
  #--------------------------------------------------------------------------
  # ☆ ステート解除プロセス(追加定義)
  #--------------------------------------------------------------------------
  def remove_state_process(state_id)
    return unless state?(state_id)
      
    #カウンターとディレイの処理
    if @actor_add_counter && @actor_add_delay
      for ability in 0..32
        @actor_add_counter[ability] ||= 0
        @actor_add_delay[ability] ||= 0
        case ability
        when 1
          @actor_add_counter[ability] -= $data_states[state_id].battler_add_ability(1)[2]
          @actor_add_counter[ability] = 0 if @actor_add_counter[ability] < 0
          @actor_add_delay[ability] = self.battler_add_ability(1)[3]
        when 10
          @actor_add_counter[ability] -= $data_states[state_id].battler_add_ability(10)
          @actor_add_counter[ability] = 0 if @actor_add_counter[ability] < 0
        when 32
          next if @actor_add_delay[ability] == 0
          remove = $data_states[state_id].battler_add_ability(32)
          remove.each do |data|
            @actor_add_delay[ability].delete_if{|obj| obj[1] == data[1]}
          end
        end
      end
    end 
      
    #身代わり対象の処理
    @substitute_list ||= []
    @substitute_list.each_with_index {|battler, index|
      @substitute_list[index] = nil if battler[0] == state_id
    }
    @substitute_list.compact!
  end
  #--------------------------------------------------------------------------
  # ☆ オートステート発動(追加定義)
  #--------------------------------------------------------------------------
  def auto_state_adder
    self.need_passive_refresh = false if actor?
    auto_list = battler_add_ability(4)
    return if auto_list == []
    
    auto_list.each do |state|
      erase_state(state)
      add_new_state(state)
      reset_state_counts(state)
    end
    
    self.need_passive_refresh = true if actor?
  end
  #--------------------------------------------------------------------------
  # ☆ 常時オートステート発動(追加定義)
  #--------------------------------------------------------------------------
  def auto_state_adder_ex(item = nil)
    return if KURE::BaseScript::C_AUTO_STATE_ADDER == 0
    self.need_passive_refresh = false if actor?
    @auto_state ||= []
    if item
      remove = item.battler_add_ability(43)
      remove.each{|state| erase_state(state) if state != 0 }
    else
      @auto_state.each{|state| erase_state(state) if state != 0 }
    end
    @auto_state = battler_add_ability(43)
    @auto_state.each do |state|
      next unless state
      next if state?(state)
      add_new_state(state)
      reset_state_counts(state)
    end
    
    self.need_passive_refresh = true if actor?
  end
  #--------------------------------------------------------------------------
  # ☆ ステート重複許容(追加定義)
  #--------------------------------------------------------------------------
  def state_multi_addable?(id)
    return true unless $data_states[id].multi_addable
    case $data_states[id].multi_addable[0]
    when 0
      cheak_member = $game_party.members
    when 1
      return true unless $game_party.in_battle
      cheak_member = $game_troop.members
    when 2
      cheak_member = $game_party.members
      cheak_member += $game_troop.members if $game_party.in_battle
    end
    num = 0
    cheak_member.each{|battler| num += 1 if battler.state?(id)}
    return true if $data_states[id].multi_addable[1] > num
    @result.multi_state = id
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［アイテムスティール(追加定義)
  #--------------------------------------------------------------------------
  def item_effect_steal(user, item, effect)
    return unless user.actor?
    return unless enemy?
    @result.use_steal = true

    #スティールされたあとか判定
    if self.stealed?
      @result.stealed = true
      return
    end
    
    #スティールされた後でなければリストを読み込み
    steal_list = self.steal_list[effect.data_id]
    if !steal_list or steal_list == []
      @result.stealed = true
      return
    end
        
    #盗めるアイテムのリストがあれば処理
    steal_list.each do |list|
      next unless list
      #成功判定
      dice = rand(1000)
      per = (list[2] * user.battler_add_ability(0)).to_i
              
      if dice < per
        case list[0]
        when 1
          item = $data_items[list[1]]
        when 2
          item = $data_weapons[list[1]]
        when 3
          item = $data_armors[list[1]]
        end
        $game_party.gain_item(item, 1)
        self.steal = true
        @result.steal = item
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［スキルポイントリセット](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_reset_skillpoint(user, item, effect)
    return if !$kure_base_script[:SkillPoint] && !$kure_base_script[:SkillPoint2]
    self.reset_skill_flag = true if actor?
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［装備破壊](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_break_equip(user, item, effect)
    return unless actor?
    return unless $kure_base_script[:SortOut]
    return if item.durable_damage == []
    return unless (item.is_a?(RPG::Skill) or item.is_a?(RPG::Item))

    #耐久値ダメージ
    item.durable_damage.each do |damage_list|
      #耐久値を操作する装備配列を作成
      if damage_list[0] == 0
        select_list = weapons
      else
        select_list = armors.select{|obj| obj && obj.etype_id == damage_list[0]}
      end
      
      #耐久値操作
      select_list.each do |item|
        next if damage_list[2] < rand(100)
        next if item.broken?
        before_name = item.name
                  
        if damage_list[1] > 0
          item.reduce_durable_value = (damage_list[1] * battler_add_ability(31)).to_i
        else
          item.reduce_durable_value =  damage_list[1]
        end
        
        next unless item.broken?
        @result.broken.push(before_name)
                    
        #破損時の処理
        for slot in 0..@equips.size - 1
          next unless @equips[slot].object
          next unless @equips[slot].object == item
          #破損時消滅設定
          if KURE::SortOut::BROKEN_SETTING == 1
            master_container = $game_party.item_master_container(item.class)
            delete_item_id = item.identify_id
            @equips[slot].object = nil 
            master_container[delete_item_id] = nil
          end
          #破損時装備不可設定
          change_equip(slot, nil) if KURE::SortOut::BROKEN_CAN_EQUIP == 1
          refresh
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［アイテム獲得](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_get_item(user, effect)
    return unless user.actor?
    effect.value1.each do |data|
      next unless data
      $game_party.gain_item($data_items[data[0]],data[1])
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［ステート初期化](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_clear_state(user, item, effect)
    #確率判定
    return if rand(100) > effect.data_id
    
    #消去及び対象外のグループリストを取得
    delete = item.clear_state_type
    keep = item.not_clear_state_type
    
    #ステートを順に初期化する(後の追加処理の為順次処理)
    states.each do |state|
      flag1 = 0 ; flag2 = 1
      
      #消去対象(消去対象に入っていればフラグON)
      state.state_type.each{|id| flag1 = 1 if delete.include?(id)}
      flag1 = 1 if delete == []
      
      #消去対象外(消去対象外に入っていればフラグOFF)
      state.state_type.each{|id| flag2 = 0 if keep.include?(id)}
      remove_state(state.id) if flag1 == 1 && flag2 == 1
    end
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［トラップ設置](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_trap(user, item, effect)
    @result.success = true
    
    trap_data = @trap_list.find{|obj| obj[0] == user && obj[1] == item.id}
    unless trap_data
      @trap_list.push([user] + item.trap_setting)
      return
    end
    
    trap_data[2] += item.trap_setting[1]
    trap_data[3] += item.trap_setting[2]
  end
  #--------------------------------------------------------------------------
  # ☆ 踏みとどまりの判定(追加定義)
  #--------------------------------------------------------------------------
  def auto_stand
    read = battler_add_ability(2)
    return false if read[0] > 100
    return false if rand(100) + 1 > read[1]
    return true if self.hp >= ((mhp * read[0]) / 100).to_i
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 回復反転の判定(追加定義)
  #--------------------------------------------------------------------------
  def reverse_heel
    return nil if battler_add_ability(3) == 0
    return battler_add_ability(3)
  end
  #--------------------------------------------------------------------------
  # ☆ メタルボディの判定(追加定義)
  #--------------------------------------------------------------------------
  def metal_body
    return battler_add_ability(5)
  end
  #--------------------------------------------------------------------------
  # ☆ 複数回発動の判定(追加定義)
  #--------------------------------------------------------------------------
  def multi_invoke(item)
    return 1 unless item.is_a?(RPG::Skill)
    data = battler_add_ability(6)[item.stype_id]
    return 1 unless data
    return data
  end
  #--------------------------------------------------------------------------
  # ☆ 即死反転の判定(追加定義)
  #--------------------------------------------------------------------------
  def reverse_deth
    return battler_add_ability(7)
  end
  #--------------------------------------------------------------------------
  # ☆ 防御壁展開の判定(追加定義)
  #--------------------------------------------------------------------------
  def defense_wall
    return false unless @actor_add_counter
    return false unless @actor_add_counter[10]
    return false if @actor_add_counter[10] < 1
    return true
  end
  #--------------------------------------------------------------------------
  # ☆ 無効化障壁の判定(追加定義)
  #--------------------------------------------------------------------------
  def invalidate_wall
    return battler_add_ability(11)
  end
  #--------------------------------------------------------------------------
  # ☆ TP消費率の取得(追加定義)
  #--------------------------------------------------------------------------
  def tpr
    return battler_add_ability(12)
  end
  #--------------------------------------------------------------------------
  # ☆ HP消費率の取得(追加定義)
  #--------------------------------------------------------------------------
  def hpr
    return battler_add_ability(22)
  end
  #--------------------------------------------------------------------------
  # ☆ 最終発動スキルIDの取得(追加定義)
  #--------------------------------------------------------------------------
  def final_invoke
    return battler_add_ability(16).sample
  end
  #--------------------------------------------------------------------------
  # ☆ 追撃発動スキルIDの取得(追加定義)
  #--------------------------------------------------------------------------
  def chace_skill_id
    result = battler_add_ability(58)
    result += [1] if result == []
    return result.sample
  end
  #--------------------------------------------------------------------------
  # ☆ 反撃強化率の判定(追加定義)
  #--------------------------------------------------------------------------
  def counter_gain
    return battler_add_ability(24)
  end
  #--------------------------------------------------------------------------
  # ☆ 属性場展開能力の取得(追加定義)
  #--------------------------------------------------------------------------
  def spread_element
    return battler_add_ability(54)
  end
  #--------------------------------------------------------------------------
  # ☆　自爆スキル(追加定義)
  #--------------------------------------------------------------------------
  def pay_life(item)
    return unless item.is_a?(RPG::Skill)
    return unless item.life_cost
    self.hp = battler_add_ability(34) ? 1 : 0
    perform_collapse_effect if self.hp = 0
  end
  #--------------------------------------------------------------------------
  # ☆ 適用するスキル／アイテムの属性を取得(追加定義)
  #--------------------------------------------------------------------------
  def apply_elements(user, item)
    return user.atk_elements if item.damage.element_id < 0
    
    e_list = item.attack_elements_list
    e_list += user.reflect_elements if user.actor?
    e_list.push(item.damage.element_id)
    e_list.uniq!
    
    return e_list
  end
  #--------------------------------------------------------------------------
  # ☆ 属性ブースターの取得(追加定義)
  #--------------------------------------------------------------------------
  def elements_booster_rate(user, element_id)
    #属性ブースターの配列取得
    result = 1 ; booster = user.multi_boost(0)
    result = (100 + booster[element_id]).to_f / 100 if booster[element_id]
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ 属性吸収の取得(追加定義)
  #--------------------------------------------------------------------------
  def elements_drain_rate(element_id)
    #属性吸収の配列取得
    result = 0 ; drain = multi_boost(1)
    result = drain[element_id].to_f / 100 if drain[element_id]
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ 属性の複数乗算修正値の取得(追加定義)
  #--------------------------------------------------------------------------
  def elements_mix_atk_rate(user, elements)
    elements.inject(1.0) {|r, i| r * element_rate(i) * elements_booster_rate(user, i)}
  end
  #--------------------------------------------------------------------------
  # ☆ 属性の複数加算修正値の取得(追加定義)
  #--------------------------------------------------------------------------
  def elements_mix_drain_rate(user, elements)
    elements.inject(0.0) {|r, i| r + elements_drain_rate(i)}
  end
  #--------------------------------------------------------------------------
  # ☆ 仲間思い修正値の取得(追加定義)
  #--------------------------------------------------------------------------
  def companion_boost(user, item)
    result = 1 ; dead_n = $game_party.dead_members.size
    result *= (1 + (dead_n * (item.companion_revise.to_f / 100)))
    result += dead_n * user.battler_add_ability(8)
    result -= dead_n * user.battler_add_ability(9)
    result = [result, 0].max
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ 装備補正修正値の取得(追加定義)
  #--------------------------------------------------------------------------
  def equip_boost(user, item, skill_type)
    equip_booster = 0
    weapon_id_list = user.weapons.collect{|obj| obj.wtype_id}
    wd_rate_list = item.weapon_d_rate
    wepon_gain_list = user.battler_add_ability(14)
    
    if weapon_id_list != []
      weapon_id_list.each do |boost_id|      
        if item.physical?
          equip_booster += user.multi_boost(2)[boost_id] if user.multi_boost(2)[boost_id]
        elsif item.magical?
          equip_booster += user.multi_boost(3)[boost_id] if user.multi_boost(3)[boost_id]
        else
          equip_booster += user.multi_boost(4)[boost_id] if user.multi_boost(4)[boost_id]
        end
        
        #スキル倍率補正
        equip_booster += wd_rate_list[boost_id] if wd_rate_list[boost_id]
        
        #通常攻撃強化
        equip_booster += user.multi_boost(5)[boost_id] if user.multi_boost(5)[boost_id]
        
        #武器スキル倍率強化
        if item.is_skill? && wepon_gain_list[boost_id]
          equip_booster += wepon_gain_list[boost_id][skill_type] if wepon_gain_list[boost_id][skill_type]
        end
        
      end
    else
      #通常攻撃強化
      equip_booster += user.multi_boost(5)[0] if user.multi_boost(5)[0]
      
      #武器スキル倍率強化
      if item.is_skill? && wepon_gain_list[0]
        equip_booster += wepon_gain_list[0][skill_type] if wepon_gain_list[0][skill_type]
      end
    end
    
    return 1 + (equip_booster.to_f / 100)
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージ増加補正の取得(追加定義)
  #--------------------------------------------------------------------------
  def gain_damage_rate(user, item)
    gain_rate ||= 1 
    skill_type = item.stype_id if item.is_skill?
    
    #仲間思い補正
    gain_rate *= companion_boost(user, item)
    
    #装備補正
    gain_rate *= equip_boost(user, item, skill_type)
    
    #スキルタイプブースター
    skilltype_booster = 0
    if item.is_skill?
      skilltype_booster += user.multi_boost(10)[skill_type] if user.multi_boost(10)[skill_type]
    end
    gain_rate *= 1 + (skilltype_booster.to_f / 100)
    
    return gain_rate
  end
  #--------------------------------------------------------------------------
  # ☆ 関連する全てのメモを取得(追加定義)
  #--------------------------------------------------------------------------  
  def get_all_notes
    all_note = ""
    if actor?
      actor_note = call_job_note_cache
      equip_note = call_equip_note_cache
      passive_note = passive_skills_notes
      all_note += actor_note + equip_note + passive_note
    end
    all_note = $data_enemies[@enemy_id].note if enemy?
    
    all_note += states.collect{|obj| obj.note}.join
    return all_note
  end
  #--------------------------------------------------------------------------
  # ☆ アクター追加能力(追加定義)
  #--------------------------------------------------------------------------  
  def battler_add_ability(id)
    @ability_cache ||= []
    @ability_data_cache ||= []
    
    #ノートのキャッシュが異なればデータを初期化する。
    if @ability_note_cache != get_all_notes
      @ability_cheack_cache = [] 
      @ability_data_cache = []
    end
    return @ability_cache[id] if @ability_cheack_cache[id]
    
    @ability_note_cache = get_all_notes.clone
    @ability_cache[id] = call_add_feature(id, @ability_note_cache)
    @ability_cheack_cache[id] = 1
    
    return @ability_cache[id]
  end
  #--------------------------------------------------------------------------
  # ☆ ブースター配列を取得(追加定義)
  #--------------------------------------------------------------------------
  def multi_boost(id)
    booster = call_multi_booster(id, get_all_notes)
    return arr_id_value_flatten(booster)
  end
  #--------------------------------------------------------------------------
  # ☆ パーティ追加能力判定(追加定義)
  #--------------------------------------------------------------------------
  def party_add_ability(id)
    return call_party_add_feature(id, get_all_notes)
  end
  #--------------------------------------------------------------------------
  # ☆ 反撃強化の適用
  #--------------------------------------------------------------------------
  def apply_counter_gain(user, damage, item)
    user.result.counter = false
    return damage if item.damage.recover?
    return damage * (1 + user.counter_gain)
  end
  #--------------------------------------------------------------------------
  # ☆ 拡張防御の適用
  #--------------------------------------------------------------------------
  def apply_adv_guard(damage, item)
    return damage if item.damage.recover?
    return damage if damage < 0
    #拡張防御の判定
    gurad = battler_add_ability(45)
    return damage if gurad[0] == 0
    return damage if rand(100) > gurad[0]
    @result.auto_guard = true
    return damage * ((100 - gurad[1]).to_f / 100)
  end
  #--------------------------------------------------------------------------
  # ☆ 踏みとどまりの適用
  #--------------------------------------------------------------------------
  def apply_stand(damage, item)
    return damage unless self.auto_stand
    return damage if item.damage.recover?
    return damage if damage < self.hp
    
    @result.auto_stand = true
    states.each do |state|
      remove_state(state.id) if state.battler_add_ability(2) != [150,0]
    end
    
    return [damage, self.hp - 1].min
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージゴールド変換の適用
  #--------------------------------------------------------------------------
  def apply_goldconvert(damage, item)
    return damage if item.damage.recover?
    data = battler_add_ability(27)
    return damage if data == 0
    
    #ゴールド減少
    reduce = (damage * data).to_i
    
    block = damage
    block = ($game_party.gold / data).to_i if reduce > $game_party.gold
    
    $game_party.lose_gold(reduce)
    @result.gold_convert = true if block > 0
    
    return (damage - block).to_i
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージMP変換の適用
  #--------------------------------------------------------------------------
  def apply_mpconvert(damage, item)
    return damage if item.damage.recover?
    data = battler_add_ability(26)
    return damage if data == 0
    
    #MP減少
    reduce = (damage * data).to_i
    
    block = damage
    block = (self.mp / data).to_i if reduce > self.mp
    
    self.mp = [0, self.mp - reduce].max
    @result.mp_convert = true if block > 0
    
    return (damage - block).to_i
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージMP吸収、ゴールド回収の適用
  #--------------------------------------------------------------------------
  def apply_add_drain(damage, item)
    return damage if item.damage.recover?
    #MP吸収
    if battler_add_ability(35) != 0
      gain = (damage * battler_add_ability(35)).to_i
      self.mp = [self.mmp, self.mp + gain].min
      @result.mp_convert_drain = gain if gain > 0
    end
    #ゴールド回収  
    if battler_add_ability(36) != 0
      gain = (damage * battler_add_ability(36)).to_i
      $game_party.gain_gold(gain)
      @result.gold_convert_drain = gain if gain > 0
    end
  end
  #--------------------------------------------------------------------------
  # ☆ メタルボディの適用
  #--------------------------------------------------------------------------
  def apply_metalbody(damage, item)
    return damage if item.damage.recover?
    return damage if self.metal_body == 0
    return [damage, self.metal_body].min
  end
  #--------------------------------------------------------------------------
  # ☆ 回復反転の適用
  #--------------------------------------------------------------------------
  def apply_reverse_heel(damage, item)
    return damage if damage > 0
    return damage if item.ignore_reverse_heel
    return damage unless self.reverse_heel
    return -1 * ( damage * self.reverse_heel ).to_i
  end
  #--------------------------------------------------------------------------
  # ☆ 防御壁の発動判定
  #--------------------------------------------------------------------------
  def defense_wall_usuable?(user,item)
    unless opposite?(user)
      return false unless user.confusion?
    end
    return false unless self.defense_wall
    return false if item.damage.recover?
    return true
  end
  #--------------------------------------------------------------------------
  # ☆ 無効化の発動判定
  #--------------------------------------------------------------------------
  def invalidate_usuable?(user,item,type)
    unless opposite?(user)
      return false unless user.confusion?
    end
    case type
    when 0
      return false if item.physical? 
      return false if item.magical?
      return false if battler_add_ability(46) == 0
    when 1
      return false if item.certain? 
      return false if item.magical?
      return false if battler_add_ability(47) == 0
    when 2
      return false if item.certain? 
      return false if item.physical?
      return false if battler_add_ability(48) == 0
    end
    return false if item.damage.recover?
    return true
  end
  #--------------------------------------------------------------------------
  # ☆ 無効化の適用
  #--------------------------------------------------------------------------
  def apply_invalidate_ability(type)
    case type
    when 0
      @result.certain_invalidate = true
    when 1
      @result.physical_invalidate = true
    when 2
      @result.magical_invalidate = true
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 防御壁の適用
  #--------------------------------------------------------------------------
  def apply_defense_wall
    @actor_add_counter[10] = [@actor_add_counter[10] - 1 , 0].max
    @result.defense = true
    return if @actor_add_counter[10] != 0

    states.each{|state| remove_state(state.id) if state.battler_add_ability(10) != 0 }
  end
  #--------------------------------------------------------------------------
  # ☆ 無効化障壁の適用
  #--------------------------------------------------------------------------
  def apply_invalidate_wall(damage, item)
    return damage if item.damage.recover?
    return damage if damage <= 0
    return damage if damage > self.invalidate_wall

    @result.invalidate = true
    return 0
  end
  #--------------------------------------------------------------------------
  # ☆ 身代わりユニットを取得
  #--------------------------------------------------------------------------
  def substitute_unit
    return [] unless @substitute_list
    arr = Array.new
    @substitute_list.each{|list| arr.push(list[1])}
    return arr
  end
  #--------------------------------------------------------------------------
  # ☆　行動変化オブジェクトターゲット変更(追加定義)
  #--------------------------------------------------------------------------
  def force_action_item_reset(skill_id)
    clear_actions
    action = Game_Action.new(self, true)
    action.set_skill(skill_id)
    @actions.push(action)
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘行動を消去(追加定義)
  #--------------------------------------------------------------------------
  def clear_select_action(index)
    return unless @actions[index]
    @actions[index] = nil
  end  
  #--------------------------------------------------------------------------
  # ★ 命中率判定チェック(追加定義)
  #--------------------------------------------------------------------------
  def item_success_cheak_process(user, item)
    case KURE::BaseScript::HIT_CHEAK_MODE
    when 0
      @result.missed = (@result.used && rand >= item_hit(user, item))
      @result.evaded = (!@result.missed && rand < item_eva(user, item))
    when 1
      @result.missed = (@result.used && rand(100) >= item.success_rate)
      @result.evaded = (!@result.missed && rand > item_ex_hit(user, item))
    end
  end
  #--------------------------------------------------------------------------
  # ★ 拡張命中率の計算(追加定義)
  #--------------------------------------------------------------------------
  def item_ex_hit(user, item)
    return [user.hit - eva,KURE::BaseScript::MIN_HIT_RATE].max  if item.physical?
    return [1 - mev,KURE::BaseScript::MIN_HIT_RATE].max  if item.magical?
    return 1
  end
  #--------------------------------------------------------------------------
  # ★ ステート転換オブジェクトを取得(拡張特徴ID50)(追加定義)
  #--------------------------------------------------------------------------
  def state_change_obj
    battler_add_ability(57)
  end
  #--------------------------------------------------------------------------
  # ★ ステート変換プロセス(拡張特徴ID50)(追加定義)
  #--------------------------------------------------------------------------
  def state_change_process(state_id)
    list = state_change_obj.select{|block| block[0] == state_id}.sort_by{rand}
    list.each{|block|
      next if rand(100) > block[2]
      return block[1]
      }
    return state_id
  end
end

#==============================================================================
# ■ Game_Actor(再定義項目集積)
#==============================================================================
class Game_Actor < Game_Battler
  attr_accessor :need_passive_refresh        # パッシブ更新フラグ
  attr_reader   :joblevel                    # 職業レベル
  attr_reader   :sub_class_level             # サブクラスレベル
  attr_reader   :sub_class_id                # サブクラス ID
  #--------------------------------------------------------------------------
  # ●■★▲◆☆◇§ 追加機能の初期化１(追加定義)
  #--------------------------------------------------------------------------
  def clear_add_object_before
    @used_skill_point = []              #スキルポイントシステム
    @battle_skill_point = []            #スキルポイントシステム
    
    @sub_class_id = 0                   #サブクラス
    @sub_class_level = 1                #サブクラス
    
    @ability_point = []                 #アビリティポイント保存配列
    
    @status_point = 0                   #ステータスポイント
    @status_divide = []                 #ステータス振り分け保存配列
    @divide_counter = []                #ステータス振り分け回数保存配列
    @last_level = 0                     #最終レベルアップ処理保存配列
    
    @battle_add_status = []             #戦闘中限定強化ステータス
    
    init_passive_skills                 #パッシブスキル初期化
    
    @equip_cache = []                   #装備キャッシュ(追加特徴用)
    @equip_note_cache = ""              #装備メモキャッシュ
    
    @job_cache = []                     #職業キャッシュ
    @job_note_cache = ""                #職業メモキャッシュ
    
    @ability_cache = []                 #アビリティキャッシュ
    @ability_cheack_cache = []          #アビリティチェックキャッシュ
    @ability_data_cache = []            #アビリティデータキャッシュ
        
    clear_master_object
    clear_cheackers
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキル関連配列の初期化(追加定義)
  #--------------------------------------------------------------------------
  def init_passive_skills
    @passive_cache ||= []
    @state_cache ||= []
    @passive_cache_data ||= [[],[],[]]
    @state_cache_data ||= [[],[],[]]
    @passive_skills_note ||= ""
    @equip_cache_p ||= []
    @skill_id_list ||= []
  end
  #--------------------------------------------------------------------------
  # ●■★▲◆☆◇§ 追加機能の初期化２(追加定義)
  #--------------------------------------------------------------------------
  def clear_add_object_after
    #初期スキルの習得
    @classlevel_list.each_with_index{|list,index|
      next if index == @class_id
      next if index == @sub_class_id
      next unless list
      learn_set_skill_lv(index, list) if KURE::BaseScript::C_DELETE_SKILL_MODE == 0
    }
    
    #TP初期化
    init_tp
    
    add_cheacker
    auto_state_adder
    auto_state_adder_ex
  end
  #--------------------------------------------------------------------------
  # ◇ マスターオブジェクトの初期化(追加定義)
  #--------------------------------------------------------------------------
  def clear_master_object
    return unless $kure_base_script[:SortOut]
    return unless @equips
    equip_list = equips
    
    master_w_list = $game_party.master_weapons_list
    master_a_list = $game_party.master_armors_list
    return unless master_w_list
    return unless master_a_list
    
    equip_list.each do |item|
      next unless item
      master_w_list[item.identify_id] = nil if item.class == RPG::Weapon
      master_a_list[item.identify_id] = nil if item.class == RPG::Armor
    end
  end
  #--------------------------------------------------------------------------
  # ● 初期レベルを設定する(追加定義)
  #--------------------------------------------------------------------------
  def first_lv_setup
    @classlevel_list = []
    @classlevel_list[@class_id] = first_skill_cheak_lv 
    lv_list = $data_actors[@actor_id].exp_jobchange_class    
    for i in 0..lv_list.size - 1
      @classlevel_list[lv_list[i]] = lv_list[i+1] if i % 2 == 0
    end
    first_skill_cheak_lv = @classlevel_list[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● クラスごとのレベルリストの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def class_level_list
    @classlevel_list ||= []
    @classlevel_list[@class_id] = @level
    return @classlevel_list
  end
  #--------------------------------------------------------------------------
  # ● 初期スキルの為のレベルを読み込み(追加定義)
  #--------------------------------------------------------------------------
  def first_skill_cheak_lv
    @level
  end
  #--------------------------------------------------------------------------
  # ● 指定IDの指定Lvまでの全職業スキルを習得(追加定義)
  #--------------------------------------------------------------------------
  def learn_set_skill_lv(job_id, job_lv)
    return unless job_id
    return if job_id == 0
    #スキルポイントシステムを利用している場合、初期スキルを制限する
    $data_classes[job_id].learnings.each do |learning|
      if $kure_base_script[:SkillPoint]
        learn_skill(learning.skill_id) if learning.level <= job_lv && learning.note.include?("<固有スキル>")
      else
        learn_skill(learning.skill_id) if learning.level <= job_lv
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定IDの指定Lvの職業スキルを操作(追加定義)
  #--------------------------------------------------------------------------
  def set_skill_specify_lv(job_id,level,mode)
    return unless job_id
    return if job_id == 0
    $data_classes[job_id].learnings.each do |learning|
      if $kure_base_script[:SkillPoint]
        if learning.note.include?("<固有スキル>")
          learn_skill(learning.skill_id) if learning.level == level && mode == 0
          forget_skill(learning.skill_id) if learning.level == level && mode == 1
        end
      else
        learn_skill(learning.skill_id) if learning.level == level && mode == 0
        forget_skill(learning.skill_id) if learning.level == level && mode == 1
      end
    end    
  end
  #--------------------------------------------------------------------------
  # ● 指定IDの指定Lvの職業スキルを習得(追加定義)
  #--------------------------------------------------------------------------
  def learn_skill_specify_lv(job,level)
    set_skill_specify_lv(job,level,0)
  end
  #--------------------------------------------------------------------------
  # ● 指定IDの指定Lvの職業スキルを忘れる(追加定義)
  #--------------------------------------------------------------------------
  def foget_skill_specify_lv_job(job,level)
    set_skill_specify_lv(job,level,1)
  end
  #--------------------------------------------------------------------------
  # ■ 習得スキルオブジェクトの配列取得(追加定義)
  #--------------------------------------------------------------------------
  def learned_skill_list
    return @skills.sort.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # ▲ サブクラススキルオブジェクトの配列取得(追加定義)
  #--------------------------------------------------------------------------
  def sub_class_skills_id
    return []
  end
  #--------------------------------------------------------------------------
  # ■★ 現在使用可能かどうかを判定する(追加定義)
  #--------------------------------------------------------------------------
  def memorize_now?(id)
    return true unless $kure_base_script[:Memorize]
    #メモライズ時の判定
    return true if @memory_skills.include?(id)
    return true if @extra_skills.include?(id)
    return true if unselect_skill?(id)
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ パッシブスキル条件を判定する(追加定義)
  #--------------------------------------------------------------------------
  def passive_condition?(id, weapon, armor)
    return true if need_weapon_condition?(id, weapon) && need_armor_condition?(id, armor)
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ パッシブスキル条件(必要武器タイプ)を判定する(追加定義)
  #--------------------------------------------------------------------------
  def need_weapon_condition?(id, weapon)
    need_weapon = $data_skills[id].passive_condition_list(0)
    return true if need_weapon == []
    return true if weapon == [] && need_weapon.include?(0)
    weapon.each{|id| return true if need_weapon.include?(id)}
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ パッシブスキル条件(必要防具タイプ)を判定する(追加定義)
  #--------------------------------------------------------------------------
  def need_armor_condition?(id, armor)
    need_armor = $data_skills[id].passive_condition_list(1)
    return true if need_armor == []
    armor.each{|id| return true if need_armor.include?(id)}
    return false
  end
  #--------------------------------------------------------------------------
  # ■ 登録不要のスキル判定(追加定義)
  #--------------------------------------------------------------------------
  def unselect_skill?(skill_id)
    return unless skill_id
    return if skill_id == 0
    skilldata = $data_skills[skill_id].note
    return true if skilldata.include?("<メモライズ不要>")
    
    cheak = []
    while skilldata do
      skilldata.match(/<メモライズ不要\s?(\d+)>/)
      cheak.push($1.to_i) if $1
      skilldata = $'
    end
    
    return true if cheak.include?(id)
    return false
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルへオブジェクトの出力(追加定義)
  #--------------------------------------------------------------------------
  def add_passive_skills(array, type)
    array.each do |id|
      data = $data_skills[id]  if type == 1
      data = $data_states[id]  if type == 2
      #武器オブジェクト
      data.passive_skill_id_w.each do |weapon|
        if type == 1
          @passive_cache_data[0][weapon] ||= []
          @passive_cache_data[0][weapon].push($data_weapons[weapon])
        end
        if type == 2
          @state_cache_data[0][weapon] ||= []
          @state_cache_data[0][weapon].push($data_weapons[weapon])
        end
      end
      #防具オブジェクト
      data.passive_skill_id_a.each do |armor|
        if type == 1
          @passive_cache_data[1][armor] ||= []
          @passive_cache_data[1][armor].push($data_armors[armor])
        end
        if type == 2
          @state_cache_data[1][armor] ||= []
          @state_cache_data[1][armor].push($data_armors[armor])
        end
      end
      #職業オブジェクト
      data.passive_skill_id_c.each do |job|
        if type == 1
          @passive_cache_data[2][job] ||= []
          @passive_cache_data[2][job].push($data_classes[job])
        end
        if type == 2
          @state_cache_data[2][job] ||= []
          @state_cache_data[2][job].push($data_classes[job])
        end
      end
    end    
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルへオブジェクトの削除(追加定義)
  #--------------------------------------------------------------------------
  def remove_passive_skills(array, type)
    array.each do |id|
      data = $data_skills[id]  if type == 1
      data = $data_states[id]  if type == 2
      #武器オブジェクト
      data.passive_skill_id_w.each do |weapon|
        @passive_cache_data[0][weapon].shift if type == 1 && @passive_cache_data[0][weapon]
        @state_cache_data[0][weapon].shift if type == 2 && @state_cache_data[0][weapon]
      end
      #防具オブジェクト
      data.passive_skill_id_a.each do |armor|
        @passive_cache_data[1][armor].shift if type == 1 && @passive_cache_data[1][armor]
        @state_cache_data[1][armor].shift if type == 2 && @state_cache_data[1][armor]
      end
      #職業オブジェクト
      data.passive_skill_id_c.each do |job|
        @passive_cache_data[2][job].shift if type == 1 && @passive_cache_data[2][job]
        @state_cache_data[2][job].shift if type == 2 && @state_cache_data[2][job]
      end
    end    
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルオブジェクトの再構築(追加定義)
  # ※データ移行措置
  #--------------------------------------------------------------------------
  def reset_passive_data
    @passive_cache = []
    @state_cache = []
    @passive_cache_data = [[],[],[]]
    @state_cache_data = [[],[],[]]
    @passive_skills_note = ""
    @equip_cache_p = []
    @ver_five_flag2 = true
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルオブジェクトの配列のセット(追加定義)
  #--------------------------------------------------------------------------
  def set_passive_skills(cheaker = 0)
    return unless actor?
    return unless @need_passive_refresh
    init_passive_skills
    reset_passive_data unless @ver_five_flag2
    
    return if @state_cache == @states && cheaker == 2
    #装備タイプの更新
    unless @equip_cache_p[0] == equips_ids
      @equip_cache_p[0] = equips_ids.clone
      @equip_cache_p[1] = weapons.collect{|item| item.wtype_id if item}.clone
      @equip_cache_p[2] = equips.collect{|item| item.etype_id if item}.clone
      @skill_id_list = []
    end
    
    #スキルキャッシュの更新
    set_skill = skills.collect{|obj| obj.id}.select{|id| memorize_now?(id)}
    if @skill_id_list != set_skill or @setting_skills == nil
      @skill_id_list = set_skill.clone
      @setting_skills = @skill_id_list.select{|skill| passive_condition?(skill, @equip_cache_p[1], @equip_cache_p[2])}.clone
    end
    
    return if @passive_cache == @setting_skills && @state_cache == @states
    @passive_skills = []
    
    #追加スキルと削除スキルをセット
    add_skill_list = @setting_skills - @passive_cache
    remove_skill_list = @passive_cache - @setting_skills
    
    add_state_list = @states - @state_cache
    remove_state_list = @state_cache - @states
    
    if @passive_cache != @setting_skills
      add_passive_skills(add_skill_list, 1)
      remove_passive_skills(remove_skill_list,1)
    end
    
    if @state_cache != @states
      add_passive_skills(add_state_list, 2)
      remove_passive_skills(remove_state_list,2)
    end
    
    @passive_skills = @state_cache_data + @passive_cache_data
    @passive_skills.flatten!.compact!
    @passive_skills_note = @passive_skills.collect{|obj| obj.note}.join
    
    @passive_cache = @setting_skills.clone
    @state_cache = @states.clone
    release_unequippable_items
    auto_state_adder_ex
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルオブジェクトの配列のセット(追加定義)
  #--------------------------------------------------------------------------
  def passive_skills
    @passive_skills ||= []
    return @passive_skills
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルオブジェクトの全てのメモ(追加定義)
  #--------------------------------------------------------------------------
  def passive_skills_notes
    @passive_skills_note ||= ""
    return @passive_skills_note
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの配列のセット(追加定義)
  #--------------------------------------------------------------------------
  def ability_point
    @ability_point ||= []
    return @ability_point
  end
  #--------------------------------------------------------------------------
  # ● 特徴オブジェクトの配列取得（追加定義）
  #--------------------------------------------------------------------------
  def features(code)
    all_features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # § ステータス振り分け処理（追加定義）
  #--------------------------------------------------------------------------
  def status_divide(param_id, value)
    @status_divide ||= []
    @status_divide[param_id] ||= 0
    @divide_counter ||= []
    @divide_counter[param_id] ||= 0
      
    return if value < 0 and @divide_counter[param_id] <= 0
    
    @status_divide[param_id] = [@status_divide[param_id] + value, 0].max
    
    if value > 0
      @divide_counter[param_id] += 1
    else
      @divide_counter[param_id] = [@divide_counter[param_id] - 1,0].max
    end
  end
  #--------------------------------------------------------------------------
  # § ステータス振り分け数配列の取得（追加定義）
  #--------------------------------------------------------------------------
  def status_divide_time_all
    return [0,0,0,0,0,0,0,0] unless @divide_counter
    return @divide_counter
  end
  #--------------------------------------------------------------------------
  # § ステータス振り分け数の取得（追加定義）
  #--------------------------------------------------------------------------
  def status_divide_time(param_id)
    return 0 unless @divide_counter
    return 0 unless @divide_counter[param_id]
    return @divide_counter[param_id]
  end
  #--------------------------------------------------------------------------
  # § ステータス振り分け数の代入（追加定義）
  #--------------------------------------------------------------------------
  def set_status_divide_time=(arr)
    @divide_counter = arr
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの呼び出し（追加定義）
  #--------------------------------------------------------------------------
  def status_point
    @status_point ||= 0
    return @status_point
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの代入（追加定義）
  #--------------------------------------------------------------------------
  def status_point=(value)
    @status_point = value
  end
  #--------------------------------------------------------------------------
  # § ステータス振り分け量の呼び出し（追加定義）
  #--------------------------------------------------------------------------
  def divide_param
    return @status_divide
  end
  #--------------------------------------------------------------------------
  # § ステータス振り分け量の代入（追加定義）
  #--------------------------------------------------------------------------
  def set_divide_param=(arr)
    @status_divide = arr
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの消費（追加定義）
  #--------------------------------------------------------------------------
  def use_status_point(value)
    @status_point ||= 0
    @status_point = [@status_point - value, 0].max
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの追加（追加定義）
  #--------------------------------------------------------------------------
  def add_status_point(value)
    @status_point ||= 0
    @status_point += value
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの配列のセット
  #--------------------------------------------------------------------------
  def gain_ability_point(a_exp)
    return if a_exp == 0
    @ability_point ||= [] ; get_list = []
    
    equip = equips.compact.collect{|obj| obj.get_ability_point}.flatten!
    return unless equip
    for i in 0..equip.size - 1
      next if i % 2 != 0
      next unless equip[i + 1]
      get_list.push([equip[i],equip[i + 1]])
    end
    
    return if get_list == []
    get_list.each do |data|
      next unless data
      next if data == []
      
      #アビリティポイントを獲得
      point = a_exp * data[1]
      @ability_point[data[0]] ||= 0
      @ability_point[data[0]] += point
      next if skill_learn?($data_skills[data[0]])
      next if $kure_base_script[:JobLvSystem] && skill_learn_sub?($data_skills[data[0]])
        
      #スキル習得判定
      if @ability_point[data[0]] >= $data_skills[data[0]].need_ability_point
        learn_skill(data[0])
        learn_skill_sub(data[0]) if $kure_base_script[:JobLvSystem]
        @ability_point[data[0]] = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 記憶容量増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_memorize
    equips.select{|obj| obj}.inject(0){|r, obj| r += obj.gain_memorize} 
  end
  #--------------------------------------------------------------------------
  # ● 記憶数増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_max_memorize
    equips.select{|obj| obj}.inject(0){|r, obj| r += obj.gain_max_memorize} 
  end
  #--------------------------------------------------------------------------
  # ☆ TP増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_tp
    return 0
  end
  #--------------------------------------------------------------------------
  # ☆ TP％増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_tp_per
    return 1   
  end
  #--------------------------------------------------------------------------
  # ☆ アクタ―、職業メモの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def call_job_note_cache  
    #初期化
    @job_cache ||= [] ; @job_note_cache ||= ""
    
    #キャッシュと同一であれば保存した配列を返す
    return @job_note_cache if @job_cache == [@actor_id, @class_id, @sub_class_id]

    actor = ""; job = ""; sub = ""
    actor = $data_actors[@actor_id].note
    job = $data_classes[@class_id].note
    sub = $data_classes[@sub_class_id].note if @sub_class_id != 0
    str = actor + job + sub
    @job_note_cache = str.clone
    @job_cache = [@actor_id, @class_id, @sub_class_id].clone
    return @job_note_cache 
  end
  #--------------------------------------------------------------------------
  # ☆ 装備品オブジェクトのID配列取得(追加定義)
  #--------------------------------------------------------------------------
  def equips_ids
    @equips.collect {|item| item.object && !item.object.broken? ? item.object.id : 0 }
  end  
  #--------------------------------------------------------------------------
  # ☆ 装備品オブジェクトのメモ取得(追加定義)
  #--------------------------------------------------------------------------
  def equips_note
    @equips.select{|item| item.object && !item.object.broken?}.collect{|item| item.object.note}.join
  end
  #--------------------------------------------------------------------------
  # ☆ 装備品メモの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def clear_equip_note_cache
    @equip_cache = [] ; @equip_note_cache = ""
  end
  #--------------------------------------------------------------------------
  # ☆ 装備品メモの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def call_equip_note_cache
    #初期化
    @equip_cache ||= [] ; @equip_note_cache ||= ""
    
    #キャッシュと同一であれば保存した配列を返す
    return @equip_note_cache if @equip_cache == equips_ids

    @equip_note_cache = equips_note.clone
    @equip_cache = equips_ids.clone
    return @equip_note_cache
  end
  #--------------------------------------------------------------------------
  # ☆ 追加属性配列を取得(追加定義)
  #--------------------------------------------------------------------------
  def reflect_elements
    reflect = [] ; result = []
    reflect = @equips.select{|obj| obj.object && obj.object.reflect_elements}.collect{|obj| obj.object.features}
    return result if reflect == []
    
    reflect.each do |obj|
      obj.each{|ft| result.push(ft.data_id) if ft.code == 31}
    end
    return result
  end 
  #--------------------------------------------------------------------------
  # ☆ リセットフラグ(追加定義)
  #--------------------------------------------------------------------------
  def reset_skill_flag
    return @reset_skill_flag
  end
  #--------------------------------------------------------------------------
  # ☆ リセットフラグ(追加定義)
  #--------------------------------------------------------------------------
  def reset_skill_flag=(value)
    @reset_skill_flag = value
  end
  #--------------------------------------------------------------------------
  # ○ スキルの必要装備を装備しているか(追加定義)
  #--------------------------------------------------------------------------
  def skill_etype_ok?(skill)
    #追加防具タイプ
    return true if skill.need_etype_id == []
    skill.need_etype_id.each{|id| return false unless etype_equipped?(id)}
    return true
  end
  #--------------------------------------------------------------------------
  # ○ 特定のタイプの防具を装備しているか(追加定義)
  #--------------------------------------------------------------------------
  def etype_equipped?(etype_id)
    equips.compact.any? {|equip| equip.etype_id == etype_id }
  end
  #--------------------------------------------------------------------------
  # ▲ 特殊経験値の獲得（経験獲得率を考慮）(追加定義)
  #--------------------------------------------------------------------------
  def gain_ex_exp(equip_exp = 0, a_exp = 0, s_exp = 0, ski_exp = 0)
    #装備個別管理を導入している場合装備経験値を獲得させる
    equip = (equip_exp * final_exp_rate).to_i if $kure_base_script[:SortOut]
    change_ex_exp(equip, a_exp, s_exp, ski_exp, true)
  end
  #--------------------------------------------------------------------------
  # ▲ 特殊経験値の変更(追加定義)
  #     show : レベルアップ表示フラグ
  #--------------------------------------------------------------------------
  def change_ex_exp(equip_exp = 0, a_exp = 0, s_exp = 0, ski_exp = 0, show)
    last_skills = learned_skill_list
    
    #装備固有の経験値処理
    if $kure_base_script[:SortOut]
      equips.each do |item|
        next unless item
        identify_id = item.identify_id
        master_container = $game_party.item_master_container(item.class)
        master_container[identify_id].equip_exp = equip_exp
        master_container[identify_id].slot_equip_exp = equip_exp
      end
    end
    
    #APの処理
    gain_ability_point(a_exp)
    
    #ステータスポイントの処理
    add_status_point(s_exp)
    
    #スキルポイントの処理
    add_skill_point(ski_exp) if $kure_base_script[:SkillPoint] or $kure_base_script[:SkillPoint2]
    
    new_skills = learned_skill_list
    
    display_ap_skilll_learn(new_skills - last_skills) if new_skills - last_skills != []
  end
  #--------------------------------------------------------------------------
  # ▲ APシステムによるスキル習得メッセージの表示(追加定義)
  #--------------------------------------------------------------------------
  def display_ap_skilll_learn(new_skills)
    if $game_message.need_new_page
      $game_message.new_page
      $game_message.need_new_page = false
    end
    
    new_skills.each do |skill|
      $game_message.add(sprintf(Vocab::ObtainSkill_AP, @name ,skill.name))
    end
  end
end

#==============================================================================
# ■ Game_Party(追加定義)
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ☆ パーティ追加能力判定(追加定義)
  #--------------------------------------------------------------------------
  def party_add_ability(ability_id)
    list = battle_members.collect{|actor| actor.party_add_ability(ability_id)}
    list.flatten!
    return list
  end
  #--------------------------------------------------------------------------
  # ☆ パーティ全員のパッシブスキルを更新(追加定義)
  #--------------------------------------------------------------------------
  def party_passive_reset
    all_members.each{|actor| actor.set_passive_skills}
  end
end

#==============================================================================
# ■ Game_BaseItem(追加定義)
#==============================================================================
class Game_BaseItem
  #--------------------------------------------------------------------------
  # ● IDの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def id
    @item_id
  end
  #--------------------------------------------------------------------------
  # ● 拡張装備タイプの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def add_etype_id
    return object.add_etype_id if object
  end  
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  attr_accessor :steal
  #--------------------------------------------------------------------------
  # ◇ レベルの取得(追加定義)
  #--------------------------------------------------------------------------
  def level
    enemy.level
  end
  #--------------------------------------------------------------------------
  # ◇ 装備経験値の取得(追加定義)
  #--------------------------------------------------------------------------
  def equip_exp
    enemy.equip_exp
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの取得(追加定義)
  #--------------------------------------------------------------------------
  def ability_exp
    enemy.ability_exp
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの取得(追加定義)
  #--------------------------------------------------------------------------
  def status_exp
    enemy.status_exp
  end
  #--------------------------------------------------------------------------
  # 〒 スキルポイントの取得(追加定義)
  #--------------------------------------------------------------------------
  def skill_exp
    enemy.skill_exp
  end
  #--------------------------------------------------------------------------
  # ☆ スティールリストの取得(追加定義)
  #--------------------------------------------------------------------------
  def steal_list
    enemy.steal_list
  end 
  #--------------------------------------------------------------------------
  # ☆ スティールされた後か判定(追加定義)
  #--------------------------------------------------------------------------
  def stealed?
    return false unless @steal
    return true
  end
end
  
#==============================================================================
# ■ Game_Troop
#==============================================================================
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ◇ 装備経験値の合計計算(追加定義)
  #--------------------------------------------------------------------------
  def equip_exp_total
    equip_exp_total = dead_members.inject(0) {|r, enemy| r += enemy.equip_exp }
    equip_exp_rate = $game_party.party_add_ability(5)
    equip_exp_total *= equip_exp_rate.max
    if $kure_base_script[:PartyEdit] && KURE::PartyEdit::SHARE_EXP_MODE == 1
      max = $game_party.max_battle_members
      now = $game_party.battle_members_size
      ptm_rate = 1 + max.to_f / now 
      equip_exp_total *= ptm_rate
    end
    return equip_exp_total.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの合計計算(追加定義)
  #--------------------------------------------------------------------------
  def ability_exp_total
    ability_exp_total = dead_members.inject(0) {|r, enemy| r += enemy.ability_exp }
    return ability_exp_total.to_i
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの合計計算(追加定義)
  #--------------------------------------------------------------------------
  def status_exp_total
    status_exp_total = dead_members.inject(0) {|r, enemy| r += enemy.status_exp }
    return status_exp_total.to_i
  end
  #--------------------------------------------------------------------------
  # 〒 スキルポイントの合計計算(追加定義)
  #--------------------------------------------------------------------------
  def skill_exp_total
    skill_exp_total = dead_members.inject(0) {|r, enemy| r += enemy.skill_exp }
    return skill_exp_total.to_i
  end
end

#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  attr_accessor   :forcing                  # 戦闘行動の強制フラグ
  #--------------------------------------------------------------------------
  # ☆ 行動変化(追加定義)
  #--------------------------------------------------------------------------
  def change_action(skill_id)
    @force_action_effect = false
    return skill_id if @subject.battler_add_ability(15) == []
    set_skill_id = skill_id
    cheak_list = @subject.battler_add_ability(15).sort_by{rand}
        
    cheak_list.each do |data|
      dice = rand(100)
      next if dice > data[1]
      @force_action_item = $data_skills[data[0]]
      set_skill_id = @force_action_item.id
      @force_action_effect = true
      break
    end
    return set_skill_id
  end
  #--------------------------------------------------------------------------
  # ☆ ランダムエフェクト(追加定義)
  #--------------------------------------------------------------------------
  def randam_effecter(skill_id)
    @ramdom_effect = false
    return skill_id
  end
  #--------------------------------------------------------------------------
  # ☆ ランダムエフェクト(追加定義)
  #--------------------------------------------------------------------------
  def randam_item_effecter(item_id)
    @ramdom_effect = false
    return item_id
  end
  #--------------------------------------------------------------------------
  # ☆ スキル変化(追加定義)
  #--------------------------------------------------------------------------
  def change_effecter(skill_id)
    @change_effect = false
    return skill_id unless @subject.battler_add_ability(13)[skill_id]
    change_list = @subject.battler_add_ability(13)[skill_id].sort_by{rand}
    return skill_id if change_list == []
    
    @change_item = $data_skills[change_list[0]]
    @change_effect = true
    return @change_item.id
  end
  #--------------------------------------------------------------------------
  # ☆ ランダムオブジェクト取得(追加定義)
  #--------------------------------------------------------------------------
  def random_item
    return nil unless @ramdom_effect
    return @random_item
  end
  #--------------------------------------------------------------------------
  # ☆ スキル変化オブジェクト取得(追加定義)
  #--------------------------------------------------------------------------
  def change_item
    return nil unless @change_effect
    return @change_item
  end
  #--------------------------------------------------------------------------
  # ☆ 行動変化オブジェクト取得(追加定義)
  #--------------------------------------------------------------------------
  def force_action_item
    return nil unless @force_action_effect
    return @force_action_item
  end
  #--------------------------------------------------------------------------
  # ☆ アイテムオブジェクト定義(追加定義)
  #--------------------------------------------------------------------------
  def item=(item)
    @item.object = item if item
  end
  #--------------------------------------------------------------------------
  # ☆ 行動主体の定義(追加定義)
  #--------------------------------------------------------------------------
  def subject=(subject)
    @subject = subject if subject
  end
end

#==============================================================================
# ■ Game_ActionResult(追加定義)
#==============================================================================
class Game_ActionResult
  #--------------------------------------------------------------------------
  # ● 追加インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :use_steal                # スティールフラグ
  attr_accessor :steal                    # スティールフラグ
  attr_accessor :stealed                  # スティールフラグ
  attr_accessor :auto_stand               # 踏みとどまりフラグ
  attr_accessor :reverse_deth             # 即死反転フラグ
  attr_accessor :defense                  # 防御壁フラグ
  attr_accessor :change_skill             # スキル変化
  attr_accessor :invalidate               # 無効化
  attr_accessor :broken                   # 破壊装備
  attr_accessor :final_atk                # 最終発動スキル
  attr_accessor :mp_convert               # MPダメージ変換
  attr_accessor :gold_convert             # ゴールドダメージ変換
  attr_accessor :mp_convert_drain         # MPダメージ吸収
  attr_accessor :gold_convert_drain       # ゴールドダメージ回収
  attr_accessor :auto_guard               # オートガード
  attr_accessor :certain_invalidate       # 必中無効化
  attr_accessor :physical_invalidate      # 物理無効化
  attr_accessor :magical_invalidate       # 魔法無効化
  attr_accessor :counter                  # 反撃フラグ
  attr_accessor :multi_state              # 重複ステートフラグ
  attr_accessor :sp_added_state_objects   # 特殊付与ステート
  #--------------------------------------------------------------------------
  # ☆ クリア
  #--------------------------------------------------------------------------
  alias k_basescript_before_clear clear
  def clear
    k_basescript_before_clear
    clear_steal
    clear_battler_ability
  end
  #--------------------------------------------------------------------------
  # ☆ スティールフラグのクリア
  #--------------------------------------------------------------------------
  def clear_steal
    @use_steal = false
    @steal = false
    @stealed  = false
  end
  #--------------------------------------------------------------------------
  # ☆ バトラー能力フラグのクリア
  #--------------------------------------------------------------------------
  def clear_battler_ability
    @auto_stand = false             #踏みとどまり
    @reverse_deth = false           #即死反転
    @defense = false                #防御壁
    @invalidate = false             #無効化
    @change_skill = false           #スキル変化
    @broken = Array.new             #破壊装備
    @mp_convert = false             #MPダメージ変換
    @gold_convert = false           #金額ダメージ変換
    @mp_convert_drain = false       #MPダメージ吸収
    @gold_convert_drain = false     #金額ダメージ回収
    @auto_guard = false             #オートガード
    @certain_invalidate = false     # 必中無効化
    @physical_invalidate = false    # 物理無効化
    @magical_invalidate = false     #魔法無効化
    @counter = false                #反撃
    @multi_state = false            #重複ステート
    @sp_added_state_objects = []    #特殊付与ステート
  end
  #--------------------------------------------------------------------------
  # ● 無効化したか否かを判定
  #--------------------------------------------------------------------------
  def invalidate?
    return true if @defense
    return true if @invalidate
    return true if @certain_invalidate
    return true if @physical_invalidate
    return true if @magical_invalidate    
  end
end

#==============================================================================
# ■ Scene_Battle(追加定義)
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 連結発動プロセス(追加定義)
  #--------------------------------------------------------------------------
  def team_attack_process(item)
    return unless item.is_a?(RPG::Skill)
    team_skill = item.team_action
    return nil unless team_skill
    team_member = @subject.friends_unit.members
    
    team_member.each do |battler|
      next if battler == @subject
      next unless battler.alive?
      next unless battler.movable?
      battler.actions.each_with_index do |action, index|
        next unless action
        if action.item == $data_skills[team_skill[1]]
          battler.clear_select_action(index)
          return [battler, $data_skills[team_skill[0]] ,$data_skills[team_skill[1]] ]
        end
      end
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 発動前コモンイベント(追加定義)
  #--------------------------------------------------------------------------
  def pre_common_process(item)
    return unless item.pre_common
    $game_temp.reserve_common_event(item.pre_common)
    $game_troop.setup_battle_event
    process_event
    update_for_wait
    @status_window.open
  end
  #--------------------------------------------------------------------------
  # ★ 行動反応追撃発動(追加定義)
  #--------------------------------------------------------------------------
  def invoke_reaction_attack(user, item, target)
    return if target.dead?
    group = user.friends_unit.members.select{|battler| battler != user}
    group.each{|battler|
      next unless battler.alive?
      next unless battler.movable?
      battler.battler_add_ability(59).each{|block|
        next if !battler.opposite?(target) && block[0] < 2
        next if battler.opposite?(target) && block[0] == 2
        next if rand(100) > block[3]
        case block[0]
        when 0
          next if item.damage.element_id != block[1]
        when 1
          next if item.hit_type != block[1] && block[1] != 3
        end
        
        skill = $data_skills[block[2]]
        @log_window.display_chase_attack(battler, skill)
        
        skill.effects.each {|effect| battler.item_global_effect_apply(effect) }
        multi_animater(skill, [target])
        apply_item_effects(target, skill)
        
        wait_for_animation
        @log_window.wait_and_clear
        break
      }
    }
  end
  #--------------------------------------------------------------------------
  # ● 連鎖発動プロセス(追加定義)
  #--------------------------------------------------------------------------
  def chain_action_process(item)
    return unless item.is_a?(RPG::Skill)
    wait_for_animation
    chain_a = item.chain_action
    return unless chain_a
    
    while chain_a do
      if chain_a[1] > rand(100)
        break unless @subject.alive?
        break unless @subject.movable?
        next_skill = $data_skills[chain_a[0]]
        pre_common_process(next_skill)
        @log_window.back_one
        @log_window.display_use_item(@subject, next_skill)
        next_skill.effects.each {|effect| @subject.item_global_effect_apply(effect) }
        
        @subject.current_action.item = next_skill
        multi_e = next_skill.multi_skill_effect
        targets = @subject.current_action.make_targets.compact
        effect_adopter(next_skill, multi_e, targets)
        chain_a = next_skill.chain_action
      else
        chain_a = nil
      end
      wait_for_animation
      @log_window.wait_and_clear
    end
    wait_for_animation
    @log_window.wait_and_clear
    @subject.current_action.item = item if @subject.current_action
  end
  #--------------------------------------------------------------------------
  # ● エフェクト発動プロセス(追加定義)
  #--------------------------------------------------------------------------
  def effect_adopter(item, multi_e, targets)
    if multi_e == []
      #連続アニメーション
      multi_animater(item, targets)
      targets.each {|target| item.repeats.times { invoke_item(target, item) } }
    else
      multi_e.each do |skill_id|
        break unless @subject.alive?
        break unless @subject.movable?
        item2 = $data_skills[skill_id]
        @subject.current_action.item = item2
        item2.effects.each {|effect| @subject.item_global_effect_apply(effect) }
        targets = @subject.current_action.make_targets.compact
        
        multi_animater(item2, targets)
        targets.each {|target| item2.repeats.times { invoke_item(target, item2) } }
      end
      @subject.current_action.item = item if @subject.alive?
    end
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # ● 連続アニメーション(追加定義)
  #--------------------------------------------------------------------------
  def multi_animater(item, targets)  
    multi_anim = Array.new
    multi_anim.push(item.animation_id)
    multi_anim += item.multi_anim_effect
    multi_anim.compact!
        
    multi_anim.each do |anim_id|
      anim_d = $data_animations[anim_id]
      if anim_d && anim_d.to_screen? && KURE::BaseScript::C_ANIMATION_CUTTER == 1
        show_normal_animation([targets[0]].compact, anim_id) if targets[0]
      else
        show_animation(targets, anim_id)
      end
      @log_window.wait
    end
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # ● 戦闘開始時スキル発動(追加定義)
  #--------------------------------------------------------------------------
  def first_invoke_items
    #アクションを作成
    $game_party.make_actions
    $game_troop.make_actions
    
    turn_invoke_process(37)
  end
  #--------------------------------------------------------------------------
  # ● ターン間スキル発動(追加定義)
  #--------------------------------------------------------------------------
  def turn_invoke_items(turn)
    case turn
    when 1
      turn_invoke_process(38)
    when 2
      turn_invoke_process(39)
    end
  end
  #--------------------------------------------------------------------------
  # ● ターン間スキル発動実働プロセス(追加定義)
  #--------------------------------------------------------------------------  
  def turn_invoke_process(id)
    all_battle_members.each do |battler|
      next unless battler.alive?
      next unless battler.movable?
      skill_list = battler.battler_add_ability(id)
      next if skill_list == []
      
      skill_list.each do |skill|
        #発動率判定
        next if rand(100) >= skill[2]
        
        #行動者を取得
        @subject = battler
        
        case id
        when 37
          #戦闘開始時の場合はウィンドウを表示する
          @status_window.unselect
          @status_window.open
        when 38,39
          #ターン間はスキルを保存しておく
          keep_skill = @subject.current_action.item if @subject.current_action
        end
        
        #スキル決定
        attack_skill = $data_skills[skill[1]]
          
        #発動タイプ
        case skill[0]
        when "N"
          @subject.make_actions unless @subject.current_action
          @subject.current_action.item = attack_skill
        when "F"
          @subject.force_action_item_reset(attack_skill.id)
        end
        
        #エフェクト発動
        use_turn_skill
            
        @log_window.wait_and_clear
        case id
        when 38,39
          @subject.current_action.item = keep_skill if keep_skill
        end
        
        refresh_status
      end
    end
    
    #行動者初期化
    @subject =  nil 
  end
  #--------------------------------------------------------------------------
  # ● ノーコストでのスキル発動
  #--------------------------------------------------------------------------
  def use_turn_skill 
    #使用スキルの判定、コストスキルの判定
    item = @subject.current_action.item
    
    #発動前コモン
    pre_common_process(item)
    
    #複数回発動
    @subject.multi_invoke(item).times{
      break unless @subject.alive?
      break unless @subject.movable?
    
    @log_window.display_use_item(@subject, item)
    item.effects.each {|effect| @subject.item_global_effect_apply(effect) }

    #マルチエフェクト
    multi_e = item.multi_skill_effect
    targets = @subject.current_action.make_targets.compact
    
    #エフェクト発動
    effect_adopter(item, multi_e, targets)
    
    #連鎖発動
    chain_action_process(item)
        
    #発動後ステート
    wait_for_animation
    after_add_state_process(item)
    @log_window.display_sp_added_states(@subject)
    refresh_status
    
    #オートリザレクション
    if KURE::BaseScript::C_AUTO_REVIVE == 1
      all_battle_members.each do |battler|
        auto_revive_process(battler)
      end
    end
    
    @log_window.wait_and_clear
    }
  end
  #--------------------------------------------------------------------------
  # ● オートリザレクション実行(追加定義)
  #--------------------------------------------------------------------------
  def auto_revive_process(battler)
    return unless battler.death_state?
    return if battler.actor_add_counter[1] == 0
    return if battler.actor_add_delay[1] > 0
    
    #判定通過(発動)
    battler.actor_add_counter[1] -= 1
    battler.actor_add_delay[1] += 1
    auto_revive_data = battler.battler_add_ability(1).clone
    
    #残り回数を使いきった場合ステートを解除
    if battler.actor_add_counter[1] == 0 
      battler.states.each do |state|
        battler.erase_state(state.id) if state.battler_add_ability(1)[0] != 0
      end
    end
      
    #確率判定
    return if auto_revive_data[1] < rand(100)
    battler.hp = (battler.mhp * auto_revive_data[0].to_f / 100).to_i
    show_animation([battler], KURE::BaseScript::S_AUTO_REVIVE_ANIM_ID)
    
    @log_window.display_autorevive_message(battler)
    refresh_status
  end
  #--------------------------------------------------------------------------
  # ● 追撃実行(追加定義)
  #--------------------------------------------------------------------------
  def chase_attack_process(chase_battler)
    chase_battler.each do |battler_list|
      e_list = $game_troop.members if battler_list[0].actor?
      e_list = $game_party.members if battler_list[0].enemy?
      next unless e_list
      
      e_list.each do |enemy|
        next unless enemy.alive?
        next unless enemy.movable?
        battler_list[1].each do |id|
          next unless enemy.state?(id)
          #追撃発動
          attack_skill = $data_skills[battler_list[0].chace_skill_id]
          attack_skill.effects.each {|effect| battler_list[0].item_global_effect_apply(effect) }
          @log_window.display_chase_attack(battler_list[0], attack_skill)
          enemy.item_apply(battler_list[0], attack_skill)
          show_counter_animation([enemy], battler_list[0], attack_skill)
          refresh_status
          @log_window.display_action_results(enemy, attack_skill)
          break
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 反撃アニメーションの表示
  #--------------------------------------------------------------------------
  def show_counter_animation(targets, attacker, attack_skill)
    if attack_skill.animation_id < 0
      if attacker.actor?
        show_normal_animation(targets, attacker.atk_animation_id1, false)
        show_normal_animation(targets, attacker.atk_animation_id2, true)
      else
        Sound.play_enemy_attack
        abs_wait_short
      end
    else
      show_normal_animation(targets, attack_skill.animation_id)
    end
    @log_window.wait
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # ● 最終反撃の発動(追加定義)
  #--------------------------------------------------------------------------
  def invoke_final_attack(target, final_skill)
    if $lnx_include && $lnx_include[:lnx11a]
      item = $data_skills[final_skill]
      if LNX11::BATTLELOG_TYPE == 2 && !item.no_display
        helpdisplay_set(item, item.display_wait)
      end
    end
    
    invoke_final_attack_process(target, final_skill)
    
    if $lnx_include && $lnx_include[:lnx11a]
      if LNX11::BATTLELOG_TYPE == 2
        wait(item.end_wait) 
        helpdisplay_clear
      end
      wait_for_effect
    end
  end
  #--------------------------------------------------------------------------
  # ● 最終反撃の処理(追加定義)
  #--------------------------------------------------------------------------
  def invoke_final_attack_process(target, final_skill)
    attack_skill = $data_skills[final_skill]
    attack_skill.effects.each {|effect| @subject.item_global_effect_apply(effect) }
    @log_window.display_final_counter(target, attack_skill)
    
    target.force_action(final_skill, -2)
    targets = target.current_action.make_targets.compact
    
    show_animation(targets, attack_skill.animation_id)
    targets.each {|target2| attack_skill.repeats.times { invoke_final_item(target2, attack_skill, target) } }
    
    refresh_status
    @log_window.display_final_end(target)
  end
  #--------------------------------------------------------------------------
  # ● 最終スキル／アイテムの発動(追加定義)
  #--------------------------------------------------------------------------
  def invoke_final_item(target, item, user)
    last_subject = @subject
    @subject = user
    if rand < target.multi_cnt_rate(user, item.hit_type, 0)
      invoke_counter_attack(target, item)
    elsif rand < target.item_mrf(user, item)
      invoke_magic_reflection(target, item)
    else
      apply_final_item_effects(apply_substitute(target, item), item, user)
    end
    @subject = last_subject
    @subject.last_target_index = target.index
  end
  #--------------------------------------------------------------------------
  # ● 最終スキル／アイテムの効果を適用(追加定義)
  #--------------------------------------------------------------------------
  def apply_final_item_effects(target, item, user)
    user.result.counter = true
    
    if target.battler_add_ability(55) > rand(100)
      apply_counter_break(target, item, user)
      return
    end
    
    target.item_apply(user, item)
    refresh_status
    @log_window.display_action_results(target, item)
  end
  #--------------------------------------------------------------------------
  # ● 最終スキル／アイテムの効果を適用(追加定義)
  #--------------------------------------------------------------------------
  def apply_counter_break(target, item, user)
    refresh_status
    @log_window.display_counter_break(target, item)
  end
  #--------------------------------------------------------------------------
  # ● トラップの発動(追加定義)
  #--------------------------------------------------------------------------
  def invoke_trap_process(target, item)
    return if KURE::BaseScript::C_TRAP_PROCESS == 0
    return if item.ignore_trap
    return unless target.opposite?(@subject)
    return unless target.trap_list
    return if target.trap_list == []
    
    #全トラップを順次判定
    target.trap_list.each_with_index {|data, index|
      next unless data
      next if data[2] <= 0
      data[2] -= 1
      next if rand(100) > data[4]
      trapper = data[0]
      next unless trapper
      case data[5]
      when "P"
        next unless item.physical?
      when "M"
        next unless item.magical?
      when "C"
        next unless item.certain?
      end
      
      @log_window.clear if index == 0
      trap_skill = $data_skills[data[1]]
      trap_skill.effects.each {|effect| @subject.item_global_effect_apply(effect) }
      @log_window.display_trap(target, trap_skill)
      show_counter_animation([@subject], target, trap_skill)
      @subject.item_apply(trapper, trap_skill)
      
      refresh_status
      @log_window.display_action_results(@subject, trap_skill)
    }
    @log_window.wait_and_clear
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの発動後処理(追加定義)
  #--------------------------------------------------------------------------
  def used_item_cost(item)    
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの発動後ステート付与処理(追加定義)
  #--------------------------------------------------------------------------
  def after_add_state_process(item)
    return if item.after_add_state == []
    item.after_add_state.each do |id|
      @subject.add_state(id)
      @subject.result.sp_added_state_objects.push($data_states[id]).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンド［パーティー編成］
  #--------------------------------------------------------------------------
  def command_partyedit
    SceneManager.call(Scene_PartyEdit)
    BattleManager.reset
    $k_form_pe_call = 1
  end
  #--------------------------------------------------------------------------
  # ● コマンド［装備変更］
  #--------------------------------------------------------------------------
  def command_exequip
    SceneManager.call(Scene_Equip)
    BattleManager.reset
    $k_form_pe_call = 1
  end
end

#==============================================================================
# ▲ BattleManager(追加定義)
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # ● ターン開始時へリセット(追加定義)
  #--------------------------------------------------------------------------
  def self.reset
    @phase = :init
    @actor_index = -1
  end
  #--------------------------------------------------------------------------
  # ● 経験値の獲得とレベルアップの表示(追加定義)
  #--------------------------------------------------------------------------
  def self.gain_ex_exp
    equip = 0 ; ap = 0 ; status = 0
    job = $game_troop.jobexp_total if $kure_base_script[:JobLvSystem]
    equip = $game_troop.equip_exp_total if $kure_base_script[:SortOut]
    ap = $game_troop.ability_exp_total
    status = $game_troop.status_exp_total
    skill = $game_troop.skill_exp_total
    
    $game_party.all_members.each do |actor|
      actor.gain_ex_exp(equip, ap, status, skill)
      actor.gain_job_exp(job, job, true) if $kure_base_script[:JobLvSystem]
      actor.refresh
    end
    wait_for_message
  end
end