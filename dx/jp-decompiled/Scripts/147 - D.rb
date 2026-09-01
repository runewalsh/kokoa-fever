#==============================================================================
#  ■併用化ベーススクリプトＤ for RGSS3 Ver5.05-EX14
#　□作成者 kure
#==============================================================================

$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:base_D] = 503
p "併用化ベーススクリプトD"

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
      next if state.id == target.death_state_id && target.result.final_atk
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id
      next if state_msg.empty?
      replace_text(target.name + state_msg)
      wait
      wait_for_effect      
    end
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 運による有効度変化率の取得(再定義)
  #--------------------------------------------------------------------------
  def luk_effect_rate(user)
    [1.0 + (user.luk - luk) * KURE::BaseScript::C_LUK_EFFECT, 0.0].max
  end
  #--------------------------------------------------------------------------
  # ● 戦闘不能になる(再定義)
  #--------------------------------------------------------------------------
  def die
    @hp = 0
    #全ステートを検索し、残留対象のステート以外を解除する
    self.need_passive_refresh = false if actor?
    states.each do |state|
      next if state.not_delete_state
      erase_state(state.id) if state.battler_add_ability(1)[0] == 0 && state.gain_drop_rate == 100
    end
    self.need_passive_refresh = true if actor?
    clear_buffs
    set_passive_skills if actor?
  end
  #--------------------------------------------------------------------------
  # ● ステートの付加(再定義)
  #--------------------------------------------------------------------------
  def add_state(state_id)
    state_id = state_change_process(state_id)
    #重複許容
    return unless state_multi_addable?(state_id)
    
    last_flag = self.need_passive_refresh if actor?
    self.need_passive_refresh = false if actor?
    
    basic_state = $data_states[state_id].basic_state
    basic_state.each{|id| return unless state?(id)}
    
    #上書きステートを処理
    overwrite_state = $data_states[state_id].overwrite_state_type
    overwrite_state.each do |type|
      states.each{|state| remove_state(state.id) if state.state_type.include?(type)}
    end
   
    #相殺ステートを処理する
    offset_state = $data_states[state_id].offset_state_type
    flag = 0
    offset_state.each do |off_type|
      states.each do |state|
        if state.state_type.include?(off_type)
          remove_state(state.id)
          flag = 1
        end
      end
    end

    self.need_passive_refresh = last_flag if actor?
    set_passive_skills(2) if actor? && flag == 1
    return if flag == 1
    self.need_passive_refresh = false if actor?
        
    #上書き情報により処理を変更
    mode = $data_states[state_id].overwrite_mode
    return if mode == 2 && state?(state_id)
    
    #付与できないステートは処理しない
    return unless state_addable?(state_id)

    #モードによりカウンター更新手順を変更
    cheak = [1,10,32]
    if @actor_add_counter && @actor_add_delay
      cheak.each do |ability|
        @actor_add_counter[ability] ||= 0
        @actor_add_delay[ability] ||= 0
        
        case ability
        when 1
          ability_1 = $data_states[state_id].battler_add_ability(1)
          case mode
          when 1,2
            @actor_add_counter[ability] += ability_1[2]
            @actor_add_delay[ability] = [ability_1[3],self.battler_add_ability(1)[3]].max
          when 0
            @actor_add_counter[ability] = [@actor_add_counter[ability],ability_1[2]].max
            @actor_add_delay[ability] = [ability_1[3],self.battler_add_ability(1)[3]].max
          end
        when 10
          case mode
          when 1,2
            @actor_add_counter[ability] += $data_states[state_id].battler_add_ability(10)
          when 0
            @actor_add_counter[ability] = [@actor_add_counter[ability],$data_states[state_id].battler_add_ability(10)].max
          end
        when 32
          if @actor_add_delay[ability] != 0
            @actor_add_delay[ability] += $data_states[state_id].battler_add_ability(32)
          end
        end
      end
    end
    
    add_new_state(state_id) unless state?(state_id)
    case mode
    when 0,2
      reset_state_counts(state_id)
    when 1
      add_state_counts(state_id)
    end
    @result.added_states.push(state_id).uniq!
    
    #アクターであればパッシブスキルを更新する
    self.need_passive_refresh = last_flag if actor?
    set_passive_skills(2) if actor?
  end
  #--------------------------------------------------------------------------
  # ○ スキル／アイテムの効果適用(再定義)
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    self.need_passive_refresh = false if actor?
    @result.clear
    @result.used = item_test(user, item)
    item_success_cheak_process(user, item)
    if @result.hit?
      skip_flag = 0
      #防御壁
      if defense_wall_usuable?(user,item)
        skip_flag = 1
        apply_defense_wall
      end
      
      #必中、物理、魔法無効判定
      type = item.hit_type
      ability_id = 46 + type
      if invalidate_usuable?(user,item,type) && skip_flag == 0
        if battler_add_ability(ability_id) > rand(100)
          skip_flag = 1
          apply_invalidate_ability(type)
        end
      end

      if skip_flag == 0
        unless item.damage.none?
          @result.critical = (rand < item_cri(user, item))
          make_damage_value(user, item)
          execute_damage(user)
        end
        item.effects.each {|effect| item_effect_apply(user, item, effect) }
        item_user_effect(user, item)
      end
    end

    if actor?
      set_b_add_status if KURE::BaseScript::C_BATTLE_ADD_STATUS == 1
      set_b_add_state if KURE::BaseScript::C_BATTLE_ADD_STATE == 1
      self.need_passive_refresh = true
      set_passive_skills 
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 使用効果［ステート付加］：通常攻撃(再定義)
  #--------------------------------------------------------------------------
  def item_effect_add_state_attack(user, item, effect)
    return if @result.invalidate
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
        else
          add_state(state_id)
        end
        @result.success = true
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
      else
        add_state(effect.data_id)
        if $data_states[effect.data_id].adv_substitute_t
          @substitute_list.push([effect.data_id,user]) if @substitute_list
        end
      end
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ☆ スキル／アイテムの属性修正値を取得(再定義)
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    element = apply_elements(user, item)
    #属性反映
    case KURE::BaseScript::C_ELEMENT_MODE
    when 0
      result = 1 if element == [] 
      result = elements_max_rate(user, element) if element != []
    when 1
      result = 1 if element == [] 
      result = elements_mix_atk_rate(user, element) - elements_mix_drain_rate(user, element) if element != []
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
  def elements_max_rate(user, elements)
    elements.inject([]) {|r, i| r.push((element_rate(i) * elements_booster_rate(user, i)) - elements_drain_rate(i)) }.max
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
    value = apply_counter_gain(user, value, item) if user.result.counter
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    
    value = apply_adv_guard(value, item)
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
    @save_class_skills = []
      
    #初期Lvで覚えるスキルを処理 
    learn_set_skill_lv(@class_id, first_skill_cheak_lv)
    
    #職業レベル導入時の処理
    if $kure_base_script[:JobLvSystem]
      #サブクラススキル習得
      learn_set_skill_lv(@sub_class_id, @sub_class_level) 
      #固有スキル習得
      learn_actor_actor_peculiar_skill(@actor_id,@level,1)
    end
    
    #初期登録スキルが有れば処理する
    if $kure_base_script[:Memorize]
      actor.first_memorize.each do |id|
        skill = $data_skills[id]
        next unless skill
        add_memorize_skill(skill) unless skill_memorize?(skill)
      end
      chain_memorize_set
    end
    
    #パッシブスキルを更新する
    set_passive_skills
  end  
  #--------------------------------------------------------------------------
  # ▲☆ 通常能力値の基本値取得(再定義)
  #--------------------------------------------------------------------------
  alias param_base_lb param_base
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
    if $kure_base_script[:JobLvSystem]
      sub_class_base = self.sub_class.params[param_id, @level] if @sub_class_id != 0
      sub_class_base = sub_class_base * KURE::JobLvSystem::SUB_CLASS_STATUS_RATE
      class_base = class_base * KURE::JobLvSystem::MAIN_CLASS_STATUS_RATE if @sub_class_id != 0
    end
    
    passive_base = 0
    #パッシブスキル関連のステータス処理
    passive_skills.each{|data| passive_base += data.params[param_id] if data.kind_of?(RPG::EquipItem)}
    
    status_divide_base = 0
    #ステータス振り分けの処理
    status_divide_base = @status_divide[param_id] if @status_divide && @status_divide[param_id]
    
    battle_add = 0
    #戦闘中ステータス強化率
    battle_add = @battle_add_status[param_id] if @battle_add_status && @battle_add_status[param_id]
  
    sum = class_base + sub_class_base + passive_base + status_divide_base
    sum *= 1 + battle_add    
    return sum.to_i
  end
  #--------------------------------------------------------------------------
  # ★ レベルアップ(再定義)
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    learn_skill_specify_lv(@class_id,@level) unless $kure_base_script[:JobLvSystem]
    
    if $kure_base_script[:Statusdivide] && @level > @last_level
      @last_level = @level
      @status_point += KURE::Statusdivide::LEVELUP_STATUS_POINT
      @status_point += (KURE::Statusdivide::LEVELUP_STATUS_POINT_REVICE * @level).to_i
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 経験値の変更(再定義)
  #     show : レベルアップ表示フラグ
  #--------------------------------------------------------------------------
  def change_exp(exp, show)    
    #経験値増加
    @exp[@class_id] = [exp, 0].max
    last_level = @level
    last_skills = learned_skill_list
    
    #レベルアップ処理
    level_up while !max_level? && self.exp >= next_level_exp
    level_down while self.exp < current_level_exp
          
    up_base = @level - last_level
        
    new_skills = learned_skill_list
    return unless show
    
    display_level_up(new_skills - last_skills) if up_base > 0
  end
  #--------------------------------------------------------------------------
  # ▲ レベルアップメッセージの表示(再定義)
  #     new_skills : 新しく習得したスキルの配列
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    if $game_message.need_new_page
      $game_message.new_page
      $game_message.need_new_page = false
    end
    
    $game_message.add(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
      
    #装備拡張の装備レベル使用時の判定
    if $kure_base_script[:ExEquip] && KURE::ExEquip::USE_EQUIPLV_SYSTEM == 1
      @equips.each do |obj|
        if obj.object && obj.object.need_equip_limit_level < @level
          $game_message.add(@name + "の" + @equips[slot].object.name + "が装備できなくなった。")
          change_equip(slot, nil)
        end
      end
    end
    
    new_skills.each do |skill|
      $game_message.add(sprintf(Vocab::ObtainSkill, skill.name))
    end
    
      #--------------------------------------------------------------------------
  # 最大レベル
  #--------------------------------------------------------------------------
  alias max_level_lb max_level
  def max_level
    
    #本来の処理での最大レベルを取得する。
    
    data = max_level_lb
    
    #各特徴の最大レベル増加値を足す。
    
    feature_objects.each {|f| data += f.mlv_plus}
    
    return data
  end

  #--------------------------------------------------------------------------
  # 通常能力値の基本値取得
  #--------------------------------------------------------------------------
  alias param_base_lb param_base
  def param_base(param_id)
    
    #レベル99以下の時は通常の処理を行い
    #100以上の場合は通常処理にレベル99以上でのパラメータを加える。
    
    @level > 99 ? self.class.params[param_id, 99] + over_level_param(param_id) : self.class.params[param_id, @level]
  end
  #--------------------------------------------------------------------------
  # レベル99以上でのパラメータ
  #--------------------------------------------------------------------------
  def over_level_param(param_id)
    
    #レベル98→99でのパラメータ増加値を取得。
    
    data = self.class.params[param_id, 99] - self.class.params[param_id, 98]
    
    #もしも0である場合は0を返す。
    
    return 0 if data == 0
    
    #現在レベルから99を引いた値、基本パラメータ補正、
    #パラメータ補正特徴による補正をパラメータ増加値に乗算し
    #最後に小数点以下を切り捨てる。
    
    data = (data * (@level - 99) * olextend_data_1 * olextend_data_2).truncate
    
    #データを返す。
    
    return data
  end
  #--------------------------------------------------------------------------
  # レベル99以上でのパラメータ補正1（基本）
  #--------------------------------------------------------------------------
  def olextend_data_1
    
    #初期データを用意。
    
    data = eval(MLV_CHANGE::P_RATE)
    
    #データが0の場合は0を返す。
    
    return 0 if data == 0
    
    #データが0でない場合は倍率にして返す。
    
    data = data.to_f / 100
    
    #データを返す。
    
    return data
  end
  #--------------------------------------------------------------------------
  # レベル99以上でのパラメータ補正2（特徴依存）
  #--------------------------------------------------------------------------
  def olextend_data_2
    
    #初期データを用意。
    
    data = 100
    
    #各特徴のパラメータ補正を加算。
    
    feature_objects.each {|f| data += eval(f.olv_extend) - 100}
    
    #データが0の場合は0を返す。
    
    return 0 if data == 0
    
    #データが0でない場合は倍率にして返す。
    
    data = data.to_f / 100
    
    #データを返す。
    
    return data
  end
    
    
  end
  #--------------------------------------------------------------------------
  # ▲★◆ 職業の変更(再定義)
  #     keep_exp : 経験値を引き継ぐ
  #--------------------------------------------------------------------------
  def change_class(class_id, keep_exp = true)
    self.need_passive_refresh = false
    
    #転職前に習得スキルを保存する
    @save_class_skills[@class_id] ||= []
    @save_class_skills[@class_id] = @skills.clone
    
    #共有スキルを配列に保存
    common_list = Array.new
    @skills.each do |skill| 
      common_list.push(skill) if $data_skills[skill].note.include?("<共有スキル>")
    end

    #転職処理
    @exp[class_id] = exp if keep_exp
    @class_id = class_id
    change_exp(@exp[@class_id] || 0, false)

    #動作テスト、職業レベルのチェックをスキップ
    
    case KURE::BaseScript::C_DELETE_SKILL_MODE
    when 0
      if @save_class_skills[@class_id]
        add_skills = @save_class_skills[@class_id].clone
        @skills ||= []
        @skills += add_skills
        @skills.uniq!
      end
      
      if KURE::BaseScript::C_MEMORIZE_REFRSH == 1
        @memory_skills = []       #スキルメモライズシステム
        @extra_skills = []        #スキルメモライズシステム
      end
    when 1
      if @save_class_skills[@class_id]
        @skills = @save_class_skills[@class_id].clone
      else
        @skills = []
      end
        
      @memory_skills = []       #スキルメモライズシステム
      @extra_skills = []        #スキルメモライズシステム
      
      if !$kure_base_script[:SkillPoint] && !$kure_base_script[:SkillPoint2]
        common_list.each{|id| learn_skill(id)}
      end
    end
    
    if $kure_base_script[:JobLvSystem]
      #職業レベルを併用している場合は職業レベルを設定
      @joblevel = 1
      change_job_exp(@jobexp[@class_id] || 0, self.sub_class_exp, false) 
      #固有スキル習得
      learn_actor_actor_peculiar_skill(@actor_id,@level,1)
    end
      
    #初期Lvで覚えるスキルを処理 
    learn_set_skill_lv(@class_id, first_skill_cheak_lv)
    #クラスレベルリストを更新する
    @classlevel_list[@class_id] = first_skill_cheak_lv
    
    self.need_passive_refresh = true
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
    return base if KURE::BaseScript::C_TP_ADDER == 0
    return @ability_data_cache[44] if @ability_data_cache && @ability_cheack_cache[44] && @ability_data_cache[44]

    all_gain_tp = battler_add_ability(44)[0]
    all_gain_tp_per = battler_add_ability(44)[1]
    
    add_fix = ($data_actors[@actor_id].tp_level_revise).to_f / 100
    add = (add_fix * (@level - 1)).to_i
    limit = $data_classes[@class_id].upper_limit_tp
      
    @ability_data_cache[44] = [limit, ((base + add + all_gain_tp) * (all_gain_tp_per.to_f / 100)).to_i].min
    return @ability_data_cache[44]
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
    if skill.request_same_weapon_id && weapons.size > 1
      return true if weapons[0].wtype_id == weapons[1].wtype_id
      return false
    end
    
    #要求判定
    wtype_id_need.each do |id|
      next if id <= 0
      return false unless wtype_equipped?(id)
    end
    
    #二刀流要求の判定
    return true if skill.need_two_weapon && weapons.size > 1
    return false if skill.need_two_weapon && weapons.size < 2  
    
    return true if wtype_id1 == 0 && wtype_id2 == 0 && wtype_id_add == []
    return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    #追加判定
    wtype_id_add.each do |id|
      next unless id
      return true if id > 0 && wtype_equipped?(id)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 装備できない装備品を外す(再定義)
  #     item_gain : 外した装備品をパーティに戻す
  #--------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    loop do
    last_equips = equips.dup
      
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
    
    cheack_arr.each{|obj| auto_state_adder_ex(obj)}
    
    return if equips == last_equips
    end
  end
  #--------------------------------------------------------------------------
  # ● 新しいステートの付加(再定義)
  #--------------------------------------------------------------------------
  def add_new_state(state_id)
    die if state_id == death_state_id
    @states.push(state_id)
    on_restrict if restriction > 0
    sort_states
  end
  #--------------------------------------------------------------------------
  # ● マップ画面上でのターン終了処理
  #--------------------------------------------------------------------------
  def turn_end_on_map
    return if KURE::BaseScript::C_WALK_PROCESS_EFFECT == 0
    if $game_party.steps % steps_for_turn == 0
      on_turn_end
      set_passive_skills(2) if @result.added_state_objects != [] && @result.removed_state_objects != [] && KURE::BaseScript::C_WALK_PASSIVE_REFRESH == 1
      perform_map_damage_effect if @result.hp_damage > 0
    end
  end
end

#==============================================================================
# ■ Game_Player(再定義)
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● エンカウント進行値の取得(再定義)
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
    if $kure_base_script[:PartyEdit] && KURE::PartyEdit::SHARE_EXP_MODE == 1
      max = $game_party.max_battle_members
      now = $game_party.battle_members_size
      ptm_rate = max.to_f / now 
      exp_total_g *= ptm_rate
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
  # ● 通常攻撃判定(再定義)
  #--------------------------------------------------------------------------
  def attack?
    return false unless item.is_a?(RPG::Skill)
    return true if item == $data_skills[1]
    return true if item.normal_attack_skill?
    return false
  end
  #--------------------------------------------------------------------------
  # ● 行動が有効か否かの判定(再定義)
  #    イベントコマンドによる [戦闘行動の強制] ではないとき、ステートの制限
  #    やアイテム切れなどで予定の行動ができなければ false を返す。
  #--------------------------------------------------------------------------
  def valid?
    return true if @ramdom_effect
    (forcing && item) || subject.usable?(item)
  end
end

#==============================================================================
# ■ Scene_Battle(再定義)
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 戦闘開始(再定義)
  #--------------------------------------------------------------------------
  def battle_start
    BattleManager.battle_start
    
    if KURE::BaseScript::C_FIRST_INVOKE_SKILL == 1
      unless @first_invoke_item_process
        first_invoke_items
        @first_invoke_item_process = true
      end
    end
    
    refresh_status
    process_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用(再定義)
  #--------------------------------------------------------------------------
  def use_item
    #使用スキルの判定、コストスキルの判定
    item = @subject.current_action.item
    cost = @subject.current_action.item
    
    #発動前コモンイベント
    pre_common_process(item)
    
    #複数回発動
    @subject.multi_invoke(item).times{
      break unless @subject.alive?
      break unless @subject.movable?
      break if $game_troop.all_dead?
    
    random = @subject.current_action.random_item
    change = @subject.current_action.change_item
    force = @subject.current_action.force_action_item
    
    #強制行動
    if force 
      item = force
      @subject.force_action_item_reset(item.id)
    end
    
    #通常攻撃再設定機能
    if KURE::BaseScript::C_NORMAL_ATTACK_RESET == 1
      if item.id == 1 or item.normal_attack_skill?
        item = $data_skills[@subject.attack_skill_id] if item.is_a?(RPG::Skill)
      end
    end
    
    #連携発動判定
    team = team_attack_process(item)
    if team
      @subject.use_item(item)
      @subject.add_skill_delay(item, random, change)
      team[0].use_item(team[2])
      team[0].add_skill_delay(team[2], nil, nil)
      item = team[1]
      pre_common_process(item)
      @subject.current_action.item = item
      @log_window.display_use_team_skill(@subject, team, item)
    else
      @log_window.display_use_item(@subject, item)
      @subject.use_item(item)
      @subject.add_skill_delay(item, random, change)
    end
    
    #ランダム発動
    item = random if random
    
    #スキル変化
    item = change if change
      
    #マルチエフェクト
    multi_e = item.multi_skill_effect
    targets = @subject.current_action.make_targets.compact
    
    #エフェクト発動
    effect_adopter(item, multi_e, targets)
    
    #連鎖発動
    chain_action_process(item)
    
    #スキル使用後コスト
    used_item_cost(cost)
    
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
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # ● ターン終了(再定義)
  #--------------------------------------------------------------------------
  def turn_end
    #追撃バトラー配列を作成
    chase_battler = Array.new
    
    all_battle_members.each do |battler|
      #ディレイカット
      battler.result.clear
      battler.delay_cutter
      battler.actor_ability_delay_cutter
      battler.trap_cutter
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
      #追撃
      if battler.alive? && KURE::BaseScript::C_CHASE_ATTACK == 1
        push2 = battler.battler_add_ability(30)
        chase_battler.push([battler,push2]) if push2 != []
      end
    end
    
    #追撃実行
    chase_attack_process(chase_battler) if KURE::BaseScript::C_CHASE_ATTACK == 1
    
    #ターン間スキル
    turn_invoke_items(2) if KURE::BaseScript::C_SE_TURN_SKILL == 1
    
    #オートリザレクション
    if KURE::BaseScript::C_AUTO_REVIVE == 1
      all_battle_members.each do |battler|
        auto_revive_process(battler)
        @log_window.wait_and_clear
      end
    end
    
    all_battle_members.each do |battler|
      battler.on_turn_end
      refresh_status
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
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
    return if @subject.dead?
    
    #反撃判定
    if rand < target.multi_cnt_rate(@subject, item.hit_type, 0)
      invoke_counter_attack(target, item)
    #反射判定
    elsif rand < target.item_mrf(@subject, item)
      invoke_magic_reflection(target, item)
    #献身判定
    else
      #献身者の指定
      new_target = apply_substitute(target, item)
      apply_item_effects(new_target, item)
      #行動反応追撃
      invoke_reaction_attack(@subject, item, new_target)
      #拡張反撃
      if rand < new_target.multi_cnt_rate(@subject, item.hit_type, 1)
        invoke_counter_attack(new_target, item)
      end
    end
    
    #トラップ発動プロセス
    invoke_trap_process(target, item)
    
    #回避反撃プロセス
    if target.result.evaded && rand < target.eva_cnt_rate(@subject, item.hit_type, 0)
      invoke_counter_attack(target, item)
    end
    
    @subject.last_target_index = target.index
  end
  #--------------------------------------------------------------------------
  # ● 反撃の発動(再定義)
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    
    #return if target.dead?
    @log_window.clear
    attack_skill = $data_skills[target.attack_skill_id]
    
    #反撃スキルの設定読み込み
    counter = target.battler_add_ability(17).sample
    case item.hit_type
    when 0
      counter = target.battler_add_ability(53).sample if target.battler_add_ability(53).sample
    when 1
      counter = target.battler_add_ability(51).sample if target.battler_add_ability(51).sample
    when 2
      counter = target.battler_add_ability(52).sample if target.battler_add_ability(52).sample
    end
    
    attack_skill = $data_skills[counter] if counter
    attack_skill.effects.each {|effect| @subject.item_global_effect_apply(effect) }
    @log_window.display_counter(target, attack_skill)
    target.result.counter = true
    show_counter_animation([@subject], target, attack_skill)
    
    if @subject.battler_add_ability(55) > rand(100)
      apply_counter_break(@subject, item, target)
      @log_window.wait_and_clear
      return
    end
    
    @subject.item_apply(target, attack_skill)
    
    refresh_status
    @log_window.display_action_results(@subject, attack_skill)
    @log_window.wait_and_clear
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンドウィンドウの作成(再定義)
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
end

#==============================================================================
# ▲ BattleManager(再定義)
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # ● 勝利の処理(再定義)
  #--------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    #バトルリザルトの存在で処理を分岐
    display_exp unless $kure_base_script[:BattleResult]
    gain_gold
    gain_drop_items
    gain_exp
    #拡張経験値獲得
    gain_ex_exp
    show_result_window if $kure_base_script[:BattleResult]
    SceneManager.return
    battle_end(0)
    return true
  end
end