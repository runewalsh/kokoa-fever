#==============================================================================
#  ■併用化ベーススクリプトＡ for RGSS3 Ver3.10-β2
#　□作成者 kure
#　　
#　併用化対応スクリプト
#　●装備拡張
#　■スキルメモライズシステム
#　★スキルポイントシステム
#　▲職業レベル
#　◆転職画面
#　◎拡張ステータス画面
#　☆拡張機能集積
#　◇装備品個別管理
#　§ステータス振り分け
#　
#==============================================================================

#==============================================================================
# ■ Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # ▲ レベルの描画(再定義)
  #--------------------------------------------------------------------------
  alias k_before_draw_actor_level draw_actor_level
  def draw_actor_level(actor, x, y)
    k_before_draw_actor_level(actor, x, y)
    if KURE::BaseScript::USE_JOBLv == 1
      if actor.max_joblevel != 1
        draw_text(x + 58, y, 10, line_height, "/", 2)
        draw_text(x + 68, y, 24, line_height, actor.joblevel, 2)
      end
      if actor.sub_class_id != 0
        draw_text(x + 92, y, 10, line_height, "/", 2)
        draw_text(x + 100, y, 24, line_height, actor.sub_class_level, 2)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ●■★▲◆ 職業の描画
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y, width = 130)
    change_color(normal_color)
    if KURE::BaseScript::USE_JOBLv == 1 && actor.sub_class_id != 0
      draw_text(x, y, 60, line_height, actor.class.short_class_name,1)
      draw_text(x + 60, y, 10, line_height, "/",1)
      draw_text(x + 70, y, 60, line_height, actor.sub_class.short_class_name,1)
    else
      draw_text(x, y, width, line_height, actor.class.name)
    end
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
  #--------------------------------------------------------------------------
  # ◎ 経験値情報の描画
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    s2 = @actor.max_joblevel? ? "-------" : @actor.next_joblevel_exp - @actor.jobexp if KURE::BaseScript::USE_JobChange == 1 && KURE::BaseScript::USE_JOBLv == 1
    s_next = "След."
    change_color(system_color)
    if KURE::BaseScript::USE_JOBLv == 1
      draw_text(x, y , 60, line_height, s_next)
      change_color(tp_gauge_color2)
      draw_text(x + 40, y , 40, line_height, "Base")
      change_color(normal_color)
      draw_text(x + 80, y , 65, line_height, s1, 2)
      draw_text(x + 145, y , 10, line_height, "/", 2)
      change_color(mp_gauge_color2)
      draw_text(x + 155, y , 30, line_height, "Job")
      change_color(normal_color)
      draw_text(x + 185, y , 60, line_height, s2, 2)
    else
      draw_text(x + 100, y , 65, line_height, s_next)
      change_color(normal_color)
      draw_text(x + 140, y , 85, line_height, s1, 2)
    end
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
    #メモライズ適用時の処理(戦闘中は常に適用)
    if KURE::BaseScript::USE_Skill_Memorize == 1
      if $game_party.in_battle
        @data = @actor ? @actor.skills.select {|skill| include?(skill) && view_skill_b?(skill) && (@actor.memory_skills.include?(skill) or @actor.extra_skills.include?(skill) or @actor.unselect_skill?(skill.id))} : []
      elsif KURE::SkillMemorize::ADOPT_MEMORIZE == 0
        @data = @actor ? @actor.skills.select {|skill| include?(skill) && view_skill_f?(skill) && (@actor.memory_skills.include?(skill) or @actor.extra_skills.include?(skill) or @actor.unselect_skill?(skill.id))} : []
      else
        @data = @actor ? @actor.skills.select {|skill| include?(skill) && view_skill_f?(skill) } : []
      end
    else
      if $game_party.in_battle
        @data = @actor ? @actor.skills.select {|skill| include?(skill) && view_skill_b?(skill) } : []
      else
        @data = @actor ? @actor.skills.select {|skill| include?(skill) && view_skill_f?(skill) } : []
      end
    end
  end
  #--------------------------------------------------------------------------
  # ■ スキルを表示するかどうか(バトル)
  #--------------------------------------------------------------------------
  def view_skill_b?(item)
    item && (item.view_skill_mode == 2 or item.view_skill_mode == 3)
  end
  #--------------------------------------------------------------------------
  # ■ スキルを表示するかどうか(フィールド)
  #--------------------------------------------------------------------------
  def view_skill_f?(item)
    item && (item.view_skill_mode == 3 or item.view_skill_mode == 1)
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
    if target.alive?
      fmt = Vocab::NOEFFECT
      add_text(sprintf(fmt, target.name))
      wait
    end
  end  
  #--------------------------------------------------------------------------
  # ☆ ダメージの表示(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_display_damage display_damage
  def display_damage(target, item)
    return if target.result.defense
    return if target.result.invalidate
    k_before_display_damage(target, item)
  end
  #--------------------------------------------------------------------------
  # ☆ スティールの表示
  #--------------------------------------------------------------------------
  def display_steal(target, item)
    if target.enemy?
      if target.result.use_steal
        
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
          
          if KURE::BaseScript::C_DRAW_STEAL_ITEM_ICON == 1
            icon = '\I[' + target.result.steal.icon_index.to_s + ']'
          end
          
          color = '\C[' + KURE::BaseScript::C_DRAW_STEAL_ITEM_COLOR.to_s + ']'
          
          add_text(sprintf(fmt, target.name, icon + color + target.result.steal.name + '\C[0]'))
        else
          fmt = Vocab::EnemyNOSteal
          add_text(sprintf(fmt, target.name))
        end
        target.result.success = true
        wait
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 自爆スキルのメッセージの表示
  #--------------------------------------------------------------------------
  def display_paylife_message(user, item)
    if item.is_a?(RPG::Skill) && item.life_cost
      if user.battler_add_ability(34) == 0
        fmt = Vocab::PayLife
        add_text(sprintf(fmt, user.name))
      else
        fmt = Vocab::Stand
        add_text(sprintf(fmt, user.name))
      end
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ☆ オートリザレクションのメッセージの表示
  #--------------------------------------------------------------------------
  def display_autorevive_message(battler)
    return if battler.hp != 0
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
    for list in 0..battler.result.broken.size - 1
      fmt = Vocab::BreakEquip
      add_text(sprintf(fmt, battler.name, battler.result.broken[list]))
    end
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
end

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ☆拡張混乱状態の取得(追加定義)
  #--------------------------------------------------------------------------
  def adv_confusion?
    adv_c = states.collect {|state| state.adv_confusion }
    return true if adv_c[0]
    return false
  end
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
  attr_accessor :actor_add_cheack     #発動チェッカー
  #--------------------------------------------------------------------------
  # ☆ 追加定数（使用効果）
  #--------------------------------------------------------------------------
  EFFECT_STEAL            = 45                 #盗むスキル
  EFFECT_SKILL_RESET      = 46                 #スキルポイントリセット
  EFFECT_BREAK_EQUIP      = 47                 #装備破壊
  EFFECT_GET_ITEM         = 48                 #アイテム獲得
  #--------------------------------------------------------------------------
  # ☆ チェック配列の初期化(追加定義)
  #--------------------------------------------------------------------------
  def clear_cheackers  
    @actor_add_counter = [] #カウント変数の初期化
    @actor_add_delay = [] #ディレイ変数の初期化
    @actor_add_cheack = [] #発動チェッカー変数の初期化
    @skill_delay = [] #スキルディレイ配列の作成
    
    @battle_add_status = [] #戦闘中追加ステータス割合配列
    @substitute_list = [] #身代わり対象リスト
  end
  #--------------------------------------------------------------------------
  # ☆ マルチ反撃率計算(追加定義)
  #--------------------------------------------------------------------------
  def multi_cnt_rate(user, hit_type)
    return 0 unless opposite?(user)# 味方には反撃しない
    
    #命中タイプごとに判定
    case hit_type
    #必中攻撃
    when 0
      return battler_add_ability(28)
    when 1
      return cnt
    #魔法攻撃
    when 2
      return battler_add_ability(29)
    end    
  end
  #--------------------------------------------------------------------------
  # ☆ 拡張マルチ反撃率計算(追加定義)
  #--------------------------------------------------------------------------
  def adv_multi_cnt_rate(user, hit_type)
    return 0 unless opposite?(user)# 味方には反撃しない
    
    #命中タイプごとに判定
    case hit_type
    #必中攻撃
    when 0
      return battler_add_ability(42)
    when 1
      return battler_add_ability(40)
    #魔法攻撃
    when 2
      return battler_add_ability(41)
    end    
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
    heel = battler_add_ability(18)
    self.hp += (self.mhp * heel[0]).to_i if self.hp > 0
    self.mp += (self.mmp * heel[1]).to_i
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘中追加ステータス処理(追加定義)
  #--------------------------------------------------------------------------
  def set_b_add_status
    return unless $game_party.in_battle
    #HPトリガーブロック
    read_1 = battler_add_ability(23)
    read_2 = battler_add_ability(25)
    @battle_add_status = [] unless @battle_add_status
    
    #戦闘中ステータスを強化する。
    for param in 2..7
      @battle_add_status[param] = 0 unless @battle_add_status[param]
      
      #オーバーソウル適用
      @battle_add_status[param] = read_1 * $game_party.dead_members.size
      
      #ピンチ強化適用
      if read_2[0] > (self.hp * 100 / self.mhp)
        @battle_add_status[param] += read_2[1]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘中追加ステート処理(追加定義)
  #--------------------------------------------------------------------------
  def set_b_add_state
    return unless $game_party.in_battle
    #ステート発動
    read_3 = battler_add_ability(33)
    for state in 0..read_3.size - 1
      if read_3[state] && read_3[state][0] && read_3[state][1] && read_3[state][2] && read_3[state][3]
        
        #トリガーによって処理を分岐
        case read_3[state][0]
        when 1 #HP
          case read_3[state][1]
          when 0
            if read_3[state][2] > self.hp * 100 / self.mhp
              add_state(read_3[state][3]) unless state?(read_3[state][3])
            end
          when 1
            if read_3[state][2] <= self.hp * 100 / self.mhp
              add_state(read_3[state][3]) unless state?(read_3[state][3])
            end
          when 2
            if read_3[state][2] > self.hp * 100 / self.mhp
              remove_state(read_3[state][3]) if state?(read_3[state][3])
            end
          when 3
            if read_3[state][2] <= self.hp * 100 / self.mhp
              remove_state(read_3[state][3]) if state?(read_3[state][3])
            end
          end
        when 2 #MP
          case read_3[state][1]
          when 0
            if read_3[state][2] > self.mp * 100 / self.mmp
              add_state(read_3[state][3]) unless state?(read_3[state][3])
            end
          when 1
            if read_3[state][2] <= self.mp * 100 / self.mmp
              add_state(read_3[state][3]) unless state?(read_3[state][3])
            end
          when 2
            if read_3[state][2] > self.mp * 100 / self.mmp
              remove_state(read_3[state][3]) if state?(read_3[state][3])
            end
          when 3
            if read_3[state][2] <= self.mp * 100 / self.mmp
              remove_state(read_3[state][3]) if state?(read_3[state][3])
            end
          end
        when 3 #TP
          case read_3[state][1]
          when 0
            if read_3[state][2] > self.tp * 100 / self.max_tp
              add_state(read_3[state][3]) unless state?(read_3[state][3])
            end
          when 1
            if read_3[state][2] <= self.tp * 100 / self.max_tp
              add_state(read_3[state][3]) unless state?(read_3[state][3])
            end
          when 2
            if read_3[state][2] > self.tp * 100 / self.max_tp
              remove_state(read_3[state][3]) if state?(read_3[state][3])
            end
          when 3
            if read_3[state][2] <= self.tp * 100 / self.max_tp
              remove_state(read_3[state][3]) if state?(read_3[state][3])
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ バトラースキルディレイ配列の取得(追加定義)
  #--------------------------------------------------------------------------
  def make_skill_delay
    @skill_delay = [] #スキルディレイ配列の作成
  end
  #--------------------------------------------------------------------------
  # ☆ バトラースキルディレイ配列の取得(追加定義)
  #--------------------------------------------------------------------------
  def skill_delay_cheacker(skill)
    return true unless @skill_delay
    return true unless @skill_delay[skill.id]
    return true if @skill_delay[skill.id] == 0
    return false    
  end
  #--------------------------------------------------------------------------
  # ☆ バトラースキルディレイの追加(追加定義)
  #--------------------------------------------------------------------------
  def add_skill_delay(skill)
    @skill_delay = [] unless @skill_delay
    id = skill.id
    @skill_delay[id] = skill.skill_delay
  end
  #--------------------------------------------------------------------------
  # ☆ バトラー能力の上限回数の取得(追加定義)
  #--------------------------------------------------------------------------
  def add_cheacker
    @actor_add_counter = [] #カウント変数の初期化
    @actor_add_delay = [] #ディレイ変数の初期化
    
    for ability in 0..32
      case ability
      when 1
        @actor_add_counter[ability] = battler_add_ability(1)[2]
        @actor_add_delay[ability] = battler_add_ability(1)[3]
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
  # ☆ 発動ディレイの減少(追加定義)
  #--------------------------------------------------------------------------
  def delay_cutter
    #スキルディレイ
    for skill_id in 0..@skill_delay.size - 1
      if @skill_delay[skill_id]
        @skill_delay[skill_id] -= 1
        @skill_delay[skill_id] = 0 if @skill_delay[skill_id] < 0
      else
        @skill_delay[skill_id] = 0 
      end
    end
    
    #アクター能力ディレイ
    for list in 0..33
      @actor_add_delay[list] = 0 unless @actor_add_delay[list]
      case list
      when 1
        if self.hp == 0 
          @actor_add_delay[list] -= 1 if @actor_add_delay[list] != 0
          @actor_add_delay[list] = 0 if @actor_add_delay[list] < 0
        end
      when 32
        if @actor_add_delay[list] != 0
          for delay in 0..@actor_add_delay[list].size - 1
            if @actor_add_delay[list][delay]
              @actor_add_delay[list][delay][0] -= 1
              if @actor_add_delay[list][delay][0] < 0
                add_state(@actor_add_delay[list][delay][1])
                @actor_add_delay[list][delay] = nil
              end
            end
          end
        @actor_add_delay[list].compact!
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 発動チェッカーの初期化(追加定義)
  #--------------------------------------------------------------------------
  def reset_cheacker
    @actor_add_cheack = [] #発動チェッカー変数の初期化
    for ability in 0..32
      @actor_add_cheack[ability] = false
    end   
  end
  #--------------------------------------------------------------------------
  # ☆ ステート解除プロセス(追加定義)
  #--------------------------------------------------------------------------
  def remove_state_process(state_id)
    if state?(state_id)
      
      #カウンターとディレイの処理
      if @actor_add_counter && @actor_add_delay
        for ability in 0..32
          @actor_add_counter[ability] = 0 unless @actor_add_counter[ability]
          @actor_add_delay[ability] = 0 unless @actor_add_delay[ability]
          case ability
          when 1
            @actor_add_counter[ability] -= $data_states[state_id].battler_add_ability(1)[2]
            @actor_add_counter[ability] = 0 if @actor_add_counter[ability] < 0
            @actor_add_delay[ability] = self.battler_add_ability(1)[3]
          when 10
            @actor_add_counter[ability] -= $data_states[state_id].battler_add_ability(10)
            @actor_add_counter[ability] = 0 if @actor_add_counter[ability] < 0
          when 32
            if @actor_add_delay[ability] != 0
              remove = $data_states[state_id].battler_add_ability(32)
              for r_state in 0..remove.size - 1
                @actor_add_delay[ability].delete_if{|obj| obj[1] == remove[r_state][1]}
              end
            end
          end
        end
      end 
      
      #身代わり対象の処理
      if @substitute_list && @substitute_list != []
        for num in 0..@substitute_list.size - 1
          if @substitute_list[num][0] == state_id
            @substitute_list[num] = nil
          end
        end
        @substitute_list.compact!
      end
    end 
  end
  #--------------------------------------------------------------------------
  # ☆ オートステート発動(追加定義)
  #--------------------------------------------------------------------------
  def auto_state_adder
    auto_list = battler_add_ability(4)
    return if auto_list == []
    
    auto_list.each do |state|
        erase_state(state) if state != 0
      end
    
    auto_list.each do |state|
      if state
        unless state?(state)
          add_new_state(state)
          reset_state_counts(state)
        end
      end
    end 
  end
  #--------------------------------------------------------------------------
  # ☆ 常時オートステート発動(追加定義)
  #--------------------------------------------------------------------------
  def auto_state_adder_ex(item = nil)
    if item
      remove = item.battler_add_ability(43)
      remove.each do |state|
        erase_state(state) if state != 0
      end
    end
    auto_list = battler_add_ability(43)
    auto_list.each do |state|
      if state
        unless state?(state)
          add_new_state(state)
          reset_state_counts(state)
        end
      end
    end  
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［アイテムスティール(追加定義)
  #--------------------------------------------------------------------------
  def item_effect_steal(user, item, effect)
    if enemy?
      @result.use_steal = true
      if self.non_stealed?
        steal_list = self.steal_list[effect.data_id]
        #盗めるアイテムのリストがあれば処理
        if steal_list != nil 
          for list in 0..steal_list.size - 1
            if steal_list[list]
              #成功判定
              dice = steal_list[list][2]
              dice = (dice / user.battler_add_ability(0)).to_i if user.actor?
              
              if rand(dice) == 0 or dice == 0
                case steal_list[list][0]
                when 1
                  item = $data_items[steal_list[list][1]]
                when 2
                  item = $data_weapons[steal_list[list][1]]
                when 3
                  item = $data_armors[steal_list[list][1]]
                end
                $game_party.gain_item(item, 1)
                self.steal = true
                @result.steal = item
              end
            end
          end
        else
          @result.stealed = true
        end
      else
        @result.stealed = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［スキルポイントリセット](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_reset_skillpoint(user, item, effect)
    self.reset_skill_flag = true if actor?
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［装備破壊](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_break_equip(user, item, effect)
    if actor?
      #耐久値ダメージ
      if KURE::BaseScript::USE_SortOut == 1
        if (item.is_a?(RPG::Skill) or item.is_a?(RPG::Item)) && item.durable_damage != []
          for dam in 0..item.durable_damage.size - 1
            if item.durable_damage[dam][0] == 0
              select_list = weapons
            else
              select_list = armors.select{|obj| obj != nil && obj.etype_id == item.durable_damage[dam][0]}
            end
            
            for list in 0..select_list.size - 1
              if rand(100) < item.durable_damage[dam][2]
                unless select_list[list].broken?
                  before_name = select_list[list].name
                  
                  if item.durable_damage[dam][1] > 0
                    select_list[list].reduce_durable_value = (item.durable_damage[dam][1] * battler_add_ability(31)).to_i
                  else
                    select_list[list].reduce_durable_value =  item.durable_damage[dam][1]
                  end
                  
                  if select_list[list].broken?
                    @result.broken.push(before_name)
                    
                    #破損時の処理
                    for slot in 0..@equips.size - 1
                      if @equips[slot].object
                        if @equips[slot].object == select_list[list]
                          #破損時消滅設定
                          if KURE::SortOut::BROKEN_SETTING == 1
                            master_container = $game_party.item_master_container(select_list[list].class)
                            delete_item_id = select_list[list].identify_id
                            @equips[slot].object = nil 
                            master_container[delete_item_id] = nil
                          end
                          #破損時装備不可設定
                          if KURE::SortOut::BROKEN_CAN_EQUIP == 1
                            change_equip(slot, nil)
                          end
                          refresh
                        end
                      end
                    end
                    
                  end
                end
              end
            end
          end
        end
      end      
      
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［アイテム獲得](追加定義)
  #--------------------------------------------------------------------------
  def item_effect_get_item(user, item, effect)
    if user.actor?
      #リストを取得
      list = item.get_item_list
      for gain in 0..list.size - 1
        if gain % 2 == 0
          if list[gain] && list[gain + 1]
            $game_party.gain_item($data_items[list[gain]],list[gain + 1])
          end
        end
      end
    end
  end  
  #--------------------------------------------------------------------------
  # ☆ オートリザレクション判定(追加定義)
  #--------------------------------------------------------------------------
  def auto_revive
    read = battler_add_ability(1)
    return false if @actor_add_cheack[1] == true
    return false if @actor_add_delay[1] > 0
    return false if @actor_add_counter[1] < 1
    @actor_add_cheack[1] = true
    return false if read[1] < rand(100) #確率判定
    return 1 if read[0] > 1  
    return read[0] if read[0] != 0
    return false
  end
  #--------------------------------------------------------------------------
  # ☆　オートリザレクション(追加定義)
  #--------------------------------------------------------------------------
  def revive_life(rper)
    if self.hp != 0
      @actor_add_cheack[1] = false
      return
    end
    
    self.hp = (mhp * rper).to_i
    #オートリザレクションステートの解除
    states.each do |state|
      if state.battler_add_ability(1)[0] != 0
        erase_state(state.id)
      end
    end    
    @actor_add_counter[1] -= 1
  end
  #--------------------------------------------------------------------------
  # ☆ 踏みとどまりの判定(追加定義)
  #--------------------------------------------------------------------------
  def auto_stand
    read = battler_add_ability(2)
    return false if read == 0
    return true if self.hp >= mhp * read
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ 回復反転の判定(追加定義)
  #--------------------------------------------------------------------------
  def reverse_heel
    read = battler_add_ability(3)
    return false if read == 0
    return read
  end
  #--------------------------------------------------------------------------
  # ☆ メタルボディの判定(追加定義)
  #--------------------------------------------------------------------------
  def metal_body
    read = battler_add_ability(5)
    return false if read == 0
    return read
  end
  #--------------------------------------------------------------------------
  # ☆ 複数回発動の判定(追加定義)
  #--------------------------------------------------------------------------
  def multi_invoke(item)
    return 1 unless item.is_a?(RPG::Skill)
    type = item.stype_id
    return 1 unless type
    return 1 if type == 0
    return 1 unless battler_add_ability(6)[type]
    return battler_add_ability(6)[type]
  end
  #--------------------------------------------------------------------------
  # ☆ 即死反転の判定(追加定義)
  #--------------------------------------------------------------------------
  def reverse_deth
    read = battler_add_ability(7)
    return false if read == 0
    return read
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
    read = battler_add_ability(11)
    return false if read == 0
    return read
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
    f_invoke = battler_add_ability(16)
    f_invoke.sort_by{rand}
    return f_invoke[0] if f_invoke[0]
    return nil
  end
  #--------------------------------------------------------------------------
  # ☆ 追撃発動スキルIDの取得(追加定義)
  #--------------------------------------------------------------------------
  def chace_skill_id
    return 1
  end
  #--------------------------------------------------------------------------
  # ☆ 反撃強化率の判定(追加定義)
  #--------------------------------------------------------------------------
  def counter_gain
    return battler_add_ability(24)
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの消費 HP 計算(追加定義)
  #--------------------------------------------------------------------------
  def skill_hp_cost(skill)
    cost = skill.hp_cost
    case cost[1]
    when 0
      return (cost[0] * thpr(skill) * hpr).to_i
    when 1
      return (self.hp * cost[0] / 100 * thpr(skill) * hpr).to_i
    when 2
      return (mhp * cost[0] / 100 * thpr(skill) * hpr).to_i
    end  
  end
  #--------------------------------------------------------------------------
  # ☆　自爆スキル(追加定義)
  #--------------------------------------------------------------------------
  def pay_life(item)
    if item.is_a?(RPG::Skill)
      if item.life_cost
        if battler_add_ability(34) == 0
          self.hp = 0
          perform_collapse_effect
        else
          self.hp = 1
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 属性ブースターの取得(追加定義)
  #--------------------------------------------------------------------------
  def elements_booster_rate(user, element_id)
    #属性ブースターの配列取得
    booster = user.multi_boost(0)
    result = 1
    result = (100 + booster[element_id]).to_f / 100 if booster[element_id]
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ 属性吸収の取得(追加定義)
  #--------------------------------------------------------------------------
  def elements_drain_rate(element_id)
    #属性吸収の配列取得
    drain = multi_boost(1)
    result = 0
    result = drain[element_id].to_f / 100 if drain[element_id]
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージ増加補正の取得(追加定義)
  #--------------------------------------------------------------------------
  def gain_damage_rate(user, item)
    
    skill_type = item.stype_id if item.is_skill?
    gain_rate = 1
    
    #仲間思い補正
    companion_boost = 1 + $game_party.dead_members.size * (item.companion_revise.to_f / 100)
    gain_rate *= companion_boost
    
    #仲間想い補正2
    companion_boost2 = 1 + $game_party.dead_members.size * user.battler_add_ability(8)
    gain_rate *= companion_boost2
    
    #仲間想い補正3
    companion_boost3 = 1 - $game_party.dead_members.size * user.battler_add_ability(9)
    gain_rate *= companion_boost3
    gain_rate = 0 if gain_rate < 0
    
    #装備補正
    weapon_id_list = user.weapons.collect{|obj| obj.wtype_id}
    wd_rate_list = item.weapon_d_rate
    wepon_gain_list = user.battler_add_ability(14)
    equip_booster = 0
    
    if weapon_id_list != []
      for list in 0..weapon_id_list.size - 1
        #装備ブースター
        boost_id = weapon_id_list[list]
        
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
        if item.is_skill?
          if wepon_gain_list[boost_id]
            equip_booster += wepon_gain_list[boost_id][skill_type] if wepon_gain_list[boost_id][skill_type]
          end
        end
        
      end
    else
      #通常攻撃強化
      equip_booster += user.multi_boost(5)[0] if user.multi_boost(5)[0]
      
      #武器スキル倍率強化
      if item.is_skill?
        if wepon_gain_list[0]
          equip_booster += wepon_gain_list[0][skill_type] if wepon_gain_list[0][skill_type]
        end
      end
    end
    gain_rate *= 1 + (equip_booster.to_f / 100)
    
    #スキルタイプブースター
    skilltype_booster = 0
    if item.is_skill?
      skilltype_booster += user.multi_boost(10)[skill_type] if user.multi_boost(10)[skill_type]
    end
    gain_rate *= 1 + (skilltype_booster.to_f / 100)
    
    return gain_rate
  end
  #--------------------------------------------------------------------------
  # ☆ ブースター配列を取得(追加定義)
  #--------------------------------------------------------------------------
  def multi_boost(boost_id)
    booster = Array.new
    
    #ブースター配列を作成
    if actor?
      actor = call_job_cache(2, boost_id)
      equip = call_equip_cache(2, boost_id)
      passive = passive_skills.collect{|obj| obj.multi_booster(boost_id)}
      sta = states.collect{|obj| obj.multi_booster(boost_id)}
      booster += actor + equip + passive + sta
    end
    if enemy?
      enemy_e = $data_enemies[@enemy_id].multi_booster(boost_id)
      sta_e = states.collect{|obj| obj.multi_booster(boost_id)}
      booster += enemy_e + sta_e      
    end
      booster.compact!
      booster.flatten!
    
    result = Array.new
    if booster != []
      for list in 0..booster.size - 1
        if list % 2 == 0
          if booster[list] && booster[list + 1]
              result[booster[list]] = 0 unless result[booster[list]]
              result[booster[list]] += booster[list + 1]
          end  
        end
      end
    end  
    
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ バトラーー追加能力判定(追加定義)
  #--------------------------------------------------------------------------
  def battler_add_ability(add_ability_id)
    all_list = Array.new

    if actor?
      actor = call_job_cache(1, add_ability_id)
      equip = call_equip_cache(1, add_ability_id)
      passive = passive_skills.collect{|obj| obj.battler_add_ability(add_ability_id)}
      sta = states.collect{|obj| obj.battler_add_ability(add_ability_id)}
      all_list += actor + equip + passive + sta
    end
    
    if enemy?
      enemy_e = [$data_enemies[@enemy_id].battler_add_ability(add_ability_id)]
      sta_e = states.collect{|obj| obj.battler_add_ability(add_ability_id)}
      all_list += enemy_e + sta_e
    end
      all_list.flatten!
    
    case add_ability_id
    when 0,3,8,9,23,24
      value = all_list.max.to_f / 100
    when 1
      sum_1 = [] ; sum_2 = [] ; sum_3 = [] ; sum_4 = []
      for list in 0..all_list.size - 1
        if list % 4 == 0
          if all_list[list] && all_list[list + 1] && all_list[list + 2] && all_list[list + 3]
            sum_1.push(all_list[list]) 
            sum_2.push(all_list[list + 1])
            sum_3.push(all_list[list + 2])
            sum_4.push(all_list[list + 3])
          end
        end
      end
      value = [sum_1.max.to_f / 100, sum_2.max, sum_3.max, sum_4.max]
    when 2,12,22,26,27,31
      all_list.delete(0)
      if all_list != []
        value = all_list.min.to_f / 100
      else
        value = 0
      end
    when 4,16,17,30,43
      all_list.delete(0)
      all_list.uniq!
      value = all_list
    when 5,7,11,34,35,36
      value = all_list.max
    when 6
      value = Array.new
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            value[all_list[list]] = 0 unless value[all_list[list]]
            value[all_list[list]] = [value[all_list[list]],all_list[list + 1]].max
          end
        end
      end
    when 10
      value = all_list.inject(0){|sum, i| sum + i}
    when 28,29,40,41,42
      sum_all = all_list.inject(0){|sum, i| sum + i}
      value = sum_all.to_f / 100
    when 13
      value = Array.new
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            value[all_list[list]] = [] unless value[all_list[list]]
            value[all_list[list]].push(all_list[list + 1])
          end
        end
      end
    when 14
      value = Array.new
      for list in 0..all_list.size - 1
        if list % 3 == 0
          if all_list[list] && all_list[list + 1] && all_list[list + 2]
            value[all_list[list]] = [] unless value[all_list[list]]
            value[all_list[list]][all_list[list + 1]] = 0 unless value[all_list[list]][all_list[list + 1]]
            value[all_list[list]][all_list[list + 1]] += all_list[list + 2]
          end
        end
      end
    when 15,32
      value = Array.new
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            value.push([all_list[list], all_list[list + 1]])
          end
        end
      end
    when 18
      sum_1 = [] ; sum_2 = []
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            sum_1.push(all_list[list]) 
            sum_2.push(all_list[list + 1])
          end
        end
      end
      value = [sum_1.max.to_f / 100, sum_2.max.to_f / 100]
    when 19,20,21
      value = Array.new
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            value[all_list[list]] = 1 unless value[all_list[list]]
            value[all_list[list]] *= (all_list[list + 1].to_f / 100) 
          end
        end
      end
    when 25
      value = [0,0]
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            if all_list[list + 1] > value[1]
              value[0] = all_list[list]
              value[1] = all_list[list + 1]
            end
          end
        end
      end
      value[1] = value[1].to_f / 100
    when 33
      value = Array.new
      for list in 0..all_list.size - 1
        if list % 4 == 0
          if all_list[list] && all_list[list + 1] && all_list[list + 2] && all_list[list + 3]
            value.push([all_list[list],all_list[list + 1],all_list[list + 2],all_list[list + 3]])
          end
        end
      end
    when 37,38,39
      value = Array.new
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            value.push([all_list[list],all_list[list + 1]])
          end
        end
      end
    when 44
      value = [0,100]
      for list in 0..all_list.size - 1
        if list % 2 == 0
          if all_list[list] && all_list[list + 1]
            value[0] += all_list[list]
            value[1] += all_list[list + 1]
          end
        end
      end
    end
    
    return value
  end
  #--------------------------------------------------------------------------
  # ☆ 反撃強化の適用
  #--------------------------------------------------------------------------
  def apply_counter_gain(user, damage, item)
    user.actor_add_cheack[24] = false
    return damage if item.damage.recover?
    return damage * (1 + user.counter_gain)
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
      if state.battler_add_ability(2) != 0
        remove_state(state.id)
      end
    end
    
    return [damage, self.hp - 1].min
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージゴールド変換の適用
  #--------------------------------------------------------------------------
  def apply_goldconvert(damage, item)
    return damage if battler_add_ability(27) == 0
    return damage if item.damage.recover?
    
    #ゴールド減少
    reduce = (damage * battler_add_ability(27)).to_i
    
    block = damage
    if reduce > $game_party.gold
      block = ($game_party.gold / battler_add_ability(27)).to_i
    end
    
    $game_party.lose_gold(reduce)
    @result.gold_convert = true if block > 0
    
    return (damage - block).to_i
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージMP変換の適用
  #--------------------------------------------------------------------------
  def apply_mpconvert(damage, item)
    return damage if battler_add_ability(26) == 0
    return damage if item.damage.recover?
    
    #MP減少
    reduce = (damage * battler_add_ability(26)).to_i
    
    block = damage
    if reduce > self.mp
      block = (self.mp / battler_add_ability(26)).to_i
    end
    
    self.mp = [0, self.mp - reduce].max
    @result.mp_convert = true if block > 0
    
    return (damage - block).to_i
  end
  #--------------------------------------------------------------------------
  # ☆ ダメージMP吸収、ゴールド回収の適用
  #--------------------------------------------------------------------------
  def apply_add_drain(damage, item)
    #MP吸収
    if battler_add_ability(35) != 0
      gain = (damage * battler_add_ability(35).to_f / 100).to_i
      self.mp = [self.mmp, self.mp + gain].min
      @result.mp_convert_drain = gain if gain > 0
    end
    #ゴールド回収  
    if battler_add_ability(36) != 0
      gain = (damage * battler_add_ability(36).to_f / 100).to_i
      $game_party.gain_gold(gain)
      @result.gold_convert_drain = gain if gain > 0
    end
  end
  #--------------------------------------------------------------------------
  # ☆ メタルボディの適用
  #--------------------------------------------------------------------------
  def apply_metalbody(damage, item)
    return damage unless self.metal_body
    return damage if item.damage.recover?
    return damage if damage <= self.metal_body
    return 1 + rand(self.metal_body)
  end
  #--------------------------------------------------------------------------
  # ☆ 回復反転の適用
  #--------------------------------------------------------------------------
  def apply_reverse_heel(damage, item)
    return damage unless self.reverse_heel
    return damage if item.ignore_reverse_heel
    return damage if damage > 0
      damage = -1 *(damage * self.reverse_heel).to_i
    return damage
  end
  #--------------------------------------------------------------------------
  # ☆ 防御壁の適用
  #--------------------------------------------------------------------------
  def apply_defense_wall(damage, item)
    return damage unless self.defense_wall
    return damage if item.damage.recover?
    return damage if damage <= 0
    @actor_add_counter[10] -= 1 if @actor_add_counter[10]
    @actor_add_counter[10] = 0 unless @actor_add_counter[10]
    @actor_add_counter[10] = 0 if @actor_add_counter[10] < 0
    
    @result.defense = true

    if @actor_add_counter[10] == 0
      states.each do |state|
        if state.battler_add_ability(10) != 0
          remove_state(state.id)
        end
      end
    end
    
    return 0 
  end
  #--------------------------------------------------------------------------
  # ☆ 無効化障壁の適用
  #--------------------------------------------------------------------------
  def apply_invalidate_wall(damage, item)
    return damage unless self.invalidate_wall
    return damage if item.damage.recover?
    return damage if damage <= 0
    return damage if damage > self.invalidate_wall
    
    @result.invalidate = true
    return 0
  end
  #--------------------------------------------------------------------------
  # ☆ アイテム使用可能ステート判定(追加定義)
  #--------------------------------------------------------------------------
  def item_usable_state?
    states.each do |state|
      return false if state.can_not_use_item
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ☆ 身代わりユニットを取得
  #--------------------------------------------------------------------------
  def substitute_unit
    arr = Array.new
    if @substitute_list
      @substitute_list.each do |list|
        arr.push(list[1])
      end
      arr.sort_by{rand}
    end
    return arr
  end
end

#==============================================================================
# ■ Game_Actor(再定義項目集積)
#==============================================================================
class Game_Actor < Game_Battler
  attr_reader   :joblevel                    # 職業レベル
  attr_reader   :sub_class_level             # サブクラスレベル
  attr_reader   :sub_class_id                # サブクラス ID
  #--------------------------------------------------------------------------
  # ●■★▲◆☆◇§ 追加機能の初期化１(追加定義)
  #--------------------------------------------------------------------------
  def clear_add_object_before
    @used_skill_point = []        #スキルポイントシステム
    @battle_skill_point = []      #スキルポイントシステム
    
    @joblevel = 1                 #職業レベル
    @jobexp = {}                  #職業レベル
    
    @sub_class_id = 0             #サブクラス
    @sub_class_level = 1          #サブクラス
    
    @ability_point = []           #アビリティポイント保存配列
    
    @status_point = 0             #ステータスポイント
    @status_divide = []           #ステータス振り分け保存配列
    @divide_counter = []          #ステータス振り分け回数保存配列
    @last_level = 0               #最終レベルアップ処理保存配列
    
    @battle_add_status = []       #戦闘中限定強化ステータス
    
    @passive_cache = []           #パッシブスキルキャッシュ
    @passive_cache_data = []      #パッシブスキルキャッシュ
    @equip_cache = []             #装備キャッシュ
    @equip_ability_cache = []     #装備能力キャッシュ
    @job_cache = []               #職業キャッシュ
    @job_ability_cache = []       #職業能力キャッシュ
    @state_cache = []             #ステートキャッシュ
    @state_cache_data = []        #ステートキャッシュ
        
    clear_master_object
    clear_cheackers
    
  end
  #--------------------------------------------------------------------------
  # ●■★▲◆☆◇§ 追加機能の初期化２(追加定義)
  #--------------------------------------------------------------------------
  def clear_add_object_after
    #初期スキルの習得
    for class_id in 0..@classlevel_list.size - 1
      if @classlevel_list[class_id] 
        if KURE::BaseScript::USE_JobChange == 0
          learn_set_skill_lv(class_id, @classlevel_list[class_id])
        else
          if KURE::JobChange::DELETE_SKILL_MODE == 0
            learn_set_skill_lv(class_id, @classlevel_list[class_id])
          end
        end
      end
    end
    
    #TP初期化
    init_tp
    add_cheacker
    reset_cheacker
    auto_state_adder
    auto_state_adder_ex if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
  end
  #--------------------------------------------------------------------------
  # ◇ マスターオブジェクトの初期化(追加定義)
  #--------------------------------------------------------------------------
  def clear_master_object
    return unless @equips
    return if KURE::BaseScript::USE_SortOut == 0
    equip_list = equips
    master_w_list = $game_party.master_weapons_list
    master_a_list = $game_party.master_armors_list
    
    return unless master_w_list
    return unless master_a_list
    
    for slot in 0..equip_list.size - 1
      if equip_list[slot]
        if equip_list[slot].class == RPG::Weapon
          master_w_list[equip_list[slot].identify_id] = nil
        end
        if equip_list[slot].class == RPG::Armor
          master_a_list[equip_list[slot].identify_id] = nil
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 職業経験値の初期化(追加定義)
  #--------------------------------------------------------------------------
  def init_jobexp
    @classlevel_list = []
    @classlevel_list[@class_id] = @joblevel
    @jobexp[@class_id] = current_joblevel_exp
  end
  #--------------------------------------------------------------------------
  # ●▲ アクター経験済み職業初期設定(追加定義)
  #--------------------------------------------------------------------------
  def init_actor_exp
    exp_list = $data_actors[@actor_id].exp_jobchange_class
    for i in 0..exp_list.size - 1
      if i % 2 == 0
        if KURE::BaseScript::USE_JOBLv == 1
          @jobexp[exp_list[i]] = jobexp_for_level(exp_list[i+1])
        else
          @exp[exp_list[i]] = exp_for_level(exp_list[i+1])
        end
        @classlevel_list[exp_list[i]] = exp_list[i+1]
      end
    end
    @level = @classlevel_list[@class_id] if KURE::BaseScript::USE_JOBLv == 0
    @joblevel = @classlevel_list[@class_id] if KURE::BaseScript::USE_JOBLv == 1
  end
  #--------------------------------------------------------------------------
  # ▲ サブクラス経験値の初期化(追加定義)
  #--------------------------------------------------------------------------
  def init_sub_class_exp
    @sub_class_id = actor.first_sub_class
    @sub_class_level = @classlevel_list[@sub_class_id] if @classlevel_list[@sub_class_id]
    if @sub_class_id != 0
      @classlevel_list[@sub_class_id] = @sub_class_level
      @jobexp[@sub_class_id] = current_sub_class_level_exp
    end
  end
  #--------------------------------------------------------------------------
  # ▲ サブクラスオブジェクト取得(追加定義)
  #--------------------------------------------------------------------------
  def sub_class
    $data_classes[@sub_class_id]
  end
  #--------------------------------------------------------------------------
  # ▲ 現在の職業レベルの最低経験値を取得(追加定義)
  #--------------------------------------------------------------------------
  def current_joblevel_exp
    jobexp_for_level(@joblevel)
  end
  #--------------------------------------------------------------------------
  # ▲ 現在のサブクラスレベルの最低経験値を取得(追加定義)
  #--------------------------------------------------------------------------
  def current_sub_class_level_exp
    sub_class_exp_for_level(@sub_class_level)
  end
  #--------------------------------------------------------------------------
  # ▲ 指定職業レベルに上がるのに必要な累計経験値の取得(追加定義)
  #--------------------------------------------------------------------------
  def jobexp_for_level(level)
    self.class.exp_for_level(level)
  end
  #--------------------------------------------------------------------------
  # ▲ 指定サブクラスレベルに上がるのに必要な累計経験値の取得(追加定義)
  #--------------------------------------------------------------------------
  def sub_class_exp_for_level(level)
    $data_classes[@sub_class_id].exp_for_level(level)
  end
  #--------------------------------------------------------------------------
  # ▲ クラスごとのレベルリストの呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def class_level_list
    @sub_class_id = 0 if @sub_class_id == nil
    @classlevel_list = [] if @classlevel_list == nil
    add_level = @level
    add_level = @joblevel if KURE::BaseScript::USE_JOBLv == 1
    @classlevel_list[@class_id] = add_level
    if @sub_class_id != 0
      add_level = @sub_class_level if KURE::BaseScript::USE_JOBLv == 1
      @classlevel_list[@sub_class_id] = add_level if KURE::BaseScript::USE_JOBLv == 1
    end
    return @classlevel_list
  end
  #--------------------------------------------------------------------------
  # ■ 習得スキルオブジェクトの配列取得(追加定義)
  #--------------------------------------------------------------------------
  def learned_skill_list
    @sub_class_skills = [] if @sub_class_skills == nil
    return (@skills | @sub_class_skills ).sort.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # ■★ 現在使用可能かどうかを判定する(追加定義)
  #--------------------------------------------------------------------------
  def usable_now?(skill)
    return true if KURE::BaseScript::USE_Skill_Memorize == 0
    #メモライズ時の判定
    return true if @memory_skills.include?(skill.id)
    return true if @extra_skills.include?(skill.id)
    return true if unselect_skill?(skill.id)
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ パッシブスキル条件を判定する(追加定義)
  #--------------------------------------------------------------------------
  def passive_condition?(skill)
    #メモライズ判定
    if KURE::BaseScript::USE_Skill_Memorize == 1
      if memory_skills.include?(skill) or extra_skills.include?(skill) or unselect_skill?(skill.id)
      else
        return false
      end
    end
    
    #条件判定処理(条件に当てはまらなければフラグON)
    flag = 0
    for id in 0..1
      case id
      #発動要求武器
      when 0
        need_weapon = skill.passive_condition_list(id)
        if need_weapon != []
          actor_weapon = weapons
          #素手
          if actor_weapon == []
            flag += 1 if need_weapon.include?(0)
          end
          #武器タイプが存在するかチェック
          for list in 0..actor_weapon.size - 1
            if actor_weapon[list]
              flag += 1 if need_weapon.include?(actor_weapon[list].wtype_id)
            end
          end
        else
          flag += 1
        end
      #発動要求装備
      when 1
        need_armor = skill.passive_condition_list(id)
        if need_armor != []
          actor_armor = armors
          #防具タイプが存在するかチェック
          for list in 0..actor_armor.size - 1
            if actor_armor[list]
              flag += 1 if need_armor.include?(actor_armor[list].etype_id)
            end
          end
        else
          flag += 1
        end
      end
    end
    
    
    return true if flag == 2
    return false
  end
  #--------------------------------------------------------------------------
  # ■ 登録不要のスキル判定(追加定義)
  #--------------------------------------------------------------------------
  def unselect_skill?(skill_id)
    return unless skill_id != nil or skill_id == 0
    skilldata = $data_skills[skill_id].note
    if skilldata.include?("<メモライズ不要>")
      return true
    else
      skilldata.each_line { |line|
      memo = line.scan(/<メモライズ不要\s?(\d+)>/)
      memo = memo.flatten
      if memo != nil and not memo.empty?
        return true if memo[0].to_i == id
      end
      }
      return false
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルオブジェクトの配列のセット(追加定義)
  #--------------------------------------------------------------------------
  def set_passive_skills
    
    #パッシブスキル関連定数初期化
    @passive_cache = [] unless @passive_cache
    @state_cache = [] unless @state_cache
    @passive_cache_data = [] unless @passive_cache_data
    @state_cache_data = [] unless @state_cache_data
    @passive_skills = [] unless @passive_skills    
    
    #パッシブスキル配列が変化していなければ処理しない
    setting_skills = skills.select{|skill| passive_condition?(skill)}
    
    return if @passive_cache == setting_skills && @state_cache == states
    @passive_skills = []
    
    #パッシブスキル処理ブロック
    if @passive_cache != setting_skills
      @passive_cache_data = []
      setting_skills.each do |skill|
        if usable_now?(skill)
          #武器のオブジェクトを出力
          if skill.passive_skill_id_w != []
            skill.passive_skill_id_w.each do |weapon|
              @passive_cache_data.push($data_weapons[weapon])
            end
          end
          #防具のオブジェクトを出力
          if skill.passive_skill_id_a != []
            skill.passive_skill_id_a.each do |armor|
              @passive_cache_data.push($data_armors[armor])
            end
          end
          #職業のオブジェクトを出力
          if skill.passive_skill_id_c != []
            skill.passive_skill_id_c.each do |job|
              @passive_cache_data.push($data_classes[job])
            end
          end
        end  
        
      end
    end
      
    #ステート関連処理ブロック
    if @state_cache != states
      @state_cache_data = []
      states.each do |state|
        #武器のオブジェクトを出力
        if state.passive_skill_id_w != []
          state.passive_skill_id_w.each do |weapon|
            @state_cache_data.push($data_weapons[weapon])
          end
        end
        #防具のオブジェクトを出力
        if state.passive_skill_id_a != []
          state.passive_skill_id_a.each do |armor|
            @state_cache_data.push($data_armors[armor])
          end
        end
        #職業のオブジェクトを出力
        if state.passive_skill_id_c != []
          state.passive_skill_id_c.each do |job|
            @state_cache_data.push($data_classes[job])
          end
        end        
      end
    end
    
    @passive_skills = @state_cache_data + @passive_cache_data
    
    release_unequippable_items
    @passive_cache = setting_skills.clone
    @state_cache = states.clone
  end
  #--------------------------------------------------------------------------
  # ■★ パッシブスキルオブジェクトの配列のセット(追加定義)
  #--------------------------------------------------------------------------
  def passive_skills
    @passive_skills = [] unless @passive_skills
    @passive_skills
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの配列のセット(追加定義)
  #--------------------------------------------------------------------------
  def ability_point
    @ability_point = [] unless @ability_point
    @ability_point
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
    @status_divide = [] unless @status_divide
    @status_divide[param_id] = 0 unless @status_divide[param_id]
    @divide_counter = [] unless @divide_counter
    @divide_counter[param_id] = 0 unless @divide_counter[param_id]
      
    return if value < 0 and @divide_counter[param_id] <= 0
    
    @status_divide[param_id] += value
    @status_divide[param_id] = 0 if @status_divide[param_id] < 0
    
    if value > 0
      @divide_counter[param_id] += 1
    else
      @divide_counter[param_id] -= 1
      @divide_counter[param_id] = 0 if @divide_counter[param_id] < 0
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
    @status_point = 0 unless @status_point
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
    @status_point = 0 unless @status_point
    @status_point -= value
    @status_point = 0 if @status_point < 0
  end
  #--------------------------------------------------------------------------
  # § ステータスポイントの追加（追加定義）
  #--------------------------------------------------------------------------
  def add_status_point(value)
    @status_point = 0 unless @status_point
    @status_point += value
  end
  #--------------------------------------------------------------------------
  # 〒スキルポイント用の取得（追加定義）
  #--------------------------------------------------------------------------
  def call_battle_sp(class_id)
    return 0 unless @battle_skill_point[class_id]
    return @battle_skill_point[class_id]
  end
  #--------------------------------------------------------------------------
  # 〒 スキルポイントの追加（追加定義）
  #--------------------------------------------------------------------------
  def add_skill_point(value)
    @battle_skill_point = [] unless @battle_skill_point
    @battle_skill_point[@class_id] = 0 unless @battle_skill_point[@class_id]
    @battle_skill_point[@class_id] += value
  end
  #--------------------------------------------------------------------------
  # ▲★ 指定IDの指定Lvまでの職業スキルを習得(追加処理)
  #--------------------------------------------------------------------------
  def learn_set_skill_lv(job_id, job_lv)
    return unless job_id
    return if job_lv == 0
    select_job = $data_classes[job_id]
    
    for learn_lv in 1..job_lv
    #スキルポイントシステムを利用している場合、初期スキルを制限する
      select_job.learnings.each do |learning|
        if KURE::BaseScript::USE_Skill_Point == 1
          if learning.note.include?("<固有スキル>")
            learn_skill(learning.skill_id) if learning.level == learn_lv
          end
        else
          learn_skill(learning.skill_id) if learning.level == learn_lv
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲★ 職業レベルアップ(追加定義)
  #--------------------------------------------------------------------------
  def joblevel_up
    @joblevel += 1
    #スキルポイントシステムを利用している場合、初期スキルを制限する
    self.class.learnings.each do |learning|
      if KURE::BaseScript::USE_Skill_Point == 1
        if learning.note.include?("<固有スキル>")
          learn_skill(learning.skill_id) if learning.level == @joblevel
        end
      else
        learn_skill(learning.skill_id) if learning.level == @joblevel
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲★ サブクラスレベルアップ(追加定義)
  #--------------------------------------------------------------------------
  def sub_class_level_up
    #サブクラス設定時
    if @sub_class_id != 0
      @sub_class_level += 1
      $data_classes[@sub_class_id].learnings.each do |learning|
        if KURE::BaseScript::USE_Skill_Point == 1
          if learning.note.include?("<固有スキル>")
            learn_skill_sub(learning.skill_id) if learning.level == @sub_class_level
          end
        else
          learn_skill_sub(learning.skill_id) if learning.level == @sub_class_level
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 職業レベルダウン(追加定義)
  #--------------------------------------------------------------------------
  def joblevel_down
    @joblevel -= 1
  end
  #--------------------------------------------------------------------------
  # ▲ サブクラスレベルダウン(追加定義)
  #--------------------------------------------------------------------------
  def sub_class_level_down
    @sub_class_level -= 1
  end
  #--------------------------------------------------------------------------
  # ▲ 職業経験値の取得(追加定義)
  #--------------------------------------------------------------------------
  def jobexp
    return 0 if @jobexp[@class_id] == nil
    return @jobexp[@class_id]
  end
  #--------------------------------------------------------------------------
  # ▲ サブクラス経験値の取得(追加定義)
  #--------------------------------------------------------------------------
  def sub_class_exp
    return 0 if @jobexp[@sub_class_id] == nil
    return @jobexp[@sub_class_id]
  end
  #--------------------------------------------------------------------------
  # ☆ アビリティポイントの配列のセット
  #--------------------------------------------------------------------------
  def gain_ability_point(a_exp)
    return if a_exp == 0
    @ability_point = [] unless @ability_point
    get_list = Array.new
    
    if KURE::BaseScript::USE_SortOut == 0
      weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| $data_weapons[obj.id].get_ability_point}
      armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| $data_armors[obj.id].get_ability_point}
      slot = []
    else
      weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| obj.object.get_ability_point}
      armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| obj.object.get_ability_point}
      slot_list = @equips.select{|obj| obj != nil}.collect{|obj| obj.slot_list}.flatten!
      slot = slot_list.collect{|obj| obj.get_ability_point}
    end
    
    
    get_list += weapon + armor + slot
    get_list.flatten!
    get_list.compact!
    
    return if get_list == ([] or empty?)
    for ap in 0..get_list.size - 1
      if ap % 2 == 0 && get_list[ap + 1]
        if KURE::BaseScript::USE_JOBLv == 1
          #アビリティポイントを獲得
          unless skill_learn?($data_skills[get_list[ap]]) or skill_learn_sub?($data_skills[get_list[ap]])
            point = a_exp * get_list[ap + 1]
          
            @ability_point[get_list[ap]] += point if @ability_point[get_list[ap]]
            @ability_point[get_list[ap]] = point unless @ability_point[get_list[ap]]
     
            #スキル習得判定
            if @ability_point[get_list[ap]] >= $data_skills[get_list[ap]].need_ability_point
              learn_skill(get_list[ap])
              learn_skill_sub(get_list[ap])
              @ability_point[get_list[ap]] = 0
            end
          end
        else
          #アビリティポイントを獲得
          unless skill_learn?($data_skills[get_list[ap]])
            point = a_exp * get_list[ap + 1]
          
            @ability_point[get_list[ap]] += point if @ability_point[get_list[ap]]
            @ability_point[get_list[ap]] = point unless @ability_point[get_list[ap]]
     
            #スキル習得判定
            if @ability_point[get_list[ap]] >= $data_skills[get_list[ap]].need_ability_point
              learn_skill(get_list[ap])
              @ability_point[get_list[ap]] = 0
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲★◆ サブクラスの変更(追加定義)
  #     keep_exp : 経験値を引き継ぐ
  #--------------------------------------------------------------------------
  def change_sub_class(sub_class_id, keep_exp = true)
    #転職前に習得スキルを保存する
    @save_class_skills[@sub_class_id] = [] unless @save_class_skills[@sub_class_id]
    @save_class_skills[@sub_class_id] = @sub_class_skills.clone
    
    #共有スキルを保存しておく
    common_list = Array.new
    for i in 0..@sub_class_skills.size - 1
      if $data_skills[@sub_class_skills[i]].note.include?("<共有スキル>")
        common_list.push(@sub_class_skills[i])
      end
    end
    
    #転職処理
    @exp[class_id] = exp if keep_exp
    @sub_class_id = sub_class_id
    change_exp(@exp[@class_id] || 0, false, self.jobexp, self.sub_class_exp)
    
    #スキル削除モード時の処理
    if KURE::BaseScript::USE_JOBLv == 1
      if KURE::JobChange::DELETE_SKILL_MODE == 0
        if @save_class_skills[@sub_class_id]
          add_skills = @save_class_skills[@sub_class_id].clone
          @sub_class_skills = [] unless @sub_class_skills
          @sub_class_skills += add_skills
          @sub_class_skills.uniq!
        end
      end
      if KURE::JobChange::DELETE_SKILL_MODE == 1
        
        @sub_class_skills = @save_class_skills[@sub_class_id]
        @sub_class_skills = [] unless @sub_class_skills
        @memory_skills = []       #スキルメモライズシステム
        @extra_skills = []        #スキルメモライズシステム
      
        for j in 0..common_list.size - 1
          learn_skill_sub(common_list[j]) if KURE::BaseScript::USE_Skill_Point == 0
        end
      end
    end
    
    #職業レベルを併用している場合は職業レベルを設定
    if KURE::BaseScript::USE_JOBLv == 1
      change_exp(self.exp, false, self.jobexp, @jobexp[@sub_class_id] || 0) if @sub_class_id != 0
    end
          
    #サブクラス設定時は初期Lvで覚えるスキルを処理
    if KURE::BaseScript::USE_JOBLv == 1
      if @sub_class_id != 0
        $data_classes[@sub_class_id].learnings.each do |learning|
          if KURE::BaseScript::USE_Skill_Point == 1
            if learning.note.include?("<固有スキル>")
              learn_skill_sub(learning.skill_id) if learning.level <= @sub_class_level
            end
          else
            learn_skill_sub(learning.skill_id) if learning.level <= @sub_class_level
          end
        end
      end
    end
        
    #クラスレベルリストを更新する
    @classlevel_list[@sub_class_id] = @sub_class_level if @sub_class_id != 0
    
    #パッシブスキルを更新する
    set_passive_skills
    
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 記憶容量増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_memorize
    gain_memorize = 0
      for i in 0..@equips.size - 1
        #オブジェクトが存在している場合
        if @equips[i].object
          gain_memorize += @equips[i].object.gain_memorize
        end
      end
    return gain_memorize    
  end
  #--------------------------------------------------------------------------
  # ● 記憶数増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_max_memorize
    gain_max_memorize = 0
      for i in 0..@equips.size - 1
        #オブジェクトが存在している場合
        if @equips[i].object
          gain_max_memorize += @equips[i].object.gain_max_memorize
        end
      end
    return gain_max_memorize    
  end
  #--------------------------------------------------------------------------
  # ☆ TP増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_tp
    return 1
  end
  #--------------------------------------------------------------------------
  # ☆ TP％増加量(追加定義)
  #--------------------------------------------------------------------------  
  def all_gain_tp_per
  
    return 1   
  end
  #--------------------------------------------------------------------------
  # ☆ パーティ追加能力判定(追加定義)
  #--------------------------------------------------------------------------
  def party_add_ability(add_ability_id)
    all_list = Array.new

    actor = call_job_cache(3, add_ability_id)
    equip = call_equip_cache(3, add_ability_id)
    passive = passive_skills.collect{|obj| obj.party_add_ability(add_ability_id)}
    sta = states.collect{|obj| obj.party_add_ability(add_ability_id)}
    all_list += actor + equip + passive + sta
    all_list.flatten!
    
    case add_ability_id
    when 0,1,3,4,5
      value = all_list.max.to_f / 100
    when 2
      value = all_list.inject(1) {|result, item| result * (item.to_f / 100) }
      value.round(1)
    end
    return value
  end
  #--------------------------------------------------------------------------
  # ☆ 装備品オブジェクトのID配列取得(追加定義)
  #--------------------------------------------------------------------------
  def equips_ids
    @equips.collect {|item| item.object ? item.object.id : 0  }
  end
  #--------------------------------------------------------------------------
  # ☆ アクタ―、職業能力呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def call_job_cache(kind, add_ability_id)  
    #初期化
    @job_cache = [] unless @job_cache
    @job_ability_cache = [] unless @job_ability_cache
    @job_ability_cache[1] = [] unless @job_ability_cache[1]
    @job_ability_cache[2] = [] unless @job_ability_cache[2]
    @job_ability_cache[3] = [] unless @job_ability_cache[3]
    
    case kind
    #装備能力
    when 1
      #キャッシュと同一であれば保存配列を返す
      if @job_cache[1] == [@actor_id, @class_id, @sub_class_id]
        #保存配列があれば値を返す
        return @job_ability_cache[1][add_ability_id] if @job_ability_cache[1][add_ability_id]
        
        #保存配列が無ければ作成
        unless @job_ability_cache[1][add_ability_id]
          actor = [$data_actors[@actor_id].battler_add_ability(add_ability_id)]
          job = [$data_classes[@class_id].battler_add_ability(add_ability_id)]
          list = actor + job
          if @sub_class_id != 0
            sub = [$data_classes[@sub_class_id].battler_add_ability(add_ability_id)]
            list += sub
          end
          @job_ability_cache[1][add_ability_id] = list.clone
          return @job_ability_cache[1][add_ability_id]
        end
      else
        #キャッシュが無ければ新たに作成
        @job_ability_cache[1] = []
        actor = [$data_actors[@actor_id].battler_add_ability(add_ability_id)]
        job = [$data_classes[@class_id].battler_add_ability(add_ability_id)]
        list = actor + job
        if @sub_class_id != 0
          sub = [$data_classes[@sub_class_id].battler_add_ability(add_ability_id)]
          list += sub
        end
        @job_ability_cache[1][add_ability_id] = list.clone
          
        #キャッシュに現在の職業構成を個保存する
        @job_cache[1] = [@actor_id, @class_id, @sub_class_id].clone
        return @job_ability_cache[1][add_ability_id]
      end
    #ブースト
    when 2
      #キャッシュと同一であれば保存配列を返す
      if @job_cache[2] == [@actor_id, @class_id, @sub_class_id]
        #保存配列があれば値を返す
        return @job_ability_cache[2][add_ability_id] if @job_ability_cache[2][add_ability_id]
        
        #保存配列が無ければ作成
        unless @job_ability_cache[2][add_ability_id]
          actor = [$data_actors[@actor_id].multi_booster(add_ability_id)]
          job = [$data_classes[@class_id].multi_booster(add_ability_id)]
          list = actor + job
          if @sub_class_id != 0
            sub = [$data_classes[@sub_class_id].multi_booster(add_ability_id)]
            list += sub
          end
          @job_ability_cache[2][add_ability_id] = list.clone
          return @job_ability_cache[2][add_ability_id]
        end
      else
        #キャッシュが無ければ新たに作成
        @job_ability_cache[2] = []
        actor = [$data_actors[@actor_id].multi_booster(add_ability_id)]
        job = [$data_classes[@class_id].multi_booster(add_ability_id)]
        list = actor + job
        if @sub_class_id != 0
          sub = [$data_classes[@sub_class_id].multi_booster(add_ability_id)]
          list += sub
        end
        @job_ability_cache[2][add_ability_id] = list.clone
          
        #キャッシュに現在の職業構成を個保存する
        @job_cache[2] = [@actor_id, @class_id, @sub_class_id].clone
        return @job_ability_cache[2][add_ability_id]
      end
    #パーティー能力
    when 3
      #キャッシュと同一であれば保存配列を返す
      if @job_cache[3] == [@actor_id, @class_id, @sub_class_id]
        #保存配列があれば値を返す
        return @job_ability_cache[3][add_ability_id] if @job_ability_cache[3][add_ability_id]
        
        #保存配列が無ければ作成
        unless @job_ability_cache[3][add_ability_id]
          actor = [$data_actors[@actor_id].party_add_ability(add_ability_id)]
          job = [$data_classes[@class_id].party_add_ability(add_ability_id)]
          list = actor + job
          if @sub_class_id != 0
            sub = [$data_classes[@sub_class_id].party_add_ability(add_ability_id)]
            list += sub
          end
          @job_ability_cache[3][add_ability_id] = list.clone
          return @job_ability_cache[3][add_ability_id]
        end
      else
        #キャッシュが無ければ新たに作成
        @job_ability_cache[3] = []
        actor = [$data_actors[@actor_id].party_add_ability(add_ability_id)]
        job = [$data_classes[@class_id].party_add_ability(add_ability_id)]
        list = actor + job
        if @sub_class_id != 0
          sub = [$data_classes[@sub_class_id].party_add_ability(add_ability_id)]
          list += sub
        end
        @job_ability_cache[3][add_ability_id] = list.clone
          
        #キャッシュに現在の職業構成を個保存する
        @job_cache[3] = [@actor_id, @class_id, @sub_class_id].clone
        return @job_ability_cache[3][add_ability_id]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 装備品能力呼び出し(追加定義)
  #--------------------------------------------------------------------------
  def call_equip_cache(kind, add_ability_id)
    #初期化
    @equip_cache = [] unless @equip_cache       
    @equip_ability_cache = [] unless @equip_ability_cache
    @equip_ability_cache[1] = [] unless @equip_ability_cache[1]
    @equip_ability_cache[2] = [] unless @equip_ability_cache[2]
    @equip_ability_cache[3] = [] unless @equip_ability_cache[3]
   
    case kind
    #装備能力
    when 1
      #キャッシュと同一であれば保存配列を返す
      if @equip_cache[1] == equips_ids
        #保存配列があれば値を返す
        return @equip_ability_cache[1][add_ability_id] if @equip_ability_cache[1][add_ability_id]
        
        #保存配列が無ければ作成
        unless @equip_ability_cache[1][add_ability_id]
          weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| obj.object.battler_add_ability(add_ability_id)}
          armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| obj.object.battler_add_ability(add_ability_id)}
          list = weapon + armor
          @equip_ability_cache[1][add_ability_id] = list.clone
          return @equip_ability_cache[1][add_ability_id]
        end
      else
        #キャッシュが無ければ新たに作成
        @equip_ability_cache[1] = []
        weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| obj.object.battler_add_ability(add_ability_id)}
        armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| obj.object.battler_add_ability(add_ability_id)}
        list = weapon + armor
        @equip_ability_cache[1][add_ability_id] = list.clone
      
        #キャッシュに現在の装備をコピーする
        @equip_cache[1] = equips_ids.clone
        return @equip_ability_cache[1][add_ability_id]
      end
    #ブースト
    when 2
      #キャッシュと同一であれば保存配列を返す
      if @equip_cache[2] == equips_ids
        #保存配列があれば値を返す
        if @equip_ability_cache[2][add_ability_id]
          return @equip_ability_cache[2][add_ability_id]
        end
        
        #保存配列が無ければ作成
        unless @equip_ability_cache[2][add_ability_id]
          weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| obj.object.multi_booster(add_ability_id)}
          armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| obj.object.multi_booster(add_ability_id)}
          list = weapon + armor
          @equip_ability_cache[2][add_ability_id] = list.clone
          return @equip_ability_cache[2][add_ability_id]
        end
      else
        #キャッシュが無ければ新たに作成
        @equip_ability_cache[2] = []
        weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| obj.object.multi_booster(add_ability_id)}
        armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| obj.object.multi_booster(add_ability_id)}
        list = weapon + armor
        @equip_ability_cache[2][add_ability_id] = list.clone
      
        #キャッシュに現在の装備をコピーする
        @equip_cache[2] = equips_ids.clone
        return @equip_ability_cache[2][add_ability_id]
      end
    #パーティー能力  
    when 3
      #キャッシュと同一であれば保存配列を返す
      if @equip_cache[3] == equips_ids
        #保存配列があれば値を返す
        if @equip_ability_cache[3][add_ability_id]
          return @equip_ability_cache[3][add_ability_id]
        end
        
        #保存配列が無ければ作成
        unless @equip_ability_cache[3][add_ability_id]
          weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| obj.object.party_add_ability(add_ability_id)}
          armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| obj.object.party_add_ability(add_ability_id)}
          list = weapon + armor
          @equip_ability_cache[3][add_ability_id] = list.clone
          return @equip_ability_cache[3][add_ability_id]
        end
      else
        #キャッシュが無ければ新たに作成
        @equip_ability_cache[3] = []
        weapon = @equips.select{|obj| obj != nil && obj.is_weapon?}.collect{|obj| obj.object.party_add_ability(add_ability_id)}
        armor = @equips.select{|obj| obj != nil && obj.is_armor?}.collect{|obj| obj.object.party_add_ability(add_ability_id)}
        list = weapon + armor
        @equip_ability_cache[3][add_ability_id] = list.clone
      
        #キャッシュに現在の装備をコピーする
        @equip_cache[3] = equips_ids.clone
        return @equip_ability_cache[3][add_ability_id]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 追加属性配列を取得(追加定義)
  #--------------------------------------------------------------------------
  def reflect_elements
    reflect = Array.new
    result = Array.new
    
    weapon = @equips.select{|obj| obj != nil && obj.is_weapon? && $data_weapons[obj.id].reflect_elements}.collect{|obj| $data_weapons[obj.id].features}
    armor = @equips.select{|obj| obj != nil && obj.is_armor? && $data_armors[obj.id].reflect_elements}.collect{|obj| $data_armors[obj.id].features}
    reflect = weapon + armor
    return result if reflect == []
    
    for item in 0..reflect.size - 1
      if reflect[item]
        for ft in 0..reflect[item].size - 1
          result.push(reflect[item][ft]) if reflect[item][ft]
        end
      end
    end
    return result if result == []

    result = result.select {|ft| ft.code == 31}.inject([]) {|r, ft| r |= [ft.data_id] }
    return result
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの消費 金額 計算(追加定義)
  #--------------------------------------------------------------------------
  def skill_gold_cost(skill)
    skill.gold_cost
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの消費 アイテム配列の取得(追加定義)
  #--------------------------------------------------------------------------
  def skill_item_cost(skill)
    list = skill.item_cost
    item_cost = Array.new
    for obj in 0..list.size - 1
      if obj % 2 == 0
        item_cost.push([list[obj],list[obj + 1]]) if list[obj + 1]
      end
    end
    return item_cost
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの必要 アイテム配列の取得(追加定義)
  #--------------------------------------------------------------------------
  def skill_need_item(skill)
    skill.need_used_item
  end  
  #--------------------------------------------------------------------------
  # ☆ リセットフラグ(追加定義)
  #--------------------------------------------------------------------------
  def reset_skill_flag
    return true if @reset_skill_flag
    return false
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
    etype_id_need = skill.need_etype_id
    
    #要求判定
    if etype_id_need != []
      for need in 0..etype_id_need.size - 1
        if etype_id_need[need] > 0
          return false unless etype_equipped?(etype_id_need[need])
        end
      end
    end
    
    return true
  end
  #--------------------------------------------------------------------------
  # ○ 特定のタイプの防具を装備しているか(追加定義)
  #--------------------------------------------------------------------------
  def etype_equipped?(etype_id)
    equips.compact.any? {|equip| equip.etype_id == etype_id }
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
    all_members.each do |actor|
      actor.set_passive_skills
    end
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
  # ▲ 職業経験値の取得(追加定義)
  #--------------------------------------------------------------------------
  def jobexp
    enemy.jobexp
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
  # ☆ スティールの判定(追加定義)
  #--------------------------------------------------------------------------
  def non_stealed?
    return true unless @steal
    return false
  end
end
  
#==============================================================================
# ■ Game_Troop
#==============================================================================
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ▲ 職業経験値の合計計算(追加定義)
  #--------------------------------------------------------------------------
  def jobexp_total
    jobexp_total = dead_members.inject(0) {|r, enemy| r += enemy.jobexp }
    jobexp_rate = $game_party.party_add_ability(4)
    jobexp_total *= jobexp_rate.max
    if KURE::BaseScript::USE_PartyEdit == 1
      if KURE::PartyEdit::SHARE_EXP_MODE == 1
        max = $game_party.max_battle_members
        now = $game_party.battle_members_size
        ptm_rate = 1 + max.to_f / now 
        jobexp_total *= ptm_rate
      end
    end
    return jobexp_total.to_i
  end
  #--------------------------------------------------------------------------
  # ◇ 装備経験値の合計計算(追加定義)
  #--------------------------------------------------------------------------
  def equip_exp_total
    equip_exp_total = dead_members.inject(0) {|r, enemy| r += enemy.equip_exp }
    equip_exp_rate = $game_party.party_add_ability(5)
    equip_exp_total *= equip_exp_rate.max
    if KURE::BaseScript::USE_PartyEdit == 1
      if KURE::PartyEdit::SHARE_EXP_MODE == 1
        max = $game_party.max_battle_members
        now = $game_party.battle_members_size
        ptm_rate = 1 + max.to_f / now 
        equip_exp_total *= ptm_rate
      end
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
  #--------------------------------------------------------------------------
  # ☆ ランダムオブジェクト取得(追加定義)
  #--------------------------------------------------------------------------
  def random_item
    return @random_item if @ramdom_effect == 1
    return nil
  end
  #--------------------------------------------------------------------------
  # ☆ 行動変化オブジェクト取得(追加定義)
  #--------------------------------------------------------------------------
  def force_action_item
    return @force_action_item if @force_action_effect == 1
    return nil
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
    #踏みとどまり
    @auto_stand = false
    #即死反転
    @reverse_deth = false
    #防御壁
    @defense = false
    #無効化
    @invalidate = false
    #スキル変化
    @change_skill = false
    #破壊装備
    @broken = Array.new
    #MPダメージ変換
    @mp_convert = false
    #金額ダメージ変換
    @gold_convert = false
    #MPダメージ吸収
    @mp_convert_drain = false
    #金額ダメージ回収
    @gold_convert_drain = false
  end
end

#==============================================================================
# ■ Scene_Battle(再定義)
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 戦闘開始時スキル発動(追加定義)
  #--------------------------------------------------------------------------
  def first_invoke_items
    #アクションを作成
    $game_party.make_actions
    $game_troop.make_actions
    
    all_battle_members.each do |battler|
      if battler.alive? && battler.movable? && battler.battler_add_ability(37) != []
        skill_list = battler.battler_add_ability(37)
        skill_list.each do |skill|
          #発動率判定
          rate = rand(100)
          if skill[1] > rate
            #ウィンドウ表示
            @status_window.unselect
            @status_window.open
            
            #追撃発動
            @subject = battler
            attack_skill = $data_skills[skill[0]]
            @log_window.display_use_item(@subject, attack_skill)
            @subject.current_action.item = attack_skill
            targets = @subject.current_action.make_targets.compact

            #軽量化アニメーション
            anim_d = $data_animations[attack_skill.animation_id]
            if anim_d && anim_d.to_screen?
              show_normal_animation([targets[0]].compact, attack_skill.animation_id)
            else
              show_animation(targets, attack_skill.animation_id)
            end
        
            targets.each {|target| attack_skill.repeats.times { invoke_item(target, attack_skill) } }
            @log_window.wait_and_clear
            refresh_status
          end
        end
      end
    end
    
    #行動者初期化
    @subject =  nil    
  end
  #--------------------------------------------------------------------------
  # ● ターン間スキル発動(追加定義)
  #--------------------------------------------------------------------------
  def turn_invoke_items(turn)
    case turn
    when 1
      cheack = 38
    when 2
      cheack = 39
    end
    
    all_battle_members.each do |battler|
      if battler.alive? && battler.movable? && battler.battler_add_ability(cheack) != []
        skill_list = battler.battler_add_ability(cheack)
        skill_list.each do |skill|
          #発動率判定
          rate = rand(100)
          if skill[1] > rate
            #追撃発動
            @subject = battler
            attack_skill = $data_skills[skill[0]]
            @log_window.display_use_item(@subject, attack_skill)
            
            #アクションが存在しなければ作成
            @subject.make_actions unless @subject.current_action
            
            keep_skill = @subject.current_action.item
            @subject.current_action.item = attack_skill
            targets = @subject.current_action.make_targets.compact

            #軽量化アニメーション
            anim_d = $data_animations[attack_skill.animation_id]
            if anim_d && anim_d.to_screen?
              show_normal_animation([targets[0]].compact, attack_skill.animation_id)
            else
              show_animation(targets, attack_skill.animation_id)
            end
        
            targets.each {|target| attack_skill.repeats.times { invoke_item(target, attack_skill) } }
            @log_window.wait_and_clear
            
            @subject.current_action.item = keep_skill if keep_skill
            
            refresh_status
          end
        end
      end
    end    
    @subject = nil
    
  end
  #--------------------------------------------------------------------------
  # ● オートリザレクション実行(追加定義)
  #--------------------------------------------------------------------------
  def auto_revive_process(auto_revive_battler)
    auto_revive_battler.each do |battler_list|
      if battler_list[0].death_state?
        battler_list[0].revive_life(battler_list[1])
        show_animation([battler_list[0]], KURE::BaseScript::S_AUTO_REVIVE_ANIM_ID)
      end
      @log_window.display_autorevive_message(battler_list[0])
      refresh_status
      @log_window.wait_and_clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 追撃実行(追加定義)
  #--------------------------------------------------------------------------
  def chase_attack_process(chase_battler)
    chase_battler.each do |battler_list|
      e_list = $game_troop.members if battler_list[0].actor?
      e_list = $game_party.members if battler_list[0].enemy?
      if e_list
        e_list.each do |enemy|
          for id in 0..battler_list[1].size - 1
            if enemy.alive? && enemy.state?(battler_list[1][id])
              
              #追撃発動
              attack_skill = $data_skills[1]
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
    attack_skill = $data_skills[final_skill]
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
    if rand < target.multi_cnt_rate(user, item.hit_type)
      invoke_counter_attack(target, item)
    elsif rand < target.item_mrf(user, item)
      invoke_magic_reflection(target, item)
    else
      apply_final_item_effects(apply_substitute(target, item), item, user)
    end
    @subject.last_target_index = target.index
  end
  #--------------------------------------------------------------------------
  # ● 最終スキル／アイテムの効果を適用(追加定義)
  #--------------------------------------------------------------------------
  def apply_final_item_effects(target, item, user)
    user.actor_add_cheack[24] = true
    target.item_apply(user, item)
    refresh_status
    @log_window.display_action_results(target, item)
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの発動後処理(追加定義)
  #--------------------------------------------------------------------------
  def used_item_cost(item)
    #自爆スキル判定
    if item.is_a?(RPG::Skill) && item.life_cost
      @log_window.display_paylife_message(@subject, item)
      @subject.pay_life(item)
      refresh_status
      wait_for_effect
    end
    
    #ロストスキル実行
    if item.is_a?(RPG::Skill) && item.lost_skill?
      if @subject.skill_learn?(item)
        @log_window.display_lostskill_message(@subject, item)
        @subject.forget_skill(item.id)
        refresh_status
        @log_window.wait_and_clear
      end
    end
    
    #耐久値消費
    if KURE::BaseScript::USE_SortOut == 1
      if item.is_a?(RPG::Skill) && item.reduce_durable != []
        if @subject.actor?
          for red in 0..item.reduce_durable.size - 1
            if item.reduce_durable[red][0] == 0
              select_list = @subject.weapons
            else
              select_list = @subject.armors.select{|obj| obj != nil && obj.etype_id == item.reduce_durable[red][0]}
            end
            
            for list in 0..select_list.size - 1
              if rand(100) < item.reduce_durable[red][2]
                unless select_list[list].broken?
                  before_name = select_list[list].name
                  select_list[list].reduce_durable_value = (item.reduce_durable[red][1] * @subject.battler_add_ability(31)).to_i
                  if select_list[list].broken?
                    @log_window.display_breakequip_message(@subject, before_name)
                    @log_window.wait_and_clear
                    
                    #破損したアイテムの設定
                    for slot in 0..@subject.equips.size - 1
                      if @subject.equips[slot]
                        if @subject.equips[slot] == select_list[list]
                          #破損時消滅設定
                          if KURE::SortOut::BROKEN_SETTING == 1
                            master_container = $game_party.item_master_container(select_list[list].class)
                            delete_item_id = select_list[list].identify_id
                            @subject.equips[slot] = nil 
                            master_container[delete_item_id] = nil
                          end
                          #破損時装備不可設定
                          if KURE::SortOut::BROKEN_CAN_EQUIP == 1
                            @subject.change_equip(slot, nil)
                          end
                          @subject.refresh
                        end
                      end
                    end
                
                  end
                end
              end
            end
          end
        end
      end
    end
    
    
  end
end