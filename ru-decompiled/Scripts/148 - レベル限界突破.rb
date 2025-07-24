#==============================================================================
# ■ RGSS3 最大レベル限界突破特徴 Ver1.00　by 星潟
#------------------------------------------------------------------------------
# このスクリプトを導入することで
# レベル100以上へのレベルアップを可能にする特徴を作成できます。
# また、レベル100以上でのレベルアップでのスキル習得設定も可能です。
# 
# 特徴を有する項目のメモ欄設定例
# 
# <レベル限界増加:10>
# 
# 限界レベルが+10されます。
# 
# <限界突破後補正:110>
# 
# レベル100以上のレベルアップ時の能力増加値の割合は
# レベル98→99の際の増加値にP_RATEで設定した％をかけたものの110％となります。
# 
# 職業の覚えるスキルのメモ欄（小さいメモ欄）設定例
# 
# <LV:120>
# 
# このスキルは本来の指定レベルで覚えず、レベル120で覚えます。
#==============================================================================
module MLV_CHANGE
  
  #レベル100以上のレベルアップ時の能力増加値の割合を設定します。
  #なお、能力増加値は、レベル98→99の際の能力を100％として計算します。
  
  P_RATE = 105
  
  #レベル限界がどれだけ増加するかを設定する特徴メモ欄用キーワードを設定します。
  
  WORD1  = "レベル限界増加"
  
  #R_RATEにさらに追加する特徴メモ欄用キーワードを設定します。
  
  WORD2  = "限界突破後補正"
  
  #そのスキルを覚えるレベルを設定する職業スキルメモ欄用キーワードを設定します。
  
  WORD3  = "LV"
  
end
class RPG::Class::Learning
  def sllv_change
    memo = @note.scan(/<#{MLV_CHANGE::WORD3}[：:](\S+)>/)
    memo = memo.flatten
    if memo != nil && !memo.empty?
      @level = memo[0].to_i
    end
  end
end
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias setup_lb setup
  def setup(actor_id)
    setup_lb(actor_id)
    @version_id = $data_system.version_id
  end
  #--------------------------------------------------------------------------
  # ● 最大レベル
  #--------------------------------------------------------------------------
  alias max_level_lb max_level
  def max_level
    data = max_level_lb
    feature_objects.each do |object|
      memo = object.note.scan(/<#{MLV_CHANGE::WORD1}[：:](\S+)>/)
      memo = memo.flatten
      if memo != nil && !memo.empty?
        data += memo[0].to_i
      end
    end
    return data
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の基本値取得
  #--------------------------------------------------------------------------
  alias param_base_lb param_base
  def param_base(param_id)
    if @level > 99
      return self.class.params[param_id, 99] + over_level_param(param_id)
    else
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
  end
  def over_level_param(param_id)
    data = self.class.params[param_id, 99] - self.class.params[param_id, 98]
    data *= @level - 99
    data *= MLV_CHANGE::P_RATE
    data /= 100
    data *= olextend_data
    data /= 100
  end
  def olextend_data
    data = 100
    feature_objects.each do |object|
      memo = object.note.scan(/<#{MLV_CHANGE::WORD2}[：:](\S+)>/)
      memo = memo.flatten
      if memo != nil && !memo.empty?
        data += memo[0].to_i
      end
    end
    return data
  end
  #--------------------------------------------------------------------------
  # ● スキルの初期化
  #--------------------------------------------------------------------------
  alias init_skills_lb init_skills
  def init_skills
    if @version_id == nil or @version_id != $data_system.version_id
      self.class.learnings.each do |learning|
        learning.sllv_change
      end
      @version_id = $data_system.version_id
    end
    init_skills_lb
  end
  #--------------------------------------------------------------------------
  # ● レベルアップ
  #--------------------------------------------------------------------------
  alias level_up_lb level_up
  def level_up
    if @version_id == nil or @version_id != $data_system.version_id
      self.class.learnings.each do |learning|
        learning.sllv_change
      end
      @version_id = $data_system.version_id
    end
    level_up_lb
  end
end