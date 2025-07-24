#==============================================================================
#  ■併用化ベーススクリプトＣ for RGSS3 Ver3.10-β2
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
# ■ Window_PartyCommand
#==============================================================================
class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_make_command_list make_command_list
  def make_command_list
    k_before_make_command_list
    if KURE::BaseScript::USE_PartyEdit == 1
      case KURE::PartyEdit::PERMIT_EDIT_IN_BATTLE
      when 1
        if $game_switches[KURE::PartyEdit::PERMIT_EDIT_IN_BATTLE_SWITH] == true
          add_command("パーティー編成",  :partyedit)
        else
          add_command("パーティー編成",  :partyedit ,false)
        end
      when 2
        add_command("パーティー編成",  :partyedit)
      end
    end
    
    if KURE::BaseScript::USE_ExEquip == 1
      case KURE::ExEquip::PERMIT_EDIT_IN_BATTLE
      when 1
        if $game_switches[KURE::ExEquip::PERMIT_EDIT_IN_BATTLE_SWITH] == true
          add_command("装備変更",  :exequip)
        else
          add_command("装備変更",  :exequip ,false)
        end
      when 2
        add_command("装備変更",  :exequip)
      end 
    end
    
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
    reset_cheacker
    auto_state_adder
    auto_state_adder_ex if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
    make_skill_delay
    if actor?
      set_passive_skills 
      set_b_add_status if KURE::BaseScript::C_BATTLE_ADD_STATUS == 1
      set_b_add_state if KURE::BaseScript::C_BATTLE_ADD_STATE == 1
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
    auto_state_adder_ex if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
    @first_invoke_item_process = false
  end
  #--------------------------------------------------------------------------
  # ● ターン終了処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_on_turn_end on_turn_end
  def on_turn_end
    
    if SceneManager.scene_is?(Scene_Map)
      if KURE::BaseScript::C_WALK_PROCESS == 1
        k_before_on_turn_end
      end  
    else
      k_before_on_turn_end
    end
      
    if actor?
      set_passive_skills if KURE::BaseScript::C_WALK_PASSIVE_REFRESH == 1
      set_b_add_status if KURE::BaseScript::C_BATTLE_ADD_STATUS == 1
      set_b_add_state if KURE::BaseScript::C_BATTLE_ADD_STATE == 1
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果適用(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_item_apply item_apply
  def item_apply(user, item)
    k_before_item_apply(user, item)
    if actor?
      set_passive_skills 
      set_b_add_status if KURE::BaseScript::C_BATTLE_ADD_STATUS == 1
      set_b_add_state if KURE::BaseScript::C_BATTLE_ADD_STATE == 1
    end
  end
  #--------------------------------------------------------------------------
  # ● ステートの付加(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_add_state add_state
  def add_state(state_id)
    #発動数カウンターの更新
    if state_addable?(state_id) && state?(state_id) == false
      
      if @actor_add_counter && @actor_add_delay
        for ability in 0..32
          @actor_add_counter[ability] = 0 unless @actor_add_counter[ability]
          @actor_add_delay[ability] = 0 unless @actor_add_delay[ability]
          case ability
          when 1
            @actor_add_counter[ability] += $data_states[state_id].battler_add_ability(1)[2]
            @actor_add_delay[ability] = [$data_states[state_id].battler_add_ability(1)[3],self.battler_add_ability(1)[3]].max
          when 10
            @actor_add_counter[ability] += $data_states[state_id].battler_add_ability(10)
          when 32
            if @actor_add_delay[ability] != 0
              @actor_add_delay[ability] += $data_states[state_id].battler_add_ability(32)
            end
          end
        end
      end
    
    end
    
    k_before_add_state(state_id)
    
    #アクターであればパッシブスキルを更新する
    if actor?
      set_passive_skills
    end
  end
  #--------------------------------------------------------------------------
  # ● ステートの解除(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_remove_state remove_state
  def remove_state(state_id)
    remove_state_process(state_id)
    kure_before_remove_state(state_id)
    
    #パッシブスキルを更新する
    if actor?
      set_passive_skills
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用(エイリアス再定義)
  #    行動側に対して呼び出され、使用対象以外に対する効果を適用する。
  #--------------------------------------------------------------------------
  alias k_before_use_item use_item
  def use_item(item)
    if item.is_a?(RPG::Skill) && $game_party.in_battle
      add_skill_delay(item)  
    end
    k_before_use_item(item)
  end
  #--------------------------------------------------------------------------
  # ☆ スキル使用コストの支払い(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_pay_skill_cost pay_skill_cost
  def pay_skill_cost(skill)
    k_before_pay_skill_cost(skill)
    self.hp = [self.hp - skill_hp_cost(skill),1].max    
    if actor?
      $game_party.lose_gold(skill_gold_cost(skill))
    
      item_cost = skill_item_cost(skill)
      for list in 0..item_cost.size - 1
        if item_cost[list]
          id = item_cost[list][0]
          num = item_cost[list][1] * -1

          if skill.use_double_item    
            if dual_wield?
              if self.weapons[0] != nil && self.weapons[1] != nil
                if self.weapons[0].wtype_id = self.weapons[1].wtype_id
                  num*=2
                end
              end
            end
          end

          $game_party.gain_item($data_items[id], num)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用効果［HP 回復](エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_item_effect_recover_hp item_effect_recover_hp
  def item_effect_recover_hp(user, item, effect)
    if self.reverse_heel && item.ignore_reverse_heel == false
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
    if KURE::BaseScript::USE_SortOut == 1 && KURE::SortOut::BROKEN_CAN_EQUIP == 1
      return false unless item.is_a?(RPG::EquipItem)
      return false if item.broken?    
    end
    k_before_equippable?(item)
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
    clear_add_object_before
    k_before_setup(actor_id)
    clear_add_object_after
  end
  #--------------------------------------------------------------------------
  # ● 経験値の初期化(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_init_exp init_exp
  def init_exp
    @classlevel_list = []
    k_before_init_exp
    @classlevel_list[@class_id] = @level if KURE::BaseScript::USE_JOBLv == 0
    
    init_jobexp if KURE::BaseScript::USE_JOBLv == 1 #職業レベル
    init_actor_exp
    init_sub_class_exp if KURE::BaseScript::USE_JOBLv == 1 #職業レベル
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_learn_skill learn_skill
  def learn_skill(skill_id)
    return if $data_skills[skill_id].not_learn_list.include?(@actor_id)
    
    k_before_learn_skill(skill_id)
 
    #メモライズ容量と相談して登録する
    if KURE::BaseScript::USE_Skill_Memorize == 1
      case KURE::BaseScript::MEMORIZE_VER
      when 1
        unless KURE::SkillMemorize::NOT_AUTO_MEMORIZE.include?($data_skills[skill_id].stype_id)
          if $data_skills[skill_id].not_auto_memorize == false
            add_memorize_skill_ir(skill_id, true) if KURE::SkillMemorize::AUTO_MEMORIZE == 1
          end
        end
      when 2
        if $data_skills[skill_id].not_auto_memorize == false
          unless @memory_skills.include?(skill_id)
            add_memorize_skill(skill_id) if KURE::SkillMemorize::AUTO_MEMORIZE == 1
          end
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
    if KURE::BaseScript::USE_Skill_Memorize == 1
      case KURE::BaseScript::MEMORIZE_VER
      when 1
        @memory_skills.delete(skill_id)
      when 2
        delete_memorize_skill(skill_id)
      end
    end
  
    #パッシブスキルを更新する
    set_passive_skills
  end
  #--------------------------------------------------------------------------
  # ■ 装備の変更(エイリアス定義)
  #--------------------------------------------------------------------------
  alias k_skillmemorize_before_change_equip change_equip
  def change_equip(slot_id, item)
    cheack_obj = @equips[slot_id].object.clone if @equips[slot_id] && @equips[slot_id].object
    k_skillmemorize_before_change_equip(slot_id, item)
    refresh
    #追加装備のスキル削除処理
    auto_state_adder_ex(cheack_obj) if KURE::BaseScript::C_AUTO_STATE_ADDER == 1
  end
  #--------------------------------------------------------------------------
  # ☆ ステート情報をクリア(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_clear_states clear_states
  def clear_states
    #常時オートステート情報を保存する
    auto_state = Array.new
    if @states
      @states.each do |id|
        auto_state.push(id) if $data_states[id].not_delete_state_healing
      end
    end
    
    kure_before_clear_states
    
    if auto_state != []
      auto_state.each do |id|
        add_state(id)
      end
    end
    
    #パッシブスキルを更新する
    if @actor_id
      set_passive_skills
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias kure_before_refresh refresh
  def refresh
    kure_before_refresh
    set_passive_skills
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用可能判定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_usable? usable?
  def usable?(item)
    
    #メモライズ判定
    if item.is_a?(RPG::Skill)
      if KURE::BaseScript::USE_Skill_Memorize == 1
        if item.id != 1 && item.id != 2
          if memory_skills.include?(item) or extra_skills.include?(item) or unselect_skill?(item.id)
          else
            return false
          end
        end
      end
    end
    
    k_before_usable?(item)
  end
end

#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # ☆ スキルを設定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_set_skill set_skill
  def set_skill(skill_id)
    set_skill_id = skill_id
    @ramdom_effect = 0
    @force_action_effect = 0
    
    #行動変化
    if @subject.battler_add_ability(15) != nil
      if @subject.battler_add_ability(15) != []
        cheak_list = @subject.battler_add_ability(15).sort_by{rand}
        for list in 0..cheak_list.size - 1
          loop = 0
          dice = rand(100)
          if loop == 0
            if cheak_list[list][1] > dice
              @force_action_item = $data_skills[cheak_list[list][0]]
              set_skill_id = $data_skills[cheak_list[list][0]].id
              @force_action_effect = 1
              loop = 1
            end
          end
        end
      end
    end
    
    if $data_skills[set_skill_id].random_skill_effect != []
      select_skill = $data_skills[set_skill_id].random_skill_effect.sort_by{rand}
      @random_item = $data_skills[select_skill[0]]
      set_skill_id = @random_item.id
      @ramdom_effect = 1
    end
    
    #スキル変化
    if @subject.battler_add_ability(13)[set_skill_id] != nil
      if @subject.battler_add_ability(13)[set_skill_id] != []
        select_skill = @subject.battler_add_ability(13)[set_skill_id].sort_by{rand}
        @random_item = $data_skills[select_skill[0]]
        @ramdom_effect = 1
      end
    end
    
    k_basescript_before_set_skill(skill_id)
  end
  #--------------------------------------------------------------------------
  # ☆ アイテムを設定(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_set_item set_item
  def set_item(item_id)
    @ramdom_effect = 0
    if $data_items[item_id].random_item_effect != []
      select_item = $data_items[item_id].random_item_effect.sort_by{rand}
      @random_item = $data_items[select_item[0]]
      @ramdom_effect = 1
    end    
    
    k_basescript_before_set_item(item_id)
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
    all_battle_members.each do |battler|
      battler.reset_cheacker
    end
    
    k_before_turn_start
    
    if KURE::BaseScript::C_SE_TURN_SKILL == 1
      turn_invoke_items(1)
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果を適用(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_apply_item_effects apply_item_effects 
  def apply_item_effects(target, item)
    #最終発動スキルを取得
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
end