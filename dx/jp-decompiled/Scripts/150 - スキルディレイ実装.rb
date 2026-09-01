#==============================================================================
# ■スキルディレイオプション for RGSS3 Ver1.01
# □作成者 kure
#
# スクリプト仕様上併用化ベーススクリプトが無いと動作しません
#
# ●使用方法
# 「<スキルディレイ 2>」スキルのメモ欄に指定、指定されたスキルは
#　2ターンの間使用できなくなる。
#===============================================================================

#==============================================================================
# ■ RPG::Skill(再定義)
#==============================================================================
class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ☆ スキルディレイの定義(追加定義)
  #--------------------------------------------------------------------------  
  def skill_delay
    return 0 unless @note
    @note.match(/<スキルディレイ\s?(\d+)\s?>/)
    return 0 unless $1
    return 1 + $1.to_i
  end
  #--------------------------------------------------------------------------
  # ☆ スキルディレイの定義(追加定義)
  #--------------------------------------------------------------------------  
  def skill_delay_mode
    return 0 unless @note
    @note.match(/<ディレイモード\s?(\d+)\s?>/)
    return 0 unless $1
    return $1.to_i
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
    return true if item.skill_delay == 0
    action = @actor.actions.collect{|obj| obj.item}
    if action.include?(item)
      return false if action[@actor.action_input_index] != item
    end
    return true
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ☆ チェック配列の初期化(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_clear_cheackers clear_cheackers
  def clear_cheackers  
    k_basescript_before_clear_cheackers
    @skill_delay = [] #スキルディレイ配列の作成
  end
  #--------------------------------------------------------------------------
  # ☆ 戦闘開始処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_basescript_before_on_battle_start on_battle_start
  def on_battle_start
    k_basescript_before_on_battle_start
    make_skill_delay
  end
  #--------------------------------------------------------------------------
  # ☆ バトラースキルディレイ配列の取得(再定義)
  #--------------------------------------------------------------------------
  def make_skill_delay
    @skill_delay = [] #スキルディレイ配列の作成
  end
  #--------------------------------------------------------------------------
  # ☆ スキル／アイテムの共通使用可能条件チェック(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_usable_item_conditions_met? usable_item_conditions_met?
  def usable_item_conditions_met?(item)
    k_before_usable_item_conditions_met?(item) && skill_delay_cheacker(item)
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
  def add_skill_delay(skill, random, change)
    @skill_delay = [] unless @skill_delay
    return unless skill.is_a?(RPG::Skill)
    return unless $game_party.in_battle
    
    @skill_delay[skill.id] = skill.skill_delay
    
    case skill.skill_delay_mode
    when 1
      @skill_delay[skill.id] = random.skill_delay if random
    when 2
      @skill_delay[skill.id] = change.skill_delay if change
    end
  end
  #--------------------------------------------------------------------------
  # ☆ 発動ディレイの減少(追加定義)
  #--------------------------------------------------------------------------
  def delay_cutter
    @skill_delay.collect!{|obj| [obj - 1,0].max if obj}
  end
end