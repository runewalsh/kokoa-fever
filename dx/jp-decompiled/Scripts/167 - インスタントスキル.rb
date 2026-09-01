#==============================================================================
# ■即時発動スキル for RGSS3 Ver1.00-β6
# □作成者 kure
#==============================================================================

#==============================================================================
# ■ RPG::UsableItem (再定義)
#==============================================================================
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ☆ 即時発動スキルの定義(追加定義)
  #--------------------------------------------------------------------------  
  def no_time_effect
    return true if @note.include?("<即時発動>")
    return false
  end
end

#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # ★ アイテムオブジェクト定義(追加定義)
  #--------------------------------------------------------------------------
  def item=(item)
    @item.object = item if item
  end
  #--------------------------------------------------------------------------
  # ★ 行動主体の定義(追加定義)
  #--------------------------------------------------------------------------
  def subject=(subject)
    @subject = subject if subject
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 戦闘行動を追加(追加定義)
  #--------------------------------------------------------------------------
  def add_current_action(action)
    @actions.unshift(action)
  end
  #--------------------------------------------------------------------------
  # ● コマンド位置を一つ戻す(追加定義)
  #--------------------------------------------------------------------------
  def reinput_command
    @actions.shift
    @action_input_index -= 1
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ◎ アイテム［決定］(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_turncut_on_item_ok on_item_ok
  def on_item_ok
    @item = @item_window.item
    if @item.no_time_effect
      @subject = BattleManager.actor
      @notime_item = true
      if !@item.need_selection?
        notime_skill_process(@subject, @item)
      elsif @item.for_opponent?
        select_enemy_selection
      else
        select_actor_selection
      end
    else
      k_before_turncut_on_item_ok
    end
  end
  #--------------------------------------------------------------------------
  # ◎ アイテム［キャンセル］(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_turncut_on_item_cancel on_item_cancel
  def on_item_cancel
    @notime_item = false
    k_before_turncut_on_item_cancel
  end
  #--------------------------------------------------------------------------
  # ● スキル［決定］(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_turncut_on_skill_ok on_skill_ok
  def on_skill_ok
    @skill = @skill_window.item
    if @skill.no_time_effect
      @subject = BattleManager.actor
      @notime_skill = true
      if !@skill.need_selection?
        notime_skill_process(@subject, @skill)
      elsif @skill.for_opponent?
        select_enemy_selection
      else
        select_actor_selection
      end
    else
      k_before_turncut_on_skill_ok
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル［キャンセル］(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_turncut_on_skill_cancel on_skill_cancel
  def on_skill_cancel
    @notime_skill = false
    k_before_turncut_on_skill_cancel
  end
  #--------------------------------------------------------------------------
  # ● アクター［決定］(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_turncut_on_actor_ok on_actor_ok
  def on_actor_ok
    if @notime_skill
      notime_skill_process(@subject, @skill, @actor_window.index)
    elsif @notime_item
      notime_skill_process(@subject, @item, @actor_window.index)
    else
      k_before_turncut_on_actor_ok
    end
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラ［決定］(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_turncut_on_enemy_ok on_enemy_ok
  def on_enemy_ok
    if @notime_skill
      notime_skill_process(@subject, @skill, @enemy_window.enemy.index)
    elsif @notime_item
      notime_skill_process(@subject, @item, @enemy_window.enemy.index)
    else
      k_before_turncut_on_enemy_ok
    end
  end
  #--------------------------------------------------------------------------
  # ● 即時発動プロセス(追加定義)
  #--------------------------------------------------------------------------
  def notime_skill_process(actor, skill, target = nil)
    @actor_window.hide ; @enemy_window.hide
    @skill_window.hide ; @item_window.hide
    @notime_skill = false ; @notime_item = false
      
    @subject = actor
      
    no_time_skill = Game_Action.new(self)
    no_time_skill.subject = @subject
    no_time_skill.item = skill
    no_time_skill.target_index = target if target
      
    @subject.add_current_action(no_time_skill)
    execute_action if @subject.current_action.valid?
    @subject.reinput_command
      
    @subject = nil
    if BattleManager.in_phase?
      @status_window.open
      next_command
    end
  end
end

#==============================================================================
# ■ BattleManager
#==============================================================================
class << BattleManager
  #--------------------------------------------------------------------------
  # ★戦闘フェイズの存在判定(追加定義)
  #--------------------------------------------------------------------------
  def in_phase?
    return true if @phase
    return false
  end
end