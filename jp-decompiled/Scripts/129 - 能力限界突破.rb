#==============================================================================
# ■ RGSS3 限界突破＆限界変動特徴 Ver1.02　by 星潟
#------------------------------------------------------------------------------
# このスクリプトを導入することで各基本能力値の限界を変更できます。
# また、その限界値を増減させる特徴を作成できます。
#
# 設定例
# 
# <限界変動:0,15000>
# 
# このキャラクターの最大HPのシステム上の限界値は+15000されます。
# 
# <限界変動:1,3000>
# 
# このキャラクターの最大MPのシステム上の限界値は+3000されます。
# 
# <限界変動:2,2000>
# 
# このキャラクターの攻撃力のシステム上の限界値は+2000されます。
# 
# <限界変動:3,1000>
# 
# このキャラクターの防御力のシステム上の限界値は+1000されます。
# 
# <限界変動:4,-50>
# 
# このキャラクターの魔法力のシステム上の限界値は-50されます。
# 
# <限界変動:5,-150>
# 
# このキャラクターの魔法防御のシステム上の限界値は-150されます。
# 
# <限界変動:6,-25>
# 
# このキャラクターの敏捷性のシステム上の限界値は-25されます。
# 
# <限界変動:7,-500>
# 
# このキャラクターの運のシステム上の限界値は-500されます。
# 
# Ver1.01 味方と敵の限界が区別されていなかった不具合を修正。
# Ver1.02 1特徴で複数の限界変動効果を読み込んでいなかった不具合を修正。
#==============================================================================
module LB
  
  WORD  = "限界変動"
  
  #アクター
  
  #最大HP
  
  A_MHP = 999999
  
  #最大MP
  
  A_MMP = 99999
  
  #攻撃力
  
  A_ATK = 9999
  
  #防御力
  
  A_DEF = 9999
  
  #魔法力
  
  A_MAT = 9999
  
  #魔法防御力
  
  A_MDF = 9999
  
  #敏捷性
  
  A_AGI = 9999
  
  #運
  
  A_LUK = 9999
  
  #エネミー
  
  #最大HP
  
  E_MHP = 9999999
  
  #最大MP
  
  E_MMP = 99999
  
  #攻撃力
  
  E_ATK = 9999
  
  #防御力
  
  E_DEF = 9999
  
  #魔法力
  
  E_MAT = 9999
  
  #魔法防御力
  
  E_MDF = 9999
  
  #敏捷性
  
  E_AGI = 9999
  
  #運
  
  E_LUK = 9999
  
end
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 限界突破追加値の取得
  #--------------------------------------------------------------------------
  def limit_param(param_id)
    data = 0
    #行別に処理を取得
    feature_objects.each do |f|
      f.note.each_line do |l|
        memo = l.scan(/<#{LB::WORD}[：:](\S+),(\S+)>/).flatten
        data += memo[1].to_i if memo != nil and !memo.empty? && memo[0].to_i == param_id
      end
    end
    return data
  end
end
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 通常能力値の最大値取得
  #--------------------------------------------------------------------------
  def param_max(param_id)
    #パラメータID別に値を取得
    case param_id
    when 0;return LB::A_MHP + limit_param(param_id)
    when 1;return LB::A_MMP + limit_param(param_id)
    when 2;return LB::A_ATK + limit_param(param_id)
    when 3;return LB::A_DEF + limit_param(param_id)
    when 4;return LB::A_MAT + limit_param(param_id)
    when 5;return LB::A_MDF + limit_param(param_id)
    when 6;return LB::A_AGI + limit_param(param_id)
    when 7;return LB::A_LUK + limit_param(param_id)
    end
    return super
  end
end
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 通常能力値の最大値取得
  #--------------------------------------------------------------------------
  def param_max(param_id)
    #パラメータID別に値を取得
    case param_id
    when 0;return LB::E_MHP + limit_param(param_id)
    when 1;return LB::E_MMP + limit_param(param_id)
    when 2;return LB::E_ATK + limit_param(param_id)
    when 3;return LB::E_DEF + limit_param(param_id)
    when 4;return LB::E_MAT + limit_param(param_id)
    when 5;return LB::E_MDF + limit_param(param_id)
    when 6;return LB::E_AGI + limit_param(param_id)
    when 7;return LB::E_LUK + limit_param(param_id)
    end
    return super
  end
end

