#==============================================================================
#  ■併用化ベーススクリプトＣ for RGSS3 Ver5.05-EX14
#　□作成者 kure
#==============================================================================

$kure_base_script = {} if $kure_base_script == nil
$kure_base_script[:base_C] = 503
p "併用化ベーススクリプトC"

#==============================================================================
# ■ Window_PartyCommand
#==============================================================================
class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_make_command_list make_command_list
  def make_command_list
    k_before_make_command_list
    if $kure_base_script[:PartyEdit]
      case KURE::PartyEdit::PERMIT_EDIT_IN_BATTLE
      when 1
        add_command("パーティー編成",  :partyedit ,$game_switches[KURE::PartyEdit::PERMIT_EDIT_IN_BATTLE_SWITH])
      when 2
        add_command("パーティー編成",  :partyedit)
      end
    end
    
    if $kure_base_script[:ExEquip]
      case KURE::ExEquip::PERMIT_EDIT_IN_BATTLE
      when 1
        add_command("装備変更",  :exequip ,$game_switches[KURE::ExEquip::PERMIT_EDIT_IN_BATTLE_SWITH])
      when 2
        add_command("装備変更",  :exequip)
      end 
    end
    
  end
end

#==============================================================================
# ■ Window_SkillList
#==============================================================================
class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ☆ フレーム更新(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_update update
  def update
    k_before_update
    process_cost_refresh if KURE::BaseScript::C_SKILL_COST_DRAW == 1
  end  
  #--------------------------------------------------------------------------
  # ☆ スキルの使用コストを描画(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_draw_skill_cost draw_skill_cost
  def draw_skill_cost(rect, skill)
    if @actor.skill_delay && @actor.skill_delay[skill.id] && @actor.skill_delay[skill.id] != 0
      change_color(knockout_color)
      draw_text(rect, "Delay " + @actor.skill_delay[skill.id].to_s, 2)
      return
    end
    if KURE::BaseScript::C_SKILL_COST_DRAW == 0
      k_before_draw_skill_cost(rect, skill)
    else
      type = 0
      type += 1 if @actor.skill_tp_cost(skill) > 0
      type += 2 if @actor.skill_mp_cost(skill) > 0
      type += 4 if @actor.skill_hp_cost(skill) > 0
    
      case type
      when 1
        change_color(tp_cost_color, enable?(skill))
        draw_text(rect, @actor.skill_tp_cost(skill), 2)
      when 2
        change_color(mp_cost_color, enable?(skill))
        draw_text(rect, @actor.skill_mp_cost(skill), 2)
      when 3
        case @cost_draw_index
        when 0,2,4
          change_color(tp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_tp_cost(skill),2)
        when 1,3,5
          change_color(mp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_mp_cost(skill), 2)
        end
      when 4
        change_color(hp_gauge_color1, enable?(skill))
        draw_text(rect, @actor.skill_hp_cost(skill), 2)
      when 5
        case @cost_draw_index
        when 0,2,4
          change_color(tp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_tp_cost(skill),2)
        when 1,3,5
          change_color(hp_gauge_color1, enable?(skill))
          draw_text(rect, @actor.skill_hp_cost(skill), 2)
        end
      when 6
        case @cost_draw_index
        when 0,2,4
          change_color(mp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_mp_cost(skill), 2)
        when 1,3,5
          change_color(hp_gauge_color1, enable?(skill))
          draw_text(rect, @actor.skill_hp_cost(skill), 2)
        end
      when 7
        case @cost_draw_index
        when 0,3
          change_color(tp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_tp_cost(skill),2)
        when 1,4
          change_color(mp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_mp_cost(skill), 2)
        when 2,5
          change_color(hp_gauge_color1, enable?(skill))
          draw_text(rect, @actor.skill_hp_cost(skill), 2)
        end
      end
    end
  end
end

#==============================================================================
# ■ Game_Message
#==============================================================================
class Game_Message
  attr_accessor :need_new_page            #改行要求
  #--------------------------------------------------------------------------
  # ● クリア(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_clear clear
  def clear
    k_before_clear
    @need_new_page = nil
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 戦闘開始処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_on_battle_start on_battle_start
  def on_battle_start
    k_before_on_battle_start
    add_cheacker
    auto_state_adder
    auto_state_adder_ex if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
    if actor?
      set_b_add_status if KURE::BaseScript::C_BATTLE_ADD_STATUS == 1
      set_b_add_state if KURE::BaseScript::C_BATTLE_ADD_STATE == 1
      set_passive_skills
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘終了処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_on_battle_end on_battle_end
  def on_battle_end
    k_before_on_battle_end
    init_tp unless preserve_tp?
    clear_cheackers
    add_cheacker
    auto_heeling if KURE::BaseScript::C_BATTLE_AUTO_HEELING == 1
    if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
      auto_state_adder_ex
      set_passive_skills if actor?
    end
    @first_invoke_item_process = false
  end
  #--------------------------------------------------------------------------
  # ● ターン終了処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_on_turn_end on_turn_end
  def on_turn_end
    self.need_passive_refresh = false if actor?
    k_before_on_turn_end
    return unless actor?
    
    set_b_add_status if KURE::BaseScript::C_BATTLE_ADD_STATUS == 1
    set_b_add_state if KURE::BaseScript::C_BATTLE_ADD_STATE == 1
    
    self.need_passive_refresh = true
    set_passive_skills(2)  if $game_party.in_battle
  end
  #--------------------------------------------------------------------------
  # ● ステートの解除(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_remove_state remove_state
  def remove_state(state_id)
    return unless state?(state_id)
    @auto_state ||= []
    return if @auto_state.include?(state_id)
    last_flag = self.need_passive_refresh if actor?
    self.need_passive_refresh = false if actor?
    
    remove_state_process(state_id)
    kure_before_remove_state(state_id)
    
    next_state = $data_states[state_id].next_state
    next_state.each{|id| add_state(id)}
    
    self.need_passive_refresh = last_flag if actor?
    #パッシブスキルを更新する
    set_passive_skills(2) if actor?
  end
  #--------------------------------------------------------------------------
  # ● ステートの消去(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_erase_state erase_state
  def erase_state(state_id)
    flag = true if state?(state_id)
    remove_state_process(state_id)
    kure_before_erase_state(state_id)
    
    #パッシブスキルを更新する
    set_passive_skills(2) if actor? && flag
  end
  #--------------------------------------------------------------------------
  # ● 使用対象以外に対する使用効果の適用(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_item_global_effect_apply item_global_effect_apply
  def item_global_effect_apply(effect)
    if effect.code == EFFECT_GET_ITEM
      item_effect_get_item(self, effect)
    end
    
    kure_before_item_global_effect_apply(effect)
  end
  #--------------------------------------------------------------------------
  # ○ 使用効果の適用(再定義)
  #--------------------------------------------------------------------------
  alias k_before_item_effect_apply item_effect_apply
  def item_effect_apply(user, item, effect)
    add_method_table = {
      EFFECT_STEAL         => :item_effect_steal,
      EFFECT_SKILL_RESET   => :item_effect_reset_skillpoint,
      EFFECT_BREAK_EQUIP   => :item_effect_break_equip,
      EFFECT_CLEAR_STATE   => :item_effect_clear_state,
      EFFECT_TRAP          => :item_effect_trap,
    }
    add_method_name = add_method_table[effect.code]
    send(add_method_name, user, item, effect) if add_method_name 
    
    k_before_item_effect_apply(user, item, effect)
  end
  #--------------------------------------------------------------------------
  # ● 使用効果［HP 回復](エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_item_effect_recover_hp item_effect_recover_hp
  def item_effect_recover_hp(user, item, effect)
    if self.reverse_heel && !item.ignore_reverse_heel
      value = (mhp * effect.value1 + effect.value2) * rec
      value *= user.pha if item.is_a?(RPG::Item)
      value = value.to_i
      @result.success = true
      @result.hp_damage += (value * self.reverse_heel).to_i
      self.hp -= (value * self.reverse_heel).to_i
    else
      k_before_item_effect_recover_hp(user, item, effect)
    end    
  end
  #--------------------------------------------------------------------------
  # ● 装備可能判定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_equippable? equippable?
  def equippable?(item)
    if $kure_base_script[:SortOut] && KURE::SortOut::BROKEN_CAN_EQUIP == 1
      return false unless item.is_a?(RPG::EquipItem)
      return false if item.broken?    
    end
    k_before_equippable?(item)
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用者側への効果(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_item_user_effect item_user_effect
  def item_user_effect(user, item)
    k_before_item_user_effect(user, item)
    
    #通常攻撃か反撃ステート対象であれば判定
    if item.add_counter_state? or item.damage.element_id < 0
      data = battler_add_ability(50).clone
      data.each do |obj|
        if (obj[1] * user.state_rate(obj[0])).to_i > rand(100)
          user.add_state(obj[0])
          user.result.sp_added_state_objects.push($data_states[obj[0]]).uniq!
        end
      end
    end
    
  end
end

#==============================================================================
# ■ Game_Actor(再定義項目集積)
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ●■★▲◆◇☆§ セットアップ(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_setup setup
  def setup(actor_id)
    @need_passive_refresh = false
      clear_add_object_before
      k_before_setup(actor_id)
      clear_add_object_after
    @need_passive_refresh = true
    set_passive_skills
  end
  #--------------------------------------------------------------------------
  # ● 経験値の初期化(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_init_exp init_exp
  def init_exp
    @joblevel = actor.initial_joblevel  #初期職業レベル
    @jobexp = {}                        #職業レベル
    first_lv_setup    
    k_before_init_exp
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_learn_skill learn_skill
  def learn_skill(skill_id)
    return if $data_skills[skill_id].not_learn_list.include?(@actor_id)
    
    k_before_learn_skill(skill_id)
    
    #メモライズ容量と相談して登録する
    if $kure_base_script[:Memorize] && KURE::SkillMemorize::AUTO_MEMORIZE == 1
      if !$data_skills[skill_id].not_auto_memorize && !unselect_skill?(skill_id)
        case $kure_base_script[:Memorize]
        when 1
          add_memorize_skill_ir(skill_id, true) unless KURE::SkillMemorize::NOT_AUTO_MEMORIZE.include?($data_skills[skill_id].stype_id)
        when 2 
          add_memorize_skill(skill_id)
        end
      end
    end
  
    #パッシブスキルを更新する
    set_passive_skills
  end
  #--------------------------------------------------------------------------
  # ● スキルを忘れる(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_forget_skill forget_skill
  def forget_skill(skill_id)
    k_before_forget_skill(skill_id)
    
    #メモライズ使用時は削除する
    delete_memorize_skill(skill_id) if $kure_base_script[:Memorize]
  
    #パッシブスキルを更新する
    set_passive_skills
  end
  #--------------------------------------------------------------------------
  # ■ スキルオブジェクトの配列取得(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_skills skills
  def skills
    if $kure_base_script[:Memorize]
      case $kure_base_script[:Memorize]
      when 1
        return (@skills | sub_class_skills_id | added_skills | @extra_skills).uniq.sort.collect {|id| $data_skills[id] }
      when 2
        arr = (@memory_skills| added_skills | @extra_skills).select{|id| id != nil}
        arr += (@skills | sub_class_skills_id).select{|id| unselect_skill?(id)}
        return arr.uniq.sort.collect {|id| $data_skills[id] }
      end
    end
    if $kure_base_script[:JobLvSystem]
      return (@skills | sub_class_skills_id | added_skills).uniq.sort.collect {|id| $data_skills[id] }
    end
    return k_before_skills
  end
  #--------------------------------------------------------------------------
  # ■ 装備の変更(エイリアス定義)
  #--------------------------------------------------------------------------
  alias k_before_change_equip change_equip
  def change_equip(slot_id, item)
    cheack_obj = @equips[slot_id].object.clone if @equips[slot_id] && @equips[slot_id].object
    k_before_change_equip(slot_id, item)

    #追加装備のスキル削除処理
    if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
      auto_state_adder_ex(cheack_obj)
      set_passive_skills if actor?
    end
  end
  #--------------------------------------------------------------------------
  # ☆ ステート情報をクリア(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_clear_states clear_states
  def clear_states
    #HP0処理回避
    @hp = 1 if @hp == 0
    #常時オートステート情報を保存する
    @need_passive_refresh = false
    auto_state = Array.new
    @states ||= []
    @auto_state ||= []
    @states.each{|id| auto_state.push(id) if $data_states[id].not_delete_state_healing}
    
    kure_before_clear_states

    auto_state.each{|id| add_state(id)}
    @need_passive_refresh = true
    #パッシブスキルを更新する
    set_passive_skills(2) if actor?
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用可能判定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_usable? usable?
  def usable?(item)
    
    #メモライズ判定
    if $kure_base_script[:Memorize] && item.is_a?(RPG::Skill) && auto_battle? && item.id != 1 && item.id != 2
      unless item.normal_attack_skill?
        return false unless memorize_now?(item.id)
      end
    end
    
    k_before_usable?(item)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_refresh refresh
  def refresh
    last_flag = @need_passive_refresh
    @need_passive_refresh = false
    kure_before_refresh
    @need_passive_refresh = last_flag
    set_passive_skills
  end
  #--------------------------------------------------------------------------
  # ▲ 特徴を保持する全オブジェクトの配列取得(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_feature_objects feature_objects
  def feature_objects
    k_before_feature_objects + passive_skills.compact
  end
  #--------------------------------------------------------------------------
  # ☆ TP の初期化(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_init_tp init_tp
  def init_tp
    k_before_init_tp

    tp_rate = passive_skills.select{|obj| obj.battle_start_tp != -1}.collect{|obj| obj.battle_start_tp}
    tp_rate.flatten!
    tp_rate.push(self.class.battle_start_tp) 
    tp_rate.push($data_actors[@actor_id].battle_start_tp)
    final_rate = tp_rate.max
    
    self.tp = max_tp * final_rate.to_f / 100 if final_rate != -1
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーが 1 歩動いたときの処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_on_player_walk on_player_walk
  def on_player_walk
    if KURE::BaseScript::C_WALK_PROCESS == 0
      check_floor_effect
      return
    else
      k_before_on_player_walk
    end
  end
end

#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # ● ランダムエフェクト関連のクリア(追加再定義)
  #--------------------------------------------------------------------------
  def clear_randamaize
    @force_action_item = nil
    @random_item = nil
    @change_item = nil    
  end
  #--------------------------------------------------------------------------
  # ● クリア(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_clear clear
  def clear
    clear_randamaize
    k_basescript_before_clear
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃を設定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_set_attack set_attack
  def set_attack
    clear_randamaize
    k_basescript_before_set_attack
  end
  #--------------------------------------------------------------------------
  # ☆ スキルを設定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_set_skill set_skill
  def set_skill(skill_id)
    clear_randamaize
    set_skill_id = change_action(skill_id)
    set_skill_id = randam_effecter(set_skill_id)
    set_skill_id = change_effecter(set_skill_id)
    k_basescript_before_set_skill(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 防御を設定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_set_guard set_guard
  def set_guard
    clear_randamaize
    k_basescript_before_set_guard
  end
  #--------------------------------------------------------------------------
  # ● アイテムを設定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_set_item_2 set_item
  def set_item(item_id)
    clear_randamaize
    randam_item_effecter(item_id)
    k_basescript_before_set_item_2(item_id)
  end
end

#==============================================================================
# ■ Scene_Battle(再定義)
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ☆ ターン開始(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_turn_start turn_start
  def turn_start    
    k_before_turn_start
    turn_invoke_items(1) if KURE::BaseScript::C_SE_TURN_SKILL == 1
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果を適用(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_apply_item_effects apply_item_effects 
  def apply_item_effects(target, item)
    #最終発動スキルフラグを立てる
    if target.hp > 0
      final_skill = target.final_invoke
      target.result.final_atk = true if final_skill
    end
    k_before_apply_item_effects(target, item)

    if target.hp <= 0 && final_skill
      invoke_final_attack(target, final_skill)
      target.perform_collapse_effect
    end
    
    #最終攻撃フラグを消去
    target.result.final_atk = false
  end
  #--------------------------------------------------------------------------
  # ● アニメーション(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_show_normal_animation show_normal_animation
  def show_normal_animation(targets, animation_id, mirror = false)
    k_before_show_normal_animation(targets, animation_id, mirror)
    wait_for_animation
  end
end

#==============================================================================
# ▲ BattleManager(エイリアス再定義)
#==============================================================================
class << BattleManager
  #--------------------------------------------------------------------------
  # ▲ 獲得した経験値の表示(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_display_exp display_exp
  def display_exp
    k_before_display_exp
    #JobExp
    if $kure_base_script[:JobLvSystem]
      if $game_troop.jobexp_total > 0
        text2 = sprintf(Vocab::ObtainJobExp, $game_troop.jobexp_total)
        $game_message.add('\.' + text2)
      end
    end
    
    #EquipExp
    if $kure_base_script[:SortOut]
      if $game_troop.equip_exp_total > 0
        text3 = sprintf(Vocab::ObtainEquipExp, $game_troop.equip_exp_total)
        $game_message.add('\.' + text3)
      end
    end
    
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
  # ● 戦闘開始(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_battle_start battle_start
  def battle_start
    k_before_battle_start if $k_form_pe_call != 1        
    $k_form_pe_call = 0
  end
end