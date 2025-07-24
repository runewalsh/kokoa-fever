#==============================================================================
# □ アクターコマンド改造（06/04 update）
#------------------------------------------------------------------------------
# 　アクターコマンドを改造します。
#==============================================================================
module Vocab
  def self.no_stype; "未設定"; end
end
module SceneManager
  class << self
    alias cc_actor_command_run run
    def run
      
#==============================================================================
# ☆ カスタマイズここから、
#==============================================================================
      
      # アクターコマンドを配列で指定します。
      # "スキル"、"アイテム"、"未設定"、スキル名が使用可能です。
      # スキルには使用可能なスキルタイプが羅列されます。
      # 未設定には習得済みのスキルのうちスキルタイプなしのスキルが羅列されます。
      $cc_actor_command_list = ["スキル", "魔法", "アイテム"]
      # 全てのアクターが初めから覚えているスキル名を指定します。
      $cc_actor_command_initial = ["スキル", "魔法"]

#==============================================================================
# ☆ カスタマイズここまで。
#==============================================================================

      $cc_trans_skill = {}
      DataManager.init
      $data_skills.each do |skill|
        skill == nil ? next :
        $cc_trans_skill[skill.name] = skill.id
        $cc_trans_skill[skill.id] = skill.id
      end
      $cc_trans_skill["未設定"] = 0
      $cc_trans_skill[0] = 0
      $cc_trans_skill[Vocab::skill] = 1000
      $cc_trans_skill[1000] = 1000
      $cc_trans_skill[Vocab::item] = 2000
      cc_actor_command_run
    end
  end
end

#==============================================================================
# □ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ スキルの初期化
  #--------------------------------------------------------------------------
  alias cc_actor_command_init_skills init_skills
  def init_skills
    cc_actor_command_init_skills
    $cc_actor_command_initial.each do |skill|
      learn_skill($cc_trans_skill[skill]) if $cc_trans_skill[skill]
    end
  end
end

#==============================================================================
# □ Window_ActorCommand
#------------------------------------------------------------------------------
# 　バトル画面で、アクターの行動を選択するウィンドウです。
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # ○ スキルコマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_skill_command(skill)
    add_command(skill.name, :custom_skill, @actor.usable?(skill), skill.id)
  end
  #--------------------------------------------------------------------------
  # ○ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    $cc_actor_command_list.each do |cmd|
      command_id = $cc_trans_skill[cmd]
      case command_id
      when 0
        $data_skills.each do |skill|
          if @actor.skill_learn?(skill) && skill.stype_id == 0 && 
            !$cc_actor_command_list.include?(skill.name) &&
            !$cc_actor_command_list.include?(skill.id)
            add_skill_command(skill)
          end
        end
      when 1..999
        skill = $data_skills[command_id]
        add_skill_command(skill) if @actor.skill_learn?(skill)
      when 1000
        add_skill_commands
      when 2000
        add_item_command
      end
    end
  end
end

#==============================================================================
# □ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ○ アクターコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias cc_actor_command_create_actor_command_window create_actor_command_window
  def create_actor_command_window
    cc_actor_command_create_actor_command_window
    @actor_command_window.set_handler(:custom_skill,  method(:command_custom_skill))
  end
  #--------------------------------------------------------------------------
  # ○ 敵キャラ［キャンセル］
  #--------------------------------------------------------------------------
  alias cc_actor_command_on_enemy_cancel on_enemy_cancel
  def on_enemy_cancel
    cc_actor_command_on_enemy_cancel
    case @actor_command_window.current_symbol
    when :custom_skill
      @actor_command_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ○ カスタムスキル
  #--------------------------------------------------------------------------
  def command_custom_skill
    @skill = $data_skills[@actor_command_window.current_ext]
    BattleManager.actor.input.set_skill(@skill.id)
    BattleManager.actor.last_skill.object = @skill
    if !@skill.need_selection?
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
end

