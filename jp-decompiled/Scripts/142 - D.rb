#==============================================================================
#  ■併用化ベーススクリプトＤ for RGSS3 Ver3.10-β2
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
# ■ Window_ActorCommand
#==============================================================================
class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● アイテムコマンドをリストに追加(再定義)
  #--------------------------------------------------------------------------
  def add_item_command
    add_command(Vocab::item, :item, @actor.item_usable_state?)
  end
end

#==============================================================================
# ■ Window_SkillList
#==============================================================================
class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● スキルをリストに含めるかどうか(再定義)
  #--------------------------------------------------------------------------
  def include?(item)
    return false unless item
    return true if item.stype_id == @stype_id
    return true if item.add_skilltype_id.include?(@stype_id)
    return false 
  end  
end

#==============================================================================
# ■ Window_BattleSkill
#==============================================================================
class Window_BattleSkill < Window_SkillList
  #--------------------------------------------------------------------------
  # ● スキルを許可状態で表示するかどうか(再定義)
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor && @actor.usable?(item) && nodelay?(item)
  end
  #--------------------------------------------------------------------------
  # ● ディレイのあるスキルを選択済みかどうか(追加定義)
  #--------------------------------------------------------------------------
  def nodelay?(item)
    return false unless @actor
    return true if item.skill_delay == 0
    action = @actor.actions.collect{|obj| obj.item}
    return false if action.include?(item)
    return true
  end
end


#==============================================================================
# ■ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 反撃の表示(再定義)
  #--------------------------------------------------------------------------
  def display_counter(target, item)
    Sound.play_evasion
    if item.id == 1
      add_text(sprintf(Vocab::CounterAttack, target.name))
    else
      add_text(sprintf(Vocab::Ext_CounterAttack, target.name, item.name))
    end
    wait
  end
  #--------------------------------------------------------------------------
  # ● ステート付加の表示(再定義)
  #--------------------------------------------------------------------------
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      
      if state.id == target.death_state_id
        unless target.result.final_atk
          target.perform_collapse_effect 
          next if state_msg.empty?
          replace_text(target.name + state_msg)
          wait
          wait_for_effect
        end
      else
        next if state_msg.empty?
        replace_text(target.name + state_msg)
        wait
        wait_for_effect
      end
    end
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 攻撃追加回数の取得
  #--------------------------------------------------------------------------
  def atk_times_add
    [features_sum_all(FEATURE_ATK_TIMES), 0].max
  end  
  #--------------------------------------------------------------------------
  # ● アイテムの使用可能条件チェック(再定義)
  #--------------------------------------------------------------------------
  def item_conditions_met?(item)
    item_usable_state? && usable_item_conditions_met?(item) && $game_party.has_item?(item)
  end
  #--------------------------------------------------------------------------
  # ● 戦闘不能になる(再定義)
  #--------------------------------------------------------------------------
  def die
    @hp = 0
    #全ステートを検索し、残留対象のステート以外を解除する
    states.each do |state|
      unless state.not_delete_state
        if state.battler_add_ability(1)[0] == 0 && state.gain_drop_rate == 100
          remove_state_process(state.id)
          erase_state(state.id)
        end
      end
    end
    clear_buffs
  end
  #--------------------------------------------------------------------------
  # ○ 使用効果の適用(再定義)
  #--------------------------------------------------------------------------
  def item_effect_apply(user, item, effect)
    method_table = {
      EFFECT_RECOVER_HP    => :item_effect_recover_hp,
      EFFECT_RECOVER_MP    => :item_effect_recover_mp,
      EFFECT_GAIN_TP       => :item_effect_gain_tp,
      EFFECT_ADD_STATE     => :item_effect_add_state,
      EFFECT_REMOVE_STATE  => :item_effect_remove_state,
      EFFECT_ADD_BUFF      => :item_effect_add_buff,
      EFFECT_ADD_DEBUFF    => :item_effect_add_debuff,
      EFFECT_REMOVE_BUFF   => :item_effect_remove_buff,
      EFFECT_REMOVE_DEBUFF => :item_effect_remove_debuff,
      EFFECT_SPECIAL       => :item_effect_special,
      EFFECT_GROW          => :item_effect_grow,
      EFFECT_LEARN_SKILL   => :item_effect_learn_skill,
      EFFECT_COMMON_EVENT  => :item_effect_common_event,
      EFFECT_STEAL         => :item_effect_steal,
      EFFECT_SKILL_RESET   => :item_effect_reset_skillpoint,
      EFFECT_BREAK_EQUIP   => :item_effect_break_equip,
      EFFECT_GET_ITEM      => :item_effect_get_item,
    }
    method_name = method_table[effect.code]
    send(method_name, user, item, effect) if method_name
  end

  #--------------------------------------------------------------------------
  # ☆ 使用効果［ステート付加］：通常攻撃(再定義)
  #--------------------------------------------------------------------------
  def item_effect_add_state_attack(user, item, effect)
    user.atk_states.each do |state_id|
      chance = effect.value1
      chance *= state_rate(state_id)
      chance *= user.atk_states_rate(state_id)
      chance *= luk_effect_rate(user)
      
      if KURE::BaseScript::C_STATE_BOOSTER == 1
        chance *= state_per_booster(user, item, state_id)
        chance += state_val_booster(user, item, state_id)
      end
        
      if rand < chance
        if reverse_deth && state_id == death_state_id
          self.hp = mhp
          @result.reverse_deth = true
          @result.success = true
        else
          add_state(state_id)
          @result.success = true
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［ステート付加］：通常(再定義)
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    chance = effect.value1
    chance *= state_rate(effect.data_id) if opposite?(user)
    chance *= luk_effect_rate(user)      if opposite?(user)
    
    if KURE::BaseScript::C_STATE_BOOSTER == 1
      chance *= state_per_booster(user, item, effect.data_id)
      chance += state_val_booster(user, item, effect.data_id)
    end
    
    if rand < chance
      if reverse_deth && effect.data_id == death_state_id
        self.hp = mhp
        @result.reverse_deth = true
        @result.success = true
      else
        add_state(effect.data_id)
        if $data_states[effect.data_id].adv_substitute_t
          @substitute_list.push([effect.data_id,user]) if @substitute_list
        end
        @result.success = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの使用可能条件チェック(再定義)
  #--------------------------------------------------------------------------
  def skill_conditions_met?(skill)
    usable_item_conditions_met?(skill) &&
    skill_wtype_ok?(skill) && skill_cost_payable?(skill) &&
    !skill_sealed?(skill.id) && !skill_type_sealed?(skill)
  end
  #--------------------------------------------------------------------------
  # ☆ スキルタイプ封印の判定（再定義）
  #--------------------------------------------------------------------------
  def skill_type_sealed?(skill)
    if skill.is_a?(RPG::Skill)
      skill.add_skilltype_id.each{|stype_id|
        return false unless features_set(FEATURE_STYPE_SEAL).include?(stype_id)
      }
      return true if features_set(FEATURE_STYPE_SEAL).include?(skill.stype_id)
    else
      features_set(FEATURE_STYPE_SEAL).include?(skill)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ☆ スキル使用コストの支払い可能判定(再定義)
  #--------------------------------------------------------------------------
  def skill_cost_payable?(skill)
    return false if tp < skill_tp_cost(skill)
    return false if mp < skill_mp_cost(skill)
    return false if hp < skill_hp_cost(skill)
    
    if actor?
      return false if $game_party.gold < skill_gold_cost(skill)
    
      need_list = skill_need_item(skill)
      for n_list in 0..need_list.size - 1
        id = need_list[n_list]
        return false unless $game_party.has_item?($data_items[id])
      end
    
      item_cost = skill_item_cost(skill)
      for i_list in 0..item_cost.size - 1
        if item_cost[i_list]
          id = item_cost[i_list][0]
          num = item_cost[i_list][1]
          return false if $game_party.item_number($data_items[id]) < num
        end
      end
    end
    
    return false unless skill_delay_cheacker(skill)
  
    return true
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの消費 MP 計算(再定義)
  #--------------------------------------------------------------------------
  def skill_mp_cost(skill)
    cost = skill.mp_cost_ex
    #タイプ消費率
    case cost[1]
    when 0
      return (cost[0] * mcr * tmcr(skill)).to_i
    when 1
      return (self.mp * cost[0] / 100 * mcr * tmcr(skill)).to_i
    when 2
      return (mmp * cost[0] / 100 * mcr * tmcr(skill)).to_i
    end
  end
  #--------------------------------------------------------------------------
  # ☆ スキルの消費 TP 計算(再定義)
  #--------------------------------------------------------------------------
  def skill_tp_cost(skill)
    cost = skill.tp_cost_ex
    case cost[1]
    when 0
      return (cost[0] * tpr * ttpr(skill)).to_i
    when 1
      return (self.tp * cost[0] / 100 * tpr * ttpr(skill)).to_i
    when 2
      return (max_tp * cost[0] / 100 * tpr * ttpr(skill)).to_i
    end
  end
  #--------------------------------------------------------------------------
  # ☆ スキル／アイテムの属性修正値を取得(再定義)
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    #複数属性のリストを習得
    e_list = item.attack_elements_list
    
    #アクターであれば反映属性を取得
    e_list += user.reflect_elements if user.actor?
    
    if e_list == ([] or empty?)
      e_id = item.damage.element_id
      if e_id < 0
        result = user.atk_elements.empty? ? 1.0 : elements_max_rate(user, user.atk_elements)
      else
        result = element_rate(e_id) * elements_booster_rate(user, e_id)
        result -= elements_drain_rate(e_id)
      end
    else
      e_list.push(item.damage.element_id)
      result = elements_max_rate(user, e_list)
    end
    
    #アクターであればダメージ増加補正を取得
    result *= gain_damage_rate(user, item) if user.actor? 
    
    return result
  end

  #--------------------------------------------------------------------------
  # ☆ 属性の最大修正値の取得(再定義)
  #     elements : 属性 ID の配列
  #    与えられた属性の中で最も有効な修正値を返す
  #--------------------------------------------------------------------------
 alias jsscript_elements_max_rate elements_max_rate
  def elements_max_rate(user, elements)
    elements.inject([0.0]) {|r, i| r.push((element_rate(i) * elements_booster_rate(user, i)) - elements_drain_rate(i)) }.max
    
    result = 0.0
    elements.each {|i| result += element_rate(i)}
    return result / elements.size
  end

  
  #--------------------------------------------------------------------------
  # ☆ ダメージ計算(再定義)
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    
    value = apply_reverse_heel(value, item)
    
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_counter_gain(user, value, item) if user.actor_add_cheack[24]
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    
    value = apply_defense_wall(value, item)
    value = apply_invalidate_wall(value, item)
    value = apply_metalbody(value, item)
    value = apply_goldconvert(value, item)
    value = apply_mpconvert(value, item)
    value = apply_stand(value, item)
    apply_add_drain(value, item)
    @result.make_damage(value.to_i, item)
  end
end

#==============================================================================
# ■ Game_Actor(再定義項目集積)
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ■★▲ スキルの初期化(再定義)
  #--------------------------------------------------------------------------
  def init_skills
    @skills = []
    @sub_class_skills = []    #サブクラススキル
    @memory_skills = []       #スキルメモライズシステム
    @extra_skills = []        #スキルメモライズシステム
    @passive_skills = []      #パッシブスキル
    
    #スキルポイントシステム利用時には消費ポイントを初期化
    @used_skill_point = [] if KURE::BaseScript::USE_Skill_Point == 1
    @save_class_skills = []
    
    #職業レベルの併用化チェックにより初期スキル習得処理を分岐
    cheack_first_Lv = @level
    cheack_first_Lv = @joblevel if KURE::BaseScript::USE_JOBLv == 1
      
    #初期Lvで覚えるスキルを処理 
    self.class.learnings.each do |learning|
      #スキルポイントシステムを利用している場合、初期スキルを制限する
      if KURE::BaseScript::USE_Skill_Point == 1
        if learning.note.include?("<固有スキル>")
          learn_skill(learning.skill_id) if learning.level <= cheack_first_Lv
        end
      else
        learn_skill(learning.skill_id) if learning.level <= cheack_first_Lv
      end
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
      
    #職業レベルを導入している場合、Lv1固有スキルを処理する
    if KURE::BaseScript::USE_JOBLv == 1 
      if $data_actors[@actor_id].actor_peculiar_skill != []
        for i in 0..$data_actors[@actor_id].actor_peculiar_skill.size - 1
          if i % 2 == 0
            if @level >= $data_actors[@actor_id].actor_peculiar_skill[i]
              learn_skill($data_actors[@actor_id].actor_peculiar_skill[i + 1])
            end
          end
        end
      end
    end
    
    #初期登録スキルが有れば処理する
    if KURE::BaseScript::USE_Skill_Memorize == 1
      @memory_skills = [] if $data_actors[@actor_id].first_memorize.size != 0
      for i in 0..$data_actors[@actor_id].first_memorize.size - 1
        if $data_skills[$data_actors[@actor_id].first_memorize[i]]
          unless skill_memorize?($data_skills[$data_actors[@actor_id].first_memorize[i]]) 
            @memory_skills.push($data_actors[@actor_id].first_memorize[i])
          end
        end
      end
      chain_memorize_set
    end
    
    #パッシブスキルを更新する
    set_passive_skills
  end  
  #--------------------------------------------------------------------------
  # ■ スキルオブジェクトの配列取得(再定義)
  #--------------------------------------------------------------------------
  def skills
    @sub_class_skills = [] if @sub_class_skills == nil
    #スキルメモライズ時のスキルオブジェクト
    if KURE::BaseScript::USE_Skill_Memorize == 1
      (@skills | @sub_class_skills | added_skills | @extra_skills).sort.collect {|id| $data_skills[id] }
    #通常のスキルオブジェクト  
    else
      (@skills | @sub_class_skills | added_skills).sort.collect {|id| $data_skills[id] }
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 特徴を保持する全オブジェクトの配列取得(再定義)
  #--------------------------------------------------------------------------
  def feature_objects
    super + [actor] + [self.class] + equips.compact + passive_skills.compact
  end
  
  #--------------------------------------------------------------------------
  # ▲ 全ての特徴オブジェクトの配列取得(再定義)
  #--------------------------------------------------------------------------
 def all_features
    sub_class_features = []
    base_features = feature_objects.inject([]) {|r, obj| r + obj.features }
    
    #サブクラスの設定により取得配列を変更
    if @sub_class_id != 0 and KURE::JobLvSystem::SUB_CLASS_FEATURE == 1
      sub_class_features = $data_classes[@sub_class_id].features

      #適用外特徴を除外する。
      apply = $data_classes[@sub_class_id].not_applied_features
      for code in 0..apply.size - 1
        sub_class_features = sub_class_features.select {|ft| ft.code != apply[code]}
      end
      
      #適用外特徴データを除外する
      apply_data = $data_classes[@sub_class_id].not_applied_features_data
      for code in 0..apply_data.size - 1
        if code % 2 == 0
          if apply_data[code] && apply_data[code + 1]
            sub_class_features = sub_class_features.select {|ft| ft.code != apply_data[code] or ft.data_id != apply_data[code + 1]}
          end
        end
      end
    end
    
    return base_features + sub_class_features
  end

  #--------------------------------------------------------------------------
  # ▲☆ 通常能力値の基本値取得(再定義)
  #--------------------------------------------------------------------------
  def param_base(param_id)
    #基本能力値の取得
    base_class = $data_actors[@actor_id].base_param_index
    if base_class == 0
      class_base = self.class.params[param_id, @level]
    else
      class_base = $data_classes[base_class].params[param_id, @level]
    end
    
    sub_class_base = 0
    #サブクラス関連のステータス処理
    if KURE::BaseScript::USE_JOBLv == 1 
      sub_class_base = self.sub_class.params[param_id, @level] if @sub_class_id != 0
      sub_class_base = sub_class_base * KURE::JobLvSystem::SUB_CLASS_STATUS_RATE
      class_base = class_base * KURE::JobLvSystem::MAIN_CLASS_STATUS_RATE if @sub_class_id != 0
    end
    
    passive_base = 0
    #パッシブスキル関連のステータス処理
    for i in 0..passive_skills.size - 1
      passive_base += passive_skills[i].params[param_id] if passive_skills[i].kind_of?(RPG::EquipItem)
    end
    
    status_divide_base = 0
    #ステータス振り分けの処理
    if @status_divide && @status_divide[param_id]
      status_divide_base = @status_divide[param_id]
    end
    
    battle_add = 0
    #戦闘中ステータス強化率
    if @battle_add_status && @battle_add_status[param_id]
      battle_add = @battle_add_status[param_id]
    end
  
    sum = class_base + sub_class_base + passive_base + status_divide_base
    sum *= 1 + battle_add
    
    return sum.to_i
  end
  #--------------------------------------------------------------------------
  # ▲★ レベルアップ(再定義)
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    
    if KURE::BaseScript::USE_StatusDivied == 1 && @level > @last_level
      @last_level = @level
      @status_point += KURE::Statusdivide::LEVELUP_STATUS_POINT
      @status_point += (KURE::Statusdivide::LEVELUP_STATUS_POINT_REVICE * @level).to_i
    end
  
    #職業レベルを導入している場合、固有スキルを処理する
    if KURE::BaseScript::USE_JOBLv == 1     
      if $data_actors[@actor_id].actor_peculiar_skill != []
        for i in 0..$data_actors[@actor_id].actor_peculiar_skill.size - 1
          if i % 2 == 0
            if @level == $data_actors[@actor_id].actor_peculiar_skill[i]
              learn_skill($data_actors[@actor_id].actor_peculiar_skill[i + 1])
            end
          end
        end
      end
    #職業レベルを導入しない場合、スキルポイントシステムを確認する
    else
      #スキルポイントシステムを利用している場合、初期スキルを制限する
      self.class.learnings.each do |learning|
        if KURE::BaseScript::USE_Skill_Point == 1
          if learning.note.include?("<固有スキル>")
            learn_skill(learning.skill_id) if learning.level == @level
          end
        else
          learn_skill(learning.skill_id) if learning.level == @level
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 経験値の獲得（経験獲得率を考慮）(再定義)
  #--------------------------------------------------------------------------
  def gain_exp(exp, jobexp = nil, equip_exp = nil, a_exp = nil, s_exp = nil, ski_exp = nil)
    jobexp = 0 if jobexp == nil
    equip_exp = 0 if equip_exp == nil
    a_exp = 0 if a_exp == nil
    s_exp = 0 if s_exp == nil
    ski_exp = 0 if ski_exp == nil
    @sub_class_id = 0 if @sub_class_id == nil
    
    #獲得した経験値を代入
    base = self.exp + (exp * final_exp_rate).to_i
    job = 0 ; sub = 0 ; equip = 0
    
    #職業レベルを導入している場合、職業経験値を獲得させる
    if KURE::BaseScript::USE_JOBLv == 1
      job = self.jobexp + (jobexp * final_exp_rate).to_i
      sub = self.sub_class_exp + (jobexp * final_exp_rate * KURE::JobLvSystem::SUB_CLASS_EXP_RATE).to_i if @sub_class_id != 0
    end
    
    #装備個別管理を導入している場合装備経験値を獲得させる
    if KURE::BaseScript::USE_SortOut == 1
      equip = (equip_exp * final_exp_rate).to_i
    end
    change_exp(base, true, job, sub, equip, a_exp, s_exp, ski_exp)
  end
  #--------------------------------------------------------------------------
  # ▲ 経験値の変更(再定義)
  #     show : レベルアップ表示フラグ
  #--------------------------------------------------------------------------
  def change_exp(exp, show, jobexp = nil, subexp = nil, equip_exp = nil, a_exp = nil, s_exp = nil, ski_exp = nil)
    equip_exp = 0 if equip_exp == nil
    jobexp = self.jobexp if jobexp == nil
    a_exp = 0 if a_exp == nil
    s_exp = 0 if s_exp == nil
    ski_exp = 0 if ski_exp == nil
    subexp = self.sub_class_exp if subexp == nil
    
    #経験値増加
    @exp[@class_id] = [exp, 0].max
    last_level = @level

    #職業経験値増加処理
    if KURE::BaseScript::USE_JOBLv == 1
      @jobexp[@class_id] = [jobexp, 0].max
      last_joblevel = @joblevel
      if @sub_class_id != 0
        @jobexp[@sub_class_id] = [subexp, 0].max      
        last_sublevel = @sub_class_level
      end
    end
    
    #装備固有の経験値処理
    if KURE::BaseScript::USE_SortOut == 1
      for slot in 0..equips.size - 1
        if equips[slot]
          identify_id = equips[slot].identify_id
          master_container = $game_party.item_master_container(equips[slot].class)
          master_container[identify_id].equip_exp = equip_exp
          master_container[identify_id].slot_equip_exp = equip_exp
        end
      end
    end
    
    last_skills = learned_skill_list
    
    #APの処理
    gain_ability_point(a_exp)
    
    #ステータスポイントの処理
    add_status_point(s_exp)
    
    #スキルポイントの処理
    add_skill_point(ski_exp)
    
    #レベルアップ処理
    level_up while !max_level? && self.exp >= next_level_exp
    level_down while self.exp < current_level_exp
    
#~     #職業レベルのレベルアップ処理
#~     if KURE::BaseScript::USE_JOBLv == 1
#~       joblevel_up while !max_joblevel? && self.jobexp >= next_joblevel_exp
#~       joblevel_down while self.jobexp < current_joblevel_exp
#~       if @sub_class_id != 0
#~         sub_class_level_up while !max_sub_class_level? && self.sub_class_exp >= next_sub_class_level_exp
#~         sub_class_level_down while self.sub_class_exp < current_sub_class_level_exp
#~       end
#~     end
      
    up_base = @level - last_level
    up_job = 0
    up_sub = 0
    
    if KURE::BaseScript::USE_JOBLv == 1
      up_job = @joblevel - last_joblevel 
      up_sub = @sub_class_level - last_sublevel if @sub_class_id != 0
    end
    
    new_skills = learned_skill_list
    
#~     if up_base > 0 or  up_job > 0 or up_sub > 0 or new_skills - last_skills != []
#~       display_level_up(new_skills - last_skills, up_base, up_job, up_sub) if show
#~     end
    refresh
  end
  #--------------------------------------------------------------------------
  # ▲ レベルアップメッセージの表示(再定義)
  #     new_skills : 新しく習得したスキルの配列
  #--------------------------------------------------------------------------
#~   def display_level_up(new_skills, base = 0, job = 0, sub = 0)
#~     $game_message.new_page
#~     if base > 0
#~       $game_message.add(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
#~       
#~       #装備拡張の装備レベル使用時の判定
#~       if KURE::BaseScript::USE_ExEquip == 1
#~         if KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
#~           for slot in 0..@equips.size - 1
#~             if @equips[slot].object
#~               if @equips[slot].object.need_equip_limit_level < @level
#~                 $game_message.add(@name + "の" + @equips[slot].object.name + "が装備できなくなった。")
#~                 change_equip(slot, nil)
#~               end
#~             end
#~           end
#~         end
#~       end
#~       
#~     end
#~     if job > 0
#~       if max_joblevel?
#~         $game_message.add(@name + "は" + self.class.name + "の職業をマスターした。")
#~       else
#~         $game_message.add(sprintf(Vocab::LevelUp, @name, self.class.name + "の職業レベルが", @joblevel))
#~       end
#~       
#~       #装備拡張の装備レベル使用時の判定
#~       if KURE::BaseScript::USE_ExEquip == 1
#~         if KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
#~           for slot in 0..@equips.size - 1
#~             if @equips[slot].object
#~               if @equips[slot].object.need_equip_limit_joblevel < @joblevel
#~                 $game_message.add(@name + "の" + @equips[slot].object.name + "が装備できなくなった。")
#~                 change_equip(slot, nil)
#~               end
#~             end
#~           end
#~         end
#~       end
#~       
#~     end
#~     if sub > 0
#~       if max_sub_class_level?
#~         $game_message.add(@name + "は" + self.sub_class.name + "の職業をマスターした。")
#~       else
#~         $game_message.add(sprintf(Vocab::LevelUp, @name, self.sub_class.name + "の職業レベルが", @sub_class_level))
#~       end
#~     end
#~     
#~     new_skills.each do |skill|
#~       if base == 0 && job == 0 && sub == 0
#~         $game_message.add(sprintf(Vocab::ObtainSkill_AP, @name ,skill.name))
#~       else
#~         $game_message.add(sprintf(Vocab::ObtainSkill, skill.name))
#~       end
#~     end
#~   end
  #--------------------------------------------------------------------------
  # ▲ 最終的な経験獲得率の計算(再定義)
  #--------------------------------------------------------------------------
  def final_exp_rate
    exr * (battle_member? ? 1 : reserve_members_exp_rate)
  end
  #--------------------------------------------------------------------------
  # ▲★◆ 職業の変更(再定義)
  #     keep_exp : 経験値を引き継ぐ
  #--------------------------------------------------------------------------
  def change_class(class_id, keep_exp = true)
    #転職前に習得スキルを保存する
    @save_class_skills[@class_id] = [] unless @save_class_skills[@class_id]
    @save_class_skills[@class_id] = @skills.clone
    
    #共有スキルを配列に保存
    common_list = Array.new
    for i in 0..@skills.size - 1
      if $data_skills[@skills[i]].note.include?("<共有スキル>")
        common_list.push(@skills[i])
      end
    end

    #転職処理
    @exp[class_id] = exp if keep_exp
    @class_id = class_id
    change_exp(@exp[@class_id] || 0, false, self.jobexp, self.sub_class_exp)

    #動作テスト、職業レベルのチェックをスキップ
    if KURE::BaseScript::USE_JobChange == 1
      if KURE::JobChange::DELETE_SKILL_MODE == 0
        if @save_class_skills[@class_id]
          add_skills = @save_class_skills[@class_id].clone
          @skills = [] unless @skills
          @skills += add_skills
          @skills.uniq!
        end
      end
      if KURE::JobChange::DELETE_SKILL_MODE == 1
        
        if @save_class_skills[@class_id]
          @skills = @save_class_skills[@class_id].clone
        else
          @skills = []
        end
        
        @memory_skills = []       #スキルメモライズシステム
        @extra_skills = []        #スキルメモライズシステム
      
        for j in 0..common_list.size - 1
          learn_skill(common_list[j]) if KURE::BaseScript::USE_Skill_Point == 0
        end
      end
    end
    
    #職業レベルを併用している場合は職業レベルを設定
    if KURE::BaseScript::USE_JOBLv == 1
      change_exp(self.exp, false, @jobexp[@class_id] || 0,self.sub_class_exp)
    end
    
    #職業レベルの併用化チェックにより初期スキル習得処理を分岐
    cheack_first_Lv = @level
    cheack_first_Lv = @joblevel if KURE::BaseScript::USE_JOBLv == 1
      
    #初期Lvで覚えるスキルを処理 
    self.class.learnings.each do |learning|
      #スキルポイントシステムを利用している場合、初期スキルを制限する
      if KURE::BaseScript::USE_Skill_Point == 1
        if learning.note.include?("<固有スキル>")
          learn_skill(learning.skill_id) if learning.level <= cheack_first_Lv
        end
      else
        learn_skill(learning.skill_id) if learning.level <= cheack_first_Lv
      end
    end
    
    #職業レベルを導入している場合、Lv1固有スキルを処理する
    if KURE::BaseScript::USE_JOBLv == 1 
      if $data_actors[@actor_id].actor_peculiar_skill != []
        for i in 0..$data_actors[@actor_id].actor_peculiar_skill.size - 1
          if i % 2 == 0
            if @level >= $data_actors[@actor_id].actor_peculiar_skill[i]
              learn_skill($data_actors[@actor_id].actor_peculiar_skill[i + 1])
            end
          end
        end
      end
    end
    
    #クラスレベルリストを更新する
    add_level = @level
    add_level = @joblevel if KURE::BaseScript::USE_JOBLv == 1
    @classlevel_list[@class_id] = add_level
    
    #パッシブスキルを更新する
    set_passive_skills
    refresh
  end

  #--------------------------------------------------------------------------
  # ● HPの呼び出し(再定義)
  #--------------------------------------------------------------------------
  def hp
    @hp = [@hp,mhp].min
    return @hp
  end
  #--------------------------------------------------------------------------
  # ● MPの呼び出し(再定義)
  #--------------------------------------------------------------------------
  def mp
    @mp = [@mp,mmp].min
    return @mp
  end
  #--------------------------------------------------------------------------
  # ☆ TP の最大値を取得(再定義)
  #--------------------------------------------------------------------------
  def max_tp
    base = $data_classes[@class_id].base_tp
    base += $data_actors[@actor_id].base_tp
    
    
    if KURE::BaseScript::C_TP_ADDER == 1
      add_fix = ($data_actors[@actor_id].tp_level_revise).to_f / 100
      add = (add_fix * (@level - 1)).to_i
      limit = $data_classes[@class_id].upper_limit_tp
      
      all_gain_tp = battler_add_ability(44)[0]
      all_gain_tp_per = battler_add_ability(44)[1]
    
      if limit > ((base + add + all_gain_tp) * (all_gain_tp_per.to_f / 100)).to_i
        return ((base + add + all_gain_tp) * (all_gain_tp_per.to_f / 100)).to_i
      else
        return limit
      end
    else
      return base
    end
    
  end
  #--------------------------------------------------------------------------
  # ☆ TP の割合を取得(再定義)
  #--------------------------------------------------------------------------
  def tp_rate
    return 0 if max_tp == 0
    return @tp.to_f / max_tp
  end
  #--------------------------------------------------------------------------
  # ☆ TP の再生(再定義)
  #--------------------------------------------------------------------------
  def regenerate_tp
    self.tp += max_tp * trg
  end
  #--------------------------------------------------------------------------
  # ☆ TP の初期化(再定義)
  #--------------------------------------------------------------------------
  def init_tp
    self.tp = rand * 25 

    tp_rate = passive_skills.select{|obj| obj.battle_start_tp != 0}.collect{|obj| obj.battle_start_tp}
    tp_rate.flatten!
    tp_rate.push(self.class.battle_start_tp)
    tp_rate.push($data_actors[@actor_id].battle_start_tp)
    final_rate = tp_rate.max
    
    self.tp = max_tp * final_rate.to_f / 100 if final_rate != 0
  end
  #--------------------------------------------------------------------------
  # ☆ 通常攻撃のスキル ID を取得(再定義)
  #--------------------------------------------------------------------------
  def attack_skill_id
    passive_list = passive_skills.select{|obj| obj.normal_attack_id != nil}.collect{|obj| obj.normal_attack_id}
    passive_list.flatten!
    if passive_list.size != 0
      attack_skill = passive_list.sort_by{rand}
      return attack_skill[0] if attack_skill[0]
    end
    
    if @equips[0].object != nil and equip_slots[0] == 0
      if $data_weapons[@equips[0].id]
        attack_skill = $data_weapons[@equips[0].id].normal_attack_id.sort_by{rand}
        return attack_skill[0] if attack_skill[0]
      end
    end
    
    if @equips[1].object != nil and equip_slots[1] == 0
      if $data_weapons[@equips[1].id]
        attack_skill = $data_weapons[@equips[1].id].normal_attack_id.sort_by{rand}
        return attack_skill[0] if attack_skill[0]
      end
    end
    
    attack_skill = $data_classes[@class_id].normal_attack_id.sort_by{rand}
    return attack_skill[0] if attack_skill[0]
    
    attack_skill = $data_actors[@actor_id].normal_attack_id.sort_by{rand}
    return attack_skill[0] if attack_skill[0]
    return 1
  end
  #--------------------------------------------------------------------------
  # ○ スキルの必要装備を装備しているか(再定義)
  #--------------------------------------------------------------------------
  def skill_wtype_ok?(skill)
    #防具判定
    return false unless skill_etype_ok?(skill)
    
    wtype_id1 = skill.required_wtype_id1
    wtype_id2 = skill.required_wtype_id2
    #追加武器タイプ
    wtype_id_add = skill.required_add_wtype_id
    
    #要求武器タイプ
    wtype_id_need = skill.need_wtype_id_all
    
    #同一タイプ二刀流判定
    if skill.request_same_weapon_id
      if weapons.size > 1
        return true if weapons[0].wtype_id == weapons[1].wtype_id
      end
      return false
    end
    
    #要求判定
    if wtype_id_need != []
      for need in 0..wtype_id_need.size - 1
        if wtype_id_need[need] > 0
          return false unless wtype_equipped?(wtype_id_need[need])
        end
      end
    end  
    
    #二刀流要求の判定
    return true if skill.need_two_weapon && weapons.size > 1
    return false if skill.need_two_weapon && weapons.size < 2  
    
    return true if wtype_id1 == 0 && wtype_id2 == 0 && wtype_id_add == []
    return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    #追加判定
    for add in 0..wtype_id_add.size - 1
      if wtype_id_add[add]
        return true if wtype_id_add[add] > 0 && wtype_equipped?(wtype_id_add[add])
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 装備できない装備品を外す(再定義)
  #     item_gain : 外した装備品をパーティに戻す
  #--------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    cheack_arr = Array.new
    @equips.each_with_index do |item, i|
      if !equippable?(item.object) || item.object.etype_id != equip_slots[i]
        
        #拡張装備タイプ判定
        if item.object
          cheack_obj = item.object.clone
          unless item.object.add_etype_id.include?(equip_slots[i])
            cheack_arr.push(cheack_obj)
            trade_item_with_party(nil, item.object) if item_gain
            item.object = nil
          end
        else
          trade_item_with_party(nil, item.object) if item_gain
          item.object = nil
        end
        
      end
    end
    
    if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
      cheack_arr.each do |obj|
        auto_state_adder_ex(obj) 
      end
    end
  end
end

#==============================================================================
# ■ Game_Player(再定義)
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● エンカウント進行値の取得
  #--------------------------------------------------------------------------
  def encounter_progress_value
    value = $game_map.bush?(@x, @y) ? 2 : 1
    
    if KURE::BaseScript::C_ENCOUNTER == 1
      encount_rate = Array.new
      encount_rate = $game_party.party_add_ability(2)
      final_rate = encount_rate.inject(1) {|result, item| result * item}
      value *= final_rate
    end
    
    value *= 0.5 if $game_party.encounter_half?
    value *= 0.5 if in_ship?
    value
  end  
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● ドロップアイテム取得率の倍率を取得(再定義)
  #--------------------------------------------------------------------------
  def drop_item_rate
    final_drop_rate = Array.new
    final_drop_rate = $game_party.party_add_ability(1)
    final_drop_rate.push(2) if $game_party.drop_item_double?
    
    #ドロップ率増加ステートの処理
    state_rate = states.collect{|obj| obj.gain_drop_rate}
    add_rate = state_rate.max.to_f / 100
    
    max_rate = final_drop_rate.max * add_rate
    return max_rate
  end  
end

#==============================================================================
# ■ Game_Troop
#==============================================================================
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● 経験値の合計計算(再定義)
  #--------------------------------------------------------------------------
  def exp_total
    exp_total_g = dead_members.inject(0) {|r, enemy| r += enemy.exp }
    exp_rate = $game_party.party_add_ability(3)
    exp_total_g *= exp_rate.max
    if KURE::BaseScript::USE_PartyEdit == 1
      if KURE::PartyEdit::SHARE_EXP_MODE == 1
        max = $game_party.max_battle_members
        now = $game_party.battle_members_size
        ptm_rate = max.to_f / now 
        exp_total_g *= ptm_rate
      end
    end
    return exp_total_g.to_i
  end
  #--------------------------------------------------------------------------
  # ● お金の合計計算(再定義)
  #--------------------------------------------------------------------------
  def gold_total
    (dead_members.inject(0) {|r, enemy| r += enemy.gold } * gold_rate).to_i
  end
  #--------------------------------------------------------------------------
  # ● お金の倍率を取得(再定義)
  #--------------------------------------------------------------------------
  def gold_rate
    final_gold_rate = Array.new
    final_gold_rate = $game_party.party_add_ability(0)
    final_gold_rate.push(2) if $game_party.gold_double?
    max_rate = final_gold_rate.max
    return max_rate
  end
end

#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # ● 行動が有効か否かの判定(再定義)
  #    イベントコマンドによる [戦闘行動の強制] ではないとき、ステートの制限
  #    やアイテム切れなどで予定の行動ができなければ false を返す。
  #--------------------------------------------------------------------------
  def valid?
    return true if @ramdom_effect == 1
    (forcing && item) || subject.usable?(item)
  end
  #--------------------------------------------------------------------------
  # ● 混乱行動を設定(再定義)
  #--------------------------------------------------------------------------
  def set_confusion
    if subject.adv_confusion?
      if subject.actor?
        confusion_action = subject.skills.sort_by{rand}
        if confusion_action[0] && subject.skill_conditions_met?(confusion_action[0])
          set_skill(confusion_action[0].id)
        else
          set_attack
        end
      elsif subject.enemy?
        confusion_action = $data_enemies[subject.enemy_id].actions.sort_by{rand}
        if confusion_action[0] && subject.action_valid?(confusion_action[0])
          set_enemy_action(confusion_action[0])
        else
          set_attack
        end
      end
    else
      set_attack
    end
    self
  end
end

#==============================================================================
# ■ Scene_Battle(再定義)
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 戦闘開始(再定義)
  #--------------------------------------------------------------------------
#~   def battle_start
#~     BattleManager.battle_start
#~     
#~     if KURE::BaseScript::C_FIRST_INVOKE_SKILL == 1
#~       unless @first_invoke_item_process
#~         first_invoke_items
#~         @first_invoke_item_process = true
#~       end
#~     end
#~     
#~     process_event
#~     start_party_command_selection
#~   end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用(再定義)
  #--------------------------------------------------------------------------
  def use_item
    if KURE::BaseScript::C_AUTO_REVIVE == 1
      #オートリザレクション配列を作成
      auto_revive_battler = Array.new
      all_battle_members.each do |battler|
        push = battler.auto_revive
        auto_revive_battler.push([battler,push]) if push
      end
    end
    
    #使用スキルの判定、コストスキルの判定
    item = @subject.current_action.item
    cost = @subject.current_action.item
    
    #複数回発動
    @subject.multi_invoke(item).times{
    
    random = @subject.current_action.random_item
    force = @subject.current_action.force_action_item
    
    #強制行動
    if force
      item = force 
      cost = force
    end
    
    #通常攻撃再設定機能
    if KURE::BaseScript::C_NORMAL_ATTACK_RESET == 1
      if item.id == 1
        item = $data_skills[@subject.attack_skill_id]
        cost = $data_skills[@subject.attack_skill_id]
      end
    end
    
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    
    #ランダム発動
    item = random if random
      
    #マルチエフェクト
    multi_e = item.multi_skill_effect
    targets = @subject.current_action.make_targets.compact
    
    if item.multi_skill_effect == []
      #アニメーション
      anim_d = $data_animations[item.animation_id]
      if anim_d && anim_d.to_screen?
        show_normal_animation([targets[0]].compact, item.animation_id) if targets[0]
        @log_window.wait
        wait_for_animation
      else
        show_animation(targets, item.animation_id)
      end
      
      targets.each {|target| item.repeats.times { invoke_item(target, item) } }
    else
      multi_e.each do |skill_id|
        item2 = $data_skills[skill_id]
        @subject.current_action.item = item2
        targets = @subject.current_action.make_targets.compact
        
        #アニメーション
        anim_d = $data_animations[item2.animation_id]
        if anim_d && anim_d.to_screen?
          show_normal_animation([targets[0]].compact, item2.animation_id) if targets[0]
          @log_window.wait
          wait_for_animation
        else
          show_animation(targets, item2.animation_id)
        end
      
        targets.each {|target| item2.repeats.times { invoke_item(target, item2) } }
      end
      @subject.current_action.item = item
    end
    
    used_item_cost(cost)
    refresh_status
    
    #オートリザレクション
    if KURE::BaseScript::C_AUTO_REVIVE == 1
      auto_revive_process(auto_revive_battler)
    end
    
    @log_window.wait_and_clear
    }
  end
  #--------------------------------------------------------------------------
  # ● ターン終了(再定義)
  #--------------------------------------------------------------------------
  def turn_end
    #オートリザレクション配列を作成
    auto_revive_battler = Array.new
    #追撃バトラー配列を作成
    chase_battler = Array.new
    
    all_battle_members.each do |battler|
      #ディレイカット
      battler.result.clear
      battler.delay_cutter
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
      #オートリザレクション
      if KURE::BaseScript::C_AUTO_REVIVE == 1
        push = battler.auto_revive
        auto_revive_battler.push([battler,push]) if push
      end
      #追撃
      if battler.alive? && KURE::BaseScript::C_CHASE_ATTACK == 1
        push2 = battler.battler_add_ability(30)
        chase_battler.push([battler,push2]) if push2 != []
      end
    end
    
    all_battle_members.each do |battler|
      battler.on_turn_end
      refresh_status
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
    end
    
    #追撃実行
    if KURE::BaseScript::C_CHASE_ATTACK == 1
      chase_attack_process(chase_battler)
    end
    
    #ターン間スキル
    if KURE::BaseScript::C_SE_TURN_SKILL == 1
      turn_invoke_items(2)
    end
    
    #オートリザレクション
    if KURE::BaseScript::C_AUTO_REVIVE == 1
      auto_revive_process(auto_revive_battler)
    end
  
    @log_window.wait_and_clear
    BattleManager.turn_end
    process_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの発動(再定義)
  #--------------------------------------------------------------------------
  def invoke_item(target, item)
    case KURE::BaseScript::COUNTER_MODE
    #デフォルト
    when 1
      #反撃判定
      if rand < target.multi_cnt_rate(@subject, item.hit_type)
        invoke_counter_attack(target, item)
      #反射判定
      elsif rand < target.item_mrf(@subject, item)
        invoke_magic_reflection(target, item)
      #献身判定
      else
        #献身者の指定
        new_target = apply_substitute(target, item)
        apply_item_effects(new_target, item)
        #拡張反撃
        if rand < new_target.adv_multi_cnt_rate(@subject, item.hit_type)
          invoke_counter_attack(new_target, item)
        end
      end      

    #行動後
    when 2
      #拡張反撃判定
      if rand < target.adv_multi_cnt_rate(@subject, item.hit_type)
        invoke_counter_attack(target, item)
      #反射判定
      elsif rand < target.item_mrf(@subject, item)
        invoke_magic_reflection(target, item)
      #献身判定
      else
        #献身者の指定
        new_target = apply_substitute(target, item)
        apply_item_effects(new_target, item)
        #反撃
        if rand < new_target.multi_cnt_rate(@subject, item.hit_type)
          invoke_counter_attack(new_target, item)
        end
      end 
    end
    @subject.last_target_index = target.index
  end
  #--------------------------------------------------------------------------
  # ● 反撃の発動(再定義)
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    @log_window.clear
    attack_skill = $data_skills[target.attack_skill_id]
    
    #反撃スキルの設定読み込み
    counter = target.battler_add_ability(17)
    rand_c = counter.sort_by{rand}
    attack_skill = $data_skills[rand_c[0]] if rand_c[0]
    
    @log_window.display_counter(target, attack_skill)
    
    target.actor_add_cheack[24] = true
    @subject.item_apply(target, attack_skill)
    show_counter_animation([@subject], target, attack_skill)
    
    refresh_status
    @log_window.display_action_results(@subject, attack_skill)
    @log_window.wait_and_clear
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_party_command_window
    @party_command_window = Window_PartyCommand.new
    @party_command_window.viewport = @info_viewport
    @party_command_window.set_handler(:fight,  method(:command_fight))
    @party_command_window.set_handler(:escape, method(:command_escape))
    @party_command_window.set_handler(:partyedit,  method(:command_partyedit))
    @party_command_window.set_handler(:exequip,  method(:command_exequip))
    @party_command_window.unselect
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
# ▲ BattleManager(再定義)
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # ▲ 獲得した経験値の表示(再定義)
  #--------------------------------------------------------------------------
  def self.display_exp
    #Exp
    if $game_troop.exp_total > 0
      text = sprintf(Vocab::ObtainExp, $game_troop.exp_total)
      $game_message.add('\.' + text)
    end
    
    #JobExp
    if KURE::BaseScript::USE_JOBLv == 1
      if $game_troop.jobexp_total > 0
        text2 = sprintf(Vocab::ObtainJobExp, $game_troop.jobexp_total)
        $game_message.add('\.' + text2)
      end
    end
    
#~     #EquipExp
#~     if KURE::BaseScript::USE_SortOut == 1
#~       if $game_troop.equip_exp_total > 0
#~         text3 = sprintf(Vocab::ObtainEquipExp, $game_troop.equip_exp_total)
#~         $game_message.add('\.' + text3)
#~       end
#~     end
    
    #AP
    if $game_troop.ability_exp_total > 0
      text4 = sprintf(Vocab::ObtainAP, $game_troop.ability_exp_total)
      $game_message.add('\.' + text4)
    end
    
    #ステータスポイント
    if $game_troop.status_exp_total > 0
      text5 = sprintf(Vocab::ObtainStatus, $game_troop.status_exp_total)
      $game_message.add('\.' + text5)
    end    
    
    #スキルポイント
    if $game_troop.skill_exp_total > 0
      text6 = sprintf(Vocab::ObtainSkillP, $game_troop.skill_exp_total)
      $game_message.add('\.' + text6)
    end   
  end
  #--------------------------------------------------------------------------
  # ▲ 経験値の獲得とレベルアップの表示(再定義)
  #--------------------------------------------------------------------------
  def self.gain_exp
    base = $game_troop.exp_total
    job = 0 ; equip = 0 ; ap = 0 ; status = 0
    job = $game_troop.jobexp_total if KURE::BaseScript::USE_JOBLv == 1 
    equip = $game_troop.equip_exp_total if KURE::BaseScript::USE_SortOut == 1
    ap = $game_troop.ability_exp_total
    status = $game_troop.status_exp_total
    skill = $game_troop.skill_exp_total
    
    $game_party.all_members.each do |actor|
      actor.gain_exp(base, job, equip, ap, status, skill)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● ターン開始時へリセット(追加定義)
  #--------------------------------------------------------------------------
  def self.reset
    @phase = :init
    @actor_index = -1
  end
  #--------------------------------------------------------------------------
  # ● 戦闘開始(再定義)
  #--------------------------------------------------------------------------
#~   def self.battle_start
#~     if $k_form_pe_call != 1
#~       $game_system.battle_count += 1 
#~       $game_party.on_battle_start
#~       $game_troop.on_battle_start
#~     end
#~     
#~     if $k_form_pe_call != 1
#~       $game_troop.enemy_names.each do |name|
#~         $game_message.add(sprintf(Vocab::Emerge, name))
#~       end
#~       if @preemptive
#~         $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
#~       elsif @surprise
#~         $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
#~       end
#~       wait_for_message
#~     end
#~         
#~     $k_form_pe_call = 0
#~   end
end