#==============================================================================
# ■戦闘中非表示スキルタイプ設定 for RGSS3 Ver1.01
# □作成者 kure
#===============================================================================
module KURE
  module Hide_Skilltype
    #非表示にするスキルタイプの設定
    HIDE_SKILL_TYPE = [2]
    
    #非表示設定モード
    #(0=項目が無くても表示、1=項目が無ければ非表示)
    HIDE_SKILL_TYPE_MODE = 1
  end
end


class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● スキルコマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_skill_commands
    @actor.added_skill_types.sort.each do |stype_id|
      #メモライズ適用時の処理(戦闘中は常に適用)
      if $kure_base_script[:Memorize]
        data = @actor ? @actor.skills.select {|skill| include_cheack?(skill,stype_id) && view_skill_b?(skill) && (@actor.memory_skills.include?(skill) or @actor.extra_skills.include?(skill) or @actor.unselect_skill?(skill.id))} : []
      else
        data = @actor ? @actor.skills.select {|skill| include_cheack?(skill,stype_id) && view_skill_b?(skill)} : []
      end
      
      unless KURE::Hide_Skilltype::HIDE_SKILL_TYPE.include?(stype_id)
        if data != [] and KURE::Hide_Skilltype::HIDE_SKILL_TYPE_MODE == 1
          name = $data_system.skill_types[stype_id]
          add_command(name, :skill, true, stype_id)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルをリストに含まれているかどうか
  #--------------------------------------------------------------------------
  def include_cheack?(item,stype_id)
    item && item.stype_id == stype_id
  end
  #--------------------------------------------------------------------------
  # ● スキルを表示するかどうか
  #--------------------------------------------------------------------------
  def view_skill_b?(item)
    item && (item.view_skill_mode == 2 or item.view_skill_mode == 3)
  end
end